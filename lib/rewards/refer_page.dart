import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class ReferPage extends StatefulWidget {
  const ReferPage({super.key});

  @override
  State<ReferPage> createState() => _ReferPageState();
}

class _ReferPageState extends State<ReferPage> {
  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  String _code = '';
  int _invited = 0;
  double _earned = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    String code = '';
    int invited = 0;
    double earned = 0;
    if (user != null) {
      final uid = user.uid;
      code = (uid.length >= 6 ? uid.substring(0, 6) : uid).toUpperCase();
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final d = doc.data();
        if (d != null) {
          final c = d['referralCode'];
          if (c is String && c.trim().isNotEmpty) code = c.trim().toUpperCase();
          final n = d['referralCount'];
          if (n is num) invited = n.toInt();
          final e = d['referralEarnings'];
          if (e is num) earned = e.toDouble();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _code = code;
      _invited = invited;
      _earned = earned;
      _loading = false;
    });
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String get _message =>
      'Join me on Mamash Pay. Send money, buy airtime and data, and pay bills in one app. '
      'Use my invite code $_code when you sign up.';

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _code));
    _msg('Code copied');
  }

  Future<void> _share() async {
    try {
      await SharePlus.instance.share(ShareParams(text: _message));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: _message));
      _msg('Couldn\'t open sharing. The invite message was copied instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Refer & Earn',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(),
                  const SizedBox(height: 16),
                  _codeCard(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _stat(Icons.group, 'Friends invited', '$_invited')),
                      const SizedBox(width: 12),
                      Expanded(child: _stat(Icons.savings, 'Cashback earned', '\u20a6${_earned.toStringAsFixed(2)}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _steps(),
                ],
              ),
            ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E5A45), Color(0xFF0A3A32), Color(0xFF08261F)],
        ),
        border: Border.all(color: _green.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF3B9BFF), Color(0xFF1D5FE8)]),
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invite friends to Mamash',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Share your code and earn cashback when they join.',
                    style: TextStyle(color: Color(0xFFC6DAD6), fontSize: 13.5, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          const Text('Your invite code', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF051A17),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _green.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_code.isEmpty ? '------' : _code,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 5)),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: _code.isEmpty ? null : _copy,
                  child: const Icon(Icons.copy, color: _green, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _code.isEmpty ? null : _share,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
                boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share, color: Color(0xFF04201A), size: 22),
                  SizedBox(width: 10),
                  Text('Share invite', style: TextStyle(color: Color(0xFF04201A), fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _green, size: 24),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          Text(label, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5)),
        ],
      ),
    );
  }

  Widget _steps() {
    Widget step(int n, String title, String sub) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: _green,
              child: Text('$n', style: const TextStyle(color: Color(0xFF04201A), fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How it works', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          step(1, 'Share your code', 'Send your invite code to friends and family.'),
          step(2, 'They sign up', 'Your friend creates a Mamash account using your code.'),
          step(3, 'You earn cashback', 'Cashback is added to your Rewards balance.'),
        ],
      ),
    );
  }
}
