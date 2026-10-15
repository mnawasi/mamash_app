import 'package:flutter/material.dart';
import '../buy_data_page.dart';
import '../betting_page.dart';

class VoucherPackPage extends StatefulWidget {
  const VoucherPackPage({super.key});

  @override
  State<VoucherPackPage> createState() => _VoucherPackPageState();
}

class _Voucher {
  final String value;
  final String title;
  final String available;
  final bool data;
  const _Voucher(this.value, this.title, this.available, this.data);
}

class _VoucherPackPageState extends State<VoucherPackPage> {
  // Sample vouchers for the UI. Replace with your real vouchers.
  static const _available = [
    _Voucher('\u20a640', 'Data Voucher', '\u20a63,000 available', true),
    _Voucher('\u20a610', 'Data Voucher', '\u20a61,000 available', true),
    _Voucher('\u20a650', 'Betting Voucher', '\u20a65,000 available', false),
    _Voucher('\u20a620', 'Betting Voucher', '\u20a62,000 available', false),
  ];

  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _line = Color(0xFF15463E);

  int _tab = 0; // 0 available, 1 mine

  void _use(_Voucher v) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => v.data ? const BuyDataPage() : const BettingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _available.where((v) => v.data).toList();
    final betting = _available.where((v) => !v.data).toList();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Voucher Pack',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tabs(),
            const SizedBox(height: 16),
            if (_tab == 0) ...[
              _section('Data vouchers', Icons.wifi, data),
              const SizedBox(height: 8),
              _section('Betting vouchers', Icons.sports_soccer, betting),
            ] else
              _empty(),
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
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF0E6B4E), Color(0xFF0A4A3A)]) : null,
              border: sel ? Border.all(color: _green.withValues(alpha: 0.7)) : null,
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontSize: 15,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Row(children: [tab('Available', 0), tab('My vouchers', 1)]),
    );
  }

  Widget _section(String title, IconData icon, List<_Voucher> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Row(
            children: [
              Icon(icon, color: _green, size: 22),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        ...list.map(_card),
      ],
    );
  }

  Widget _card(_Voucher v) {
    final accent = v.data ? _green : _purple;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A33), Color(0xFF08221F)]),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: accent.withValues(alpha: 0.18),
              border: Border.all(color: accent, width: 1.3),
            ),
            child: Icon(v.data ? Icons.public : Icons.sports_soccer, color: accent, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(v.value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Text(v.title, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(v.available, style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _use(v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
              ),
              child: const Text('Use',
                  style: TextStyle(color: Color(0xFF04201A), fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: const Column(
        children: [
          Icon(Icons.local_activity_outlined, color: Color(0xFF6B8F88), size: 54),
          SizedBox(height: 12),
          Text('No vouchers yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Vouchers you claim will appear here.',
              textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
        ],
      ),
    );
  }
}
