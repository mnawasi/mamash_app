import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamash_app/country_config.dart';

class _Merchant {
  final String id;
  final String name;
  final String address;
  final String hours;
  final bool sample;
  const _Merchant(this.id, this.name, this.address, this.hours,
      {this.sample = false});
}

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  static const Color _bg = Color(0xFF040C0B);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  final _search = TextEditingController();
  List<_Merchant> _all = [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final list = <_Merchant>[];
    try {
      final snap =
          await FirebaseFirestore.instance.collection('merchants').limit(50).get();
      for (final d in snap.docs) {
        final m = d.data();
        list.add(_Merchant(d.id, (m['name'] ?? 'Merchant').toString(),
            (m['address'] ?? '').toString(), (m['hours'] ?? '').toString()));
      }
    } catch (_) {}
    if (list.isEmpty) {
      list.addAll(const [
        _Merchant('sample1', 'Sample Merchant 1', 'Add real merchants in Firestore',
            '8am - 8pm',
            sample: true),
        _Merchant('sample2', 'Sample Merchant 2', 'Add real merchants in Firestore',
            '9am - 6pm',
            sample: true),
      ]);
    }
    if (!mounted) return;
    setState(() {
      _all = list;
      _loading = false;
    });
  }

  List<_Merchant> get _shown {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where((m) =>
            m.name.toLowerCase().contains(q) || m.address.toLowerCase().contains(q))
        .toList();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _request(_Merchant m) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _msg('Please log in again');
    final c = CountryConfig.current;
    final ctrl = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        title: Text('Withdraw at ${m.name}',
            style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 20),
          decoration: InputDecoration(
            prefixText: '${c.symbol} ',
            prefixStyle: const TextStyle(color: _green, fontSize: 20),
            hintText: 'Amount',
            hintStyle: const TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text.trim());
                Navigator.pop(ctx, (v != null && v > 0) ? v : null);
              },
              child: const Text('Get code')),
        ],
      ),
    );
    if (amount == null) return;
    final code = (Random.secure().nextInt(900000) + 100000).toString();
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('withdrawals')
          .add({
        'amount': amount,
        'currency': c.currencyCode,
        'merchantId': m.id,
        'merchantName': m.name,
        'code': code,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(minutes: 15))),
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _panel,
          title: const Text('Withdrawal code',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(code,
                  style: const TextStyle(
                      color: _green,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6)),
              const SizedBox(height: 12),
              Text(
                  '${c.symbol}${amount.toStringAsFixed(2)} at ${m.name}.\n'
                  'Show this code to the merchant within 15 minutes. '
                  'Cash withdrawal is not live yet, so no money has left your wallet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  Navigator.pop(ctx);
                },
                child: const Text('Copy code')),
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          ],
        ),
      );
    } catch (_) {
      _msg('Could not create the request. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _tile(_Merchant m) {
    return GestureDetector(
      onTap: _busy ? null : () => _request(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront, color: _green),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  if (m.address.isNotEmpty)
                    Text(m.address,
                        style:
                            const TextStyle(color: Colors.white54, fontSize: 13)),
                  if (m.hours.isNotEmpty)
                    Text(m.hours,
                        style: const TextStyle(color: _green, fontSize: 12)),
                  if (m.sample)
                    const Text('Sample entry',
                        style: TextStyle(color: Colors.orange, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
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
            colors: [Color(0xFF062A22), Color(0xFF040C0B), Color(0xFF040C0B)],
            stops: [0, .4, 1],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    const Text('Withdraw',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search merchants',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: _panel,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _line)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _line)),
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: _green))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _line),
                            ),
                            child: const Text(
                                'Pick a merchant, enter an amount and get a 6-digit '
                                'code. Cash withdrawal opens once our merchant '
                                'network is live.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4)),
                          ),
                          for (final m in _shown) _tile(m),
                          if (_shown.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                  child: Text('No merchants found',
                                      style: TextStyle(color: Colors.white54))),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
