import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../country_config.dart';
import 'finance_common.dart';

const List<String> kWalletCodes = ['NGN', 'GHS', 'CAD', 'USD', 'GBP'];

double minFor(String code) => code == 'NGN' ? 100 : 1;

CountryConfig configFor(String code) {
  for (final c in CountryConfig.all) {
    if (c.currencyCode == code) return c;
  }
  return CountryConfig.all.first;
}

String dateLabel(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[d.month - 1]} ${d.day}, ${d.year}';
}

Stream<Map<String, double>> walletStream() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(<String, double>{});
  return FirebaseFirestore.instance.collection('users').doc(uid).snapshots().map((d) {
    final w = d.data()?['wallets'];
    final out = <String, double>{};
    if (w is Map) {
      w.forEach((k, v) {
        if (v is num) out['$k'] = v.toDouble();
      });
    }
    return out;
  });
}

class Saving {
  final String id;
  final String type;
  final String currency;
  final String status;
  final double balance;
  final DateTime? lockedUntil;
  final DateTime? createdAt;
  final int? lockDays;
  const Saving({
    required this.id,
    required this.type,
    required this.currency,
    required this.status,
    required this.balance,
    this.lockedUntil,
    this.createdAt,
    this.lockDays,
  });

  factory Saving.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    DateTime? ts(dynamic v) => v is Timestamp ? v.toDate() : null;
    return Saving(
      id: d.id,
      type: (m['type'] ?? '') as String,
      currency: (m['currency'] ?? 'NGN') as String,
      status: (m['status'] ?? 'active') as String,
      balance: ((m['balance'] as num?) ?? 0).toDouble(),
      lockedUntil: ts(m['lockedUntil']),
      createdAt: ts(m['createdAt']),
      lockDays: (m['lockDays'] as num?)?.toInt(),
    );
  }
}

Stream<List<Saving>> savingsStream() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(<Saving>[]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('savings')
      .snapshots()
      .map((s) => s.docs.map(Saving.fromDoc).toList());
}

class SavingsException implements Exception {
  final String message;
  SavingsException(this.message);
  @override
  String toString() => message;
}

class SavingsService {
  final FirebaseFunctions _f = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> _call(String name, Map<String, dynamic> data) async {
    try {
      final r = await _f.httpsCallable(name).call(data);
      return Map<String, dynamic>.from(r.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw SavingsException(e.message ?? 'Something went wrong. Please try again.');
    } catch (_) {
      throw SavingsException('Could not reach the server. Check your connection.');
    }
  }

  Future<Map<String, dynamic>> deposit({
    required String type,
    required String currency,
    required double amount,
    String? planId,
    int? lockDays,
  }) =>
      _call('savingsDeposit', {
        'type': type,
        'currency': currency,
        'amount': amount,
        if (planId != null) 'planId': planId,
        if (lockDays != null) 'lockDays': lockDays,
      });

  Future<Map<String, dynamic>> breakPlan(String planId) => _call('savingsBreak', {'planId': planId});

  Future<Map<String, dynamic>> spendSaveMove({required String currency, required int percent}) =>
      _call('spendSaveMove', {'currency': currency, 'percent': percent});
}

class CurrencyChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const CurrencyChips({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: kWalletCodes.map((code) {
          final c = configFor(code);
          final sel = code == selected;
          return GestureDetector(
            onTap: () => onChanged(code),
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: sel ? FT.green.withValues(alpha: 0.15) : FT.panel,
                border: Border.all(color: sel ? FT.green : FT.line, width: sel ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Text(c.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(code,
                      style: TextStyle(color: sel ? FT.green : Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

Future<double?> askAmount(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required CountryConfig ccy,
  required double walletBalance,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FT.panel,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AmountSheet(title: title, confirmLabel: confirmLabel, ccy: ccy, walletBalance: walletBalance),
  );
}

class _AmountSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final CountryConfig ccy;
  final double walletBalance;
  const _AmountSheet({required this.title, required this.confirmLabel, required this.ccy, required this.walletBalance});

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  final _ctrl = TextEditingController();
  String _error = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _quick(int pct) {
    final v = (widget.walletBalance * pct).floorToDouble() / 100;
    setState(() => _ctrl.text = v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2));
  }

  void _ok() {
    final v = double.tryParse(_ctrl.text.trim());
    final min = minFor(widget.ccy.currencyCode);
    if (v == null || v <= 0) return setState(() => _error = 'Enter an amount');
    if (v < min) return setState(() => _error = 'Minimum is ${widget.ccy.symbol}${money(min, decimals: 0)}');
    if (v > widget.walletBalance) return setState(() => _error = 'That is more than your wallet balance');
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Wallet balance: ${widget.ccy.symbol}${money(widget.walletBalance)}',
                style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
            const SizedBox(height: 14),
            Row(
              children: [25, 50, 75, 100].map((p) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _quick(p),
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: FT.green.withValues(alpha: 0.6)),
                      ),
                      child: Center(
                        child: Text(p == 100 ? 'Max' : '$p%',
                            style: const TextStyle(color: FT.green, fontSize: 13.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: FT.inner,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FT.line),
              ),
              child: Row(
                children: [
                  Text(widget.ccy.symbol, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      cursorColor: FT.green,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'Amount',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error, style: const TextStyle(color: Color(0xFFFF5A67), fontSize: 13.5)),
              ),
            const SizedBox(height: 18),
            FinButton(label: widget.confirmLabel, icon: Icons.check, onTap: _ok),
          ],
        ),
      ),
    );
  }
}
