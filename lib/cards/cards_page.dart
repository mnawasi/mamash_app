import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  int _tab = 0; // 0 virtual, 1 physical
  int _currency = 0; // 0 NGN, 1 USD (virtual only)
  String _name = '';
  bool _onList = false;
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? '';
    bool onList = false;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final d = doc.data();
        if (d != null) {
          for (final k in ['fullName', 'name', 'displayName', 'username']) {
            final v = d[k];
            if (v is String && v.trim().isNotEmpty) {
              name = v.trim();
              break;
            }
          }
          onList = d['cardWaitlist'] == true;
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _name = name;
      _onList = onList;
      _loading = false;
    });
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _notify() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _msg('Please log in again');
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'cardWaitlist': true,
        'cardWaitlistAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _onList = true);
      _msg('You\'re on the list. We\'ll let you know when cards launch.');
    } catch (_) {
      _msg('Could not save. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF063A31), Color(0xFF03110F)],
            stops: [0, .4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _tabs(),
                const SizedBox(height: 16),
                _cardPreview(),
                if (_tab == 0) ...[
                  const SizedBox(height: 14),
                  _currencyChips(),
                ],
                const SizedBox(height: 16),
                _actions(),
                const SizedBox(height: 18),
                _comingCard(),
                const SizedBox(height: 18),
                _notifyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cards', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              Text('Spend online and in stores', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF3A2E0A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8B83D)),
          ),
          child: const Text('Coming soon',
              style: TextStyle(color: Color(0xFFFFD66B), fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _tabs() {
    Widget tab(String label, IconData icon, int i) {
      final sel = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF0E6B4E), Color(0xFF0A4A3A)]) : null,
              border: sel ? Border.all(color: _green.withValues(alpha: 0.7)) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: sel ? _green : Colors.white70, size: 22),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _line),
      ),
      child: Row(children: [tab('Virtual', Icons.credit_card, 0), tab('Physical', Icons.contactless, 1)]),
    );
  }

  Widget _cardPreview() {
    final physical = _tab == 1;
    final usd = _tab == 0 && _currency == 1;
    final colors = physical
        ? const [Color(0xFF2A2210), Color(0xFF6B4E10), Color(0xFF2A2210)]
        : usd
            ? const [Color(0xFF123A7A), Color(0xFF1D4ED8), Color(0xFF0A2250)]
            : const [Color(0xFF0E7A57), Color(0xFF1FE5A0), Color(0xFF0A4A38)];
    final shownName = _loading ? '' : (_name.isEmpty ? 'YOUR NAME' : _name.toUpperCase());

    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
          boxShadow: [BoxShadow(color: colors[1].withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Mamash',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(physical ? 'PHYSICAL' : (usd ? 'VIRTUAL \u2022 USD' : 'VIRTUAL \u2022 NGN'),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: const LinearGradient(colors: [Color(0xFFFFE08A), Color(0xFFD9A21C)]),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('\u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022  \u2022\u2022\u2022\u2022',
                    style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(shownName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                    const Text('\u2022\u2022/\u2022\u2022', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _currencyChips() {
    Widget chip(String label, String flag, int i) {
      final sel = _currency == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _currency = i),
          child: Container(
            height: 46,
            margin: EdgeInsets.only(right: i == 0 ? 10 : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: sel ? _green.withValues(alpha: 0.15) : _panel,
              border: Border.all(color: sel ? _green : _line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(color: sel ? _green : Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(children: [chip('Naira card', '\u{1F1F3}\u{1F1EC}', 0), chip('Dollar card', '\u{1F1FA}\u{1F1F8}', 1)]);
  }

  Widget _actions() {
    Widget item(IconData icon, String label) {
      return Expanded(
        child: GestureDetector(
          onTap: () => _msg('$label will be available when cards launch'),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _panel,
                  border: Border.all(color: _line),
                ),
                child: Icon(icon, color: Colors.white38, size: 26),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        item(Icons.add, 'Fund'),
        item(Icons.ac_unit, 'Freeze'),
        item(Icons.visibility_outlined, 'Details'),
        item(Icons.tune, 'Limits'),
      ],
    );
  }

  Widget _comingCard() {
    Widget row(IconData icon, String title, String sub) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: _green.withValues(alpha: 0.12),
                border: Border.all(color: _green.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: _green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final physical = _tab == 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What\'s coming', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (!physical) ...[
            row(Icons.shopping_bag_outlined, 'Pay online', 'Use your card for online shopping and subscriptions'),
            row(Icons.public, 'Naira and dollar cards', 'Choose the currency that fits what you\'re paying for'),
          ] else ...[
            row(Icons.storefront_outlined, 'Pay in stores', 'Tap or swipe at shops and withdraw cash at ATMs'),
            row(Icons.local_shipping_outlined, 'Delivered to you', 'Request a card and have it sent to your address'),
          ],
          row(Icons.ac_unit, 'Freeze anytime', 'Lock and unlock your card instantly from the app'),
          row(Icons.tune, 'Your own limits', 'Set how much can be spent each day or month'),
        ],
      ),
    );
  }

  Widget _notifyButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: (_onList || _busy || _loading) ? null : _notify,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: _onList
                  ? null
                  : const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
              color: _onList ? _green.withValues(alpha: 0.12) : null,
              border: _onList ? Border.all(color: _green) : null,
              boxShadow: _onList ? null : [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)],
            ),
            child: Center(
              child: _busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF04201A)))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_onList ? Icons.check_circle : Icons.notifications_active,
                            color: _onList ? _green : const Color(0xFF04201A), size: 22),
                        const SizedBox(width: 10),
                        Text(_onList ? 'You\'re on the list' : 'Notify me when cards launch',
                            style: TextStyle(
                                color: _onList ? _green : const Color(0xFF04201A),
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
