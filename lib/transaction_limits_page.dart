import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_kyc_page.dart';
import 'tier3_verification_page.dart';

class TransactionLimitsPage extends StatefulWidget {
  const TransactionLimitsPage({super.key});

  @override
  State<TransactionLimitsPage> createState() => _TransactionLimitsPageState();
}

class _Tier {
  final int number;
  final double daily;
  final String requirement;
  final Color color;
  const _Tier(this.number, this.daily, this.requirement, this.color);
}

class _TransactionLimitsPageState extends State<TransactionLimitsPage> {
  // Daily sending limit for each tier. These are only DISPLAYED here.
  // Your server must enforce them on every transfer.
  static const _tiers = [
    _Tier(1, 500000, 'Basic account', Color(0xFFFFC83D)),
    _Tier(2, 5000000, 'Verify your identity (BVN and ID)', Color(0xFF3B82F6)),
    _Tier(3, 30000000, 'Upload a NEPA (electricity) bill as proof of address', Color(0xFF22C55E)),
  ];

  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _line = Color(0xFF1B2A44);

  bool _loading = true;
  int _tierNumber = 1;
  double _dailySpent = 0;

  _Tier get _tier => _tiers[_tierNumber - 1];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    int tier = 1;
    double daily = 0;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final d = doc.data();
        if (d != null) {
          final t = d['tier'];
          int? parsed;
          if (t is num) parsed = t.toInt();
          if (t is String) parsed = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), ''));
          final verified = d['verified'] == true || d['isVerified'] == true || d['kycVerified'] == true;
          if (parsed != null && parsed >= 1 && parsed <= 3) {
            tier = parsed;
          } else if (verified) {
            tier = 2;
          }
          final ds = d['dailySpent'];
          if (ds is num) daily = ds.toDouble();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _tierNumber = tier;
      _dailySpent = daily;
      _loading = false;
    });
  }

  String _naira(double v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '\u20a6$b';
  }

  void _increase() {
    if (_tierNumber >= 3) {
      _msg('You\'re already on the highest tier');
    } else if (_tierNumber == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationKycPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const Tier3VerificationPage()));
    }
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Transaction Limits',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tierCard(),
                  const SizedBox(height: 14),
                  _dailyCard(),
                  const SizedBox(height: 18),
                  const Text('All tiers',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ..._tiers.map(_tierRow),
                  const SizedBox(height: 10),
                  _increaseButton(),
                  const SizedBox(height: 12),
                  const Text(
                    'Limits help protect your money. Move up a tier to send more each day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 12.5, height: 1.4),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tierCard() {
    final t = _tier;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: t.color.withValues(alpha: 0.1),
        border: Border.all(color: t.color.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.color.withValues(alpha: 0.2)),
            child: Icon(Icons.workspace_premium, color: t.color, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tier ${t.number}', style: TextStyle(color: t.color, fontSize: 22, fontWeight: FontWeight.w800)),
                Text('You can send up to ${_naira(t.daily)} per day',
                    style: const TextStyle(color: Color(0xFFC6D2EA), fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyCard() {
    final limit = _tier.daily;
    final remaining = (limit - _dailySpent).clamp(0, limit).toDouble();
    final progress = limit == 0 ? 0.0 : (_dailySpent / limit).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA23E), Color(0xFFC2570C)],
                  ),
                ),
                child: const Icon(Icons.today, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily limit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Resets every day', style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 12.5)),
                  ],
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(_naira(limit),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF16233A),
              valueColor: AlwaysStoppedAnimation<Color>(progress > 0.85 ? const Color(0xFFFF5A67) : _gold),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used today ${_naira(_dailySpent)}',
                  style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 12.5)),
              Text('Left ${_naira(remaining)}', style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 12.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tierRow(_Tier t) {
    final current = t.number == _tierNumber;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: current ? t.color.withValues(alpha: 0.08) : _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: current ? t.color : _line, width: current ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.color.withValues(alpha: 0.18)),
            child: Text('${t.number}', style: TextStyle(color: t.color, fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Tier ${t.number}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    if (current) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(8)),
                        child: const Text('Current',
                            style: TextStyle(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
                Text(t.requirement, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 12.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_naira(t.daily), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              const Text('per day', style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 11.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _increaseButton() {
    final top = _tierNumber >= 3;
    return GestureDetector(
      onTap: _increase,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, color: Color(0xFF3A2A00), size: 24),
            const SizedBox(width: 10),
            Text(top ? 'Highest tier reached' : 'Upgrade my tier',
                style: const TextStyle(color: Color(0xFF3A2A00), fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
