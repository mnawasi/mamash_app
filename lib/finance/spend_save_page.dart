import 'package:flutter/material.dart';
import 'finance_common.dart';
import 'savings_common.dart';

class SpendSavePage extends StatefulWidget {
  const SpendSavePage({super.key});

  @override
  State<SpendSavePage> createState() => _SpendSavePageState();
}

class _SpendSavePageState extends State<SpendSavePage> {
  static const Color _green2 = Color(0xFF22C55E);
  static const _percents = [10, 15, 20, 50, 100];
  final _svc = SavingsService();
  final _wallets = walletStream();
  final _savings = savingsStream();
  String _code = 'NGN';
  int _percent = 10;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    financeCountry().then((c) {
      if (mounted) setState(() => _code = c.currencyCode);
    });
  }

  void _msg(String t) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _run(Future<Map<String, dynamic>> Function() job, String ok) async {
    setState(() => _busy = true);
    try {
      await job();
      _msg(ok);
    } on SavingsException catch (e) {
      _msg(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  double _preview(double wallet) => (wallet * _percent).floorToDouble() / 100;

  Future<void> _move(double wallet) async {
    final c = configFor(_code);
    final amt = _preview(wallet);
    if (amt < minFor(_code)) return _msg('Your ${c.currencyName} wallet is too low for $_percent%');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FT.panel,
        title: const Text('Move to Spend & Save?', style: TextStyle(color: Colors.white)),
        content: Text(
          '$_percent% of your wallet (${c.symbol}${money(amt)}) will be taken from your ${c.currencyName} wallet and put into Spend & Save.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Move money', style: TextStyle(color: FT.green))),
        ],
      ),
    );
    if (ok == true) await _run(() => _svc.spendSaveMove(currency: _code, percent: _percent), 'Moved to Spend & Save');
  }

  Future<void> _withdraw(Saving s) async {
    final c = configFor(_code);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FT.panel,
        title: const Text('Withdraw everything?', style: TextStyle(color: Colors.white)),
        content: Text('${c.symbol}${money(s.balance)} goes back to your ${c.currencyName} wallet.',
            style: const TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Withdraw', style: TextStyle(color: FT.green))),
        ],
      ),
    );
    if (ok == true) await _run(() => _svc.breakPlan(s.id), 'Money returned to your wallet');
  }

  @override
  Widget build(BuildContext context) {
    final c = configFor(_code);
    return FinScaffold(
      title: 'Spend & Save',
      subtitle: 'Set money aside from your wallet',
      accent: _green2,
      children: [
        CurrencyChips(selected: _code, onChanged: (v) => setState(() => _code = v)),
        StreamBuilder<Map<String, double>>(
          stream: _wallets,
          builder: (context, ws) {
            final wallet = ws.data?[_code] ?? 0;
            return StreamBuilder<List<Saving>>(
              stream: _savings,
              builder: (context, ss) {
                final list = (ss.data ?? []).where((s) => s.type == 'spendsave' && s.currency == _code).toList();
                final box = list.isEmpty ? null : list.first;
                final bal = box?.balance ?? 0;
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(colors: [Color(0xFF166534), Color(0xFF14532D), Color(0xFF052E16)]),
                        border: Border.all(color: _green2.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('In Spend & Save', style: TextStyle(color: Color(0xFFBBF7D0), fontSize: 14)),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('${c.symbol}${money(bal)}',
                                style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 4),
                          Text('${c.currencyName} wallet: ${c.symbol}${money(wallet)}',
                              style: const TextStyle(color: Color(0xFFBBF7D0), fontSize: 13)),
                        ],
                      ),
                    ),
                    FinPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('How much of your wallet?',
                              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Row(
                            children: _percents.map((p) {
                              final sel = _percent == p;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _percent = p),
                                  child: Container(
                                    height: 48,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: sel ? _green2.withValues(alpha: 0.18) : FT.inner,
                                      border: Border.all(color: sel ? _green2 : FT.line, width: sel ? 1.6 : 1),
                                    ),
                                    child: Center(
                                      child: Text('$p%',
                                          style: TextStyle(
                                              color: sel ? _green2 : Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Text('$_percent% of your wallet is ${c.symbol}${money(_preview(wallet))}',
                              style: const TextStyle(color: Color(0xFFD5E8E4), fontSize: 14)),
                        ],
                      ),
                    ),
                    FinButton(label: 'Move $_percent% to Spend & Save', icon: Icons.south, busy: _busy, onTap: () => _move(wallet)),
                    const SizedBox(height: 10),
                    FinButton(
                      label: 'Withdraw all',
                      icon: Icons.north,
                      outline: true,
                      onTap: (bal > 0 && box != null && !_busy) ? () => _withdraw(box) : () => _msg('Nothing to withdraw yet'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
