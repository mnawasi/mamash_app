import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../models/mamash_giftcard.dart';
import 'giftcard_service.dart';
import '../country_config.dart';

class GiftCardsPage extends StatefulWidget {
  const GiftCardsPage({super.key});

  @override
  State<GiftCardsPage> createState() => _GiftCardsPageState();
}

class _TypeInfo {
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  const _TypeInfo(this.title, this.sub, this.icon, this.color);
}

class _GiftCardsPageState extends State<GiftCardsPage> {
  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  static const _amounts = [1000, 2000, 5000, 10000, 20000];
  static const Map<GiftcardType, _TypeInfo> _info = {
    GiftcardType.favi: _TypeInfo('Favi', 'For your loved ones', Icons.favorite, Color(0xFFFF5C8A)),
    GiftcardType.mama: _TypeInfo('Mama', 'Family supporting each other', Icons.family_restroom, Color(0xFFFFB02E)),
    GiftcardType.lucky: _TypeInfo('Lucky', 'Random giveaway', Icons.celebration, Color(0xFF8B5CF6)),
  };

  final _service = GiftcardService();
  final _codeCtrl = TextEditingController();
  int _tab = 0; // 0 send, 1 redeem, 2 my cards
  GiftcardType _type = GiftcardType.favi;
  int? _amount;
  bool _busy = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _naira(num v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '${CountryConfig.current.symbol}$b';
  }

