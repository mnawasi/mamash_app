import 'package:flutter/material.dart';
import '../country_config.dart';
import 'finance_common.dart';
import 'savings_common.dart';

class SafeBoxPage extends StatefulWidget {
  const SafeBoxPage({super.key});

  @override
  State<SafeBoxPage> createState() => _SafeBoxPageState();
}

class _SafeBoxPageState extends State<SafeBoxPage> {
  static const Color _blue = Color(0xFF3B82F6);
  final _svc = SavingsService();
  final _wallets = walletStream();
  final _savings = savingsStream();
  String _code = 'NGN';
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

  Future<void> _add(double wallet) async {
    final c = configFor(_code);
    final amt = await askAmount(context, title: 'Add to SafeBox', confirmLabel: 'Add to SafeBox', ccy: c, walletBalance: wallet);
    if (amt == null) return;
    await _run(() => _svc.deposit(type: 'safebox', currency: _code, amount: amt), 'Added to your SafeBox');
  }

  Future<void> _break(Saving box) async {
    final c = configFor(_code);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FT.panel,
        title: const Text('Break your SafeBox?', style: TextStyle(color: Colors.white)),
        content: Text(
          'All ${c.symbol}${money(box.balance)} in your SafeBox goes back to your ${c.currencyName} wallet.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it locked')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Break SafeBox', style: TextStyle(color: Color(0xFFFF5A67))),
          ),
        ],
      ),
    );
    if (ok == true) await _run(() => _svc.breakPlan(box.id), 'SafeBox broken. Your money is back in your wallet.');
  }

  @override
  Widget build(BuildContext context) {
    final c = configFor(_code);
    return FinScaffold(
      title: 'SafeBox',
      subtitle: 'Keep money out of reach until you need it',
      accent: _blue,
      children: [
        CurrencyChips(selected: _code, onChanged: (v) => setState(() => _code = v)),
        StreamBuilder<Map<String, double>>(
          stream: _wallets,
          builder: (context, ws) {
            final wallet = ws.data?[_code] ?? 0;
            return StreamBuilder<List<Saving>>(
              stream: _savings,
              builder: (context, ss) {
                final boxes = (ss.data ?? []).where((s) => s.type == 'safebox' && s.currency == _code).toList();
                final box = boxes.isEmpty ? null : boxes.first;
                final bal = box?.balance ?? 0;
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF0F1F4D)],
                        ),
                        border: Border.all(color: _blue.withValues(alpha: 0.6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text('In your SafeBox', style: TextStyle(color: Color(0xFFC7D8FF), fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('${c.symbol}${money(bal)}',
                                style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 6),
                          Text('${c.currencyName} wallet: ${c.symbol}${money(wallet)}',
                              style: const TextStyle(color: Color(0xFFC7D8FF), fontSize: 13)),
                        ],
                      ),
                    ),
                    FinButton(label: 'Add money', icon: Icons.add, busy: _busy, onTap: () => _add(wallet)),
                    const SizedBox(height: 10),
                    FinButton(
                      label: 'Break SafeBox',
                      icon: Icons.lock_open,
                      outline: true,
                      onTap: (bal > 0 && box != null && !_busy) ? () => _break(box) : () => _msg('Your SafeBox is empty'),
                    ),
                    const SizedBox(height: 16),
                    const FinPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How SafeBox works', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                          SizedBox(height: 10),
                          _Point('Add money from your wallet whenever you like.'),
                          _Point('Money in your SafeBox is kept apart from your everyday wallet.'),
                          _Point('Need it back? Break your SafeBox and everything returns to your wallet straight away.'),
                        ],
                      ),
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

class _Point extends StatelessWidget {
  final String text;
  const _Point(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 3), child: Icon(Icons.check_circle, color: FT.green, size: 17)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFD5E8E4), fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}