  Future<void> _create() async {
    final amt = _amount;
    if (amt == null) return _msg('Choose an amount');
    final info = _info[_type]!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: Text('Create ${info.title} card', style: const TextStyle(color: Colors.white)),
        content: Text('${_naira(amt)} will be taken from your Naira wallet. Whoever redeems the code receives the money.',
            style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final r = await _service.buy(amount: amt, type: _type.name);
      if (!mounted) return;
      await _showCode(r['code'] as String, amt);
    } on GiftcardException catch (e) {
      _msg(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showCode(String code, int amount) async {
    final text = 'I sent you a Mamash gift card worth ${_naira(amount)}! '
        'Open Mamash Pay, go to Gift Cards, tap Redeem and enter this code: $code';
    await showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: _green, size: 48),
              const SizedBox(height: 10),
              Text('${_naira(amount)} gift card ready',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF051A17),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _green.withValues(alpha: 0.6)),
                ),
                child: SelectableText(code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              const Text('Share this code. The first person to redeem it gets the money.',
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        if (mounted) _msg('Code copied');
                      },
                      icon: const Icon(Icons.copy, color: _green),
                      label: const Text('Copy', style: TextStyle(color: _green)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: _green)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await SharePlus.instance.share(ShareParams(text: text));
                        } catch (_) {
                          await Clipboard.setData(ClipboardData(text: text));
                          if (mounted) _msg('Message copied');
                        }
                      },
                      icon: const Icon(Icons.share, color: Color(0xFF04201A)),
                      label: const Text('Share', style: TextStyle(color: Color(0xFF04201A), fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(backgroundColor: _green),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeem() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return _msg('Enter the gift card code');
    setState(() => _busy = true);
    try {
      final r = await _service.redeem(code);
      if (!mounted) return;
      _codeCtrl.clear();
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _panel,
          title: const Text('Gift card redeemed', style: TextStyle(color: Colors.white)),
          content: Text('${_naira(r['amount'] as num)} was added to your Naira wallet.',
              style: const TextStyle(color: Colors.white70)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great', style: TextStyle(color: _green)))],
        ),
      );
    } on GiftcardException catch (e) {
      _msg(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
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
        title: const Text('Gift Cards', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(),
            const SizedBox(height: 18),
            if (_tab == 0) _send(),
            if (_tab == 1) _redeemTab(),
            if (_tab == 2) _myCards(),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String label, int i) {
      final sel = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF0E6B4E), Color(0xFF0A4A3A)]) : null,
              border: sel ? Border.all(color: _green.withValues(alpha: 0.7)) : null,
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white70, fontSize: 14.5, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(26), border: Border.all(color: _line)),
      child: Row(children: [tab('Send a gift', 0), tab('Redeem', 1), tab('My cards', 2)]),
    );
  }

  final Map<GiftcardType, String> _messages = {
    GiftcardType.favi:
        'Some people are not just people. They are home.\n\nYou are my peace, my smile, my favourite hello.\nThis is not just a gift card. Na small piece of my heart I send for you.',
    GiftcardType.mama:
        'Mama, everything good in me started with you.\n\nYour prayers carried me, your sacrifices built me, and your love never once asked for anything back.\nThis is not just a gift card. It is a small thank you for a lifetime of love.',
    GiftcardType.lucky:
        'Today, luck found you, but someone thought of you first.\n\nThey wanted to make your day a little brighter and remind you that good things find good people.\nEnjoy this little surprise, and pass the kindness on.',
  };

  static const Map<GiftcardType, List<String>> _msgHead = {
    GiftcardType.favi: ['\u2764\uFE0F', 'To My Favi', '\u2014 From someone who thinks about you always'],
    GiftcardType.mama: ['\u{1F338}', 'To Mama', '\u2014 Your child, who loves you always'],
    GiftcardType.lucky: ['\u{1F340}', 'To the Lucky One', '\u2014 From someone who wants you to smile'],
  };

  void _showMessage(GiftcardType t) {
    final head = _msgHead[t]!;
    final i = _info[t]!;
    final ctrl = TextEditingController(text: _messages[t]);
    setState(() => _type = t);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _line),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(head[0], style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(head[1],
                  style: TextStyle(
                      color: i.color, fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: null,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14.5, height: 1.45),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  hintText: 'Write your message',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
              const SizedBox(height: 6),
              Text(head[2],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                      fontSize: 13)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _messages[t] = ctrl.text;
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Send Love Now \u{1F48C}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _send() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose a card', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...GiftcardType.values.map((t) {
          final i = _info[t]!;
          final sel = _type == t;
          return GestureDetector(
            onTap: () => setState(() => _type = t),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: sel ? i.color.withValues(alpha: 0.12) : _panel,
                border: Border.all(color: sel ? i.color : _line, width: sel ? 1.6 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: i.color.withValues(alpha: 0.2)),
                    child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showMessage(t),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(i.icon, color: i.color, size: 26),
                    ),
                  ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.title, style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
                        Text(i.sub, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
                      ],
                    ),
                  ),
                  if (sel) Icon(Icons.check_circle, color: i.color),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 10),
        const Text('Amount', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _amounts.map((a) {
            final sel = _amount == a;
            return GestureDetector(
              onTap: () => setState(() => _amount = a),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: sel ? _green.withValues(alpha: 0.15) : _panel,
                  border: Border.all(color: sel ? _green : _line, width: sel ? 1.6 : 1),
                ),
                child: Text(_naira(a),
                    style: TextStyle(color: sel ? _green : Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _bigButton(_busy ? null : 'Create gift card', _busy ? null : _create),
      ],
    );
  }

  Widget _redeemTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter your gift card code',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: _line)),
          child: TextField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'MAMASH-FAVI-XXXXXXXXXXXX',
              hintStyle: TextStyle(color: Color(0xFF6B8F88), fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('The money is added to your Naira wallet straight away.',
            style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5)),
        const SizedBox(height: 24),
        _bigButton(_busy ? null : 'Redeem', _busy ? null : _redeem),
      ],
    );
  }

  Widget _myCards() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Text('Please log in.', style: TextStyle(color: Colors.white70));
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('giftcards').where('senderId', isEqualTo: uid).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Text('Could not load your cards.', style: TextStyle(color: Colors.white70));
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        final cards = snap.data!.docs.map((d) => MamashGiftcard.fromMap(d.id, d.data())).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (cards.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _line)),
            child: const Column(
              children: [
                Icon(Icons.card_giftcard, color: Color(0xFF6B8F88), size: 50),
                SizedBox(height: 10),
                Text('No gift cards yet', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Cards you create will appear here.', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
              ],
            ),
          );
        }
        return Column(children: cards.map(_cardTile).toList());
      },
    );
  }

  Widget _cardTile(MamashGiftcard c) {
    final i = _info[c.type]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: i.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: i.color.withValues(alpha: 0.2)),
            child: Icon(i.icon, color: i.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${i.title}  \u2022  ${_naira(c.amountNaira)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800)),
                Text(c.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12)),
                const SizedBox(height: 4),
                Text(c.isRedeemed ? 'Redeemed' : 'Not redeemed yet',
                    style: TextStyle(color: c.isRedeemed ? const Color(0xFF8FA3C8) : _green, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (!c.isRedeemed)
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: c.code));
                if (mounted) _msg('Code copied');
              },
              child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.copy, color: _green, size: 20)),
            ),
        ],
      ),
    );
  }

  Widget _bigButton(String? label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Center(
          child: label == null
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF04201A)))
              : Text(label, style: const TextStyle(color: Color(0xFF04201A), fontSize: 17, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
