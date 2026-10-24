import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../country_config.dart';
import 'finance_common.dart';
import 'savings_common.dart';

class FixedSavingsPage extends StatefulWidget {
  const FixedSavingsPage({super.key});

  @override
  State<FixedSavingsPage> createState() => _FixedSavingsPageState();
}

class _FixedSavingsPageState extends State<FixedSavingsPage> {
  static const Color _gold = Color(0xFFFFB02E);
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

  Future<void> _newPlan(double wallet) async {
    final c = configFor(_code);
    final r = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FT.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NewPlanSheet(ccy: c, wallet: wallet),
    );
    if (r == null) return;
    await _run(
      () => _svc.deposit(type: 'fixed', currency: _code, amount: r['amount'] as double, lockDays: r['days'] as int),
      'Your savings plan has started',
    );
  }

  Future<void> _add(Saving p, double wallet) async {
    final c = configFor(_code);
    final amt = await askAmount(context, title: 'Add to this plan', confirmLabel: 'Add money', ccy: c, walletBalance: wallet);
    if (amt == null) return;
    await _run(() => _svc.deposit(type: 'fixed', currency: _code, amount: amt, planId: p.id), 'Money added to your plan');
  }

  Future<void> _break(Saving p, bool matured) async {
    final c = configFor(_code);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FT.panel,
        title: Text(matured ? 'Withdraw your savings?' : 'Break this plan early?', style: const TextStyle(color: Colors.white)),
        content: Text(
          matured
              ? '${c.symbol}${money(p.balance)} goes back to your ${c.currencyName} wallet.'
              : 'Your plan ends now and ${c.symbol}${money(p.balance)} goes back to your ${c.currencyName} wallet. You can start a new plan any time.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(matured ? 'Withdraw' : 'Break plan', style: TextStyle(color: matured ? FT.green : const Color(0xFFFF5A67))),
          ),
        ],
      ),
    );
    if (ok == true) await _run(() => _svc.breakPlan(p.id), 'Done. Your money is back in your wallet.');
  }

  @override
  Widget build(BuildContext context) {
    final c = configFor(_code);
    return FinScaffold(
      title: 'Fixed Savings',
      subtitle: 'Save for a set period',
      accent: _gold,
      children: [
        CurrencyChips(selected: _code, onChanged: (v) => setState(() => _code = v)),
        StreamBuilder<Map<String, double>>(
          stream: _wallets,
          builder: (context, ws) {
            final wallet = ws.data?[_code] ?? 0;
            return StreamBuilder<List<Saving>>(
              stream: _savings,
              builder: (context, ss) {
                final plans = (ss.data ?? [])
                    .where((s) => s.type == 'fixed' && s.currency == _code && s.status == 'active')
                    .toList()
                  ..sort((a, b) => (a.lockedUntil ?? DateTime(2100)).compareTo(b.lockedUntil ?? DateTime(2100)));
                final total = plans.fold<double>(0, (a, p) => a + p.balance);
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const LinearGradient(colors: [Color(0xFF7A4E0B), Color(0xFF4A3008), Color(0xFF2A1C06)]),
                        border: Border.all(color: _gold.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total in fixed plans', style: TextStyle(color: Color(0xFFFFE3A3), fontSize: 14)),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text('${c.symbol}${money(total)}',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 4),
                          Text('${plans.length} active ${plans.length == 1 ? 'plan' : 'plans'}  \u2022  Wallet ${c.symbol}${money(wallet)}',
                              style: const TextStyle(color: Color(0xFFFFE3A3), fontSize: 13)),
                        ],
                      ),
                    ),
                    if (plans.isEmpty)
                      const FinEmpty(
                        icon: Icons.event_available,
                        title: 'No fixed plans yet',
                        sub: 'Start a plan, choose how long to save, and withdraw when it matures.',
                      )
                    else
                      ...plans.map((p) => _planCard(p, wallet)),
                    FinButton(label: 'Start a new plan', icon: Icons.add, busy: _busy, onTap: () => _newPlan(wallet)),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _planCard(Saving p, double wallet) {
    final c = configFor(p.currency);
    final now = DateTime.now();
    final end = p.lockedUntil;
    final start = p.createdAt;
    final matured = end != null && !end.isAfter(now);
    double progress = matured ? 1 : 0;
    if (!matured && end != null && start != null) {
      final total = end.difference(start).inSeconds;
      progress = total <= 0 ? 0 : (now.difference(start).inSeconds / total).clamp(0.0, 1.0);
    }
    final daysLeft = end == null ? 0 : end.difference(now).inDays + 1;
    return FinPanel(
      border: matured ? FT.green.withValues(alpha: 0.7) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${c.symbol}${money(p.balance)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (matured ? FT.green : _gold).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: matured ? FT.green : _gold),
                ),
                child: Text(matured ? 'Matured' : '${p.lockDays ?? ''} days',
                    style: TextStyle(color: matured ? FT.green : _gold, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF16352F),
              valueColor: AlwaysStoppedAnimation<Color>(matured ? FT.green : _gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            end == null
                ? ''
                : matured
                    ? 'Ready to withdraw since ${dateLabel(end)}'
                    : 'Matures ${dateLabel(end)}  \u2022  $daysLeft ${daysLeft == 1 ? 'day' : 'days'} left',
            style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!matured) ...[
                Expanded(child: FinButton(label: 'Add money', icon: Icons.add, outline: true, onTap: () => _add(p, wallet))),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: FinButton(
                  label: matured ? 'Withdraw' : 'Break plan',
                  icon: matured ? Icons.download : Icons.lock_open,
                  outline: !matured,
                  onTap: () => _break(p, matured),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewPlanSheet extends StatefulWidget {
  final CountryConfig ccy;
  final double wallet;
  const _NewPlanSheet({required this.ccy, required this.wallet});

  @override
  State<_NewPlanSheet> createState() => _NewPlanSheetState();
}

class _NewPlanSheetState extends State<_NewPlanSheet> {
  static const _periods = [30, 90, 180, 365];
  final _ctrl = TextEditingController();
  int _days = 90;
  String _error = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() {
    final v = double.tryParse(_ctrl.text.trim());
    final min = minFor(widget.ccy.currencyCode);
    if (v == null || v <= 0) return setState(() => _error = 'Enter an amount');
    if (v < min) return setState(() => _error = 'Minimum is ${widget.ccy.symbol}${money(min, decimals: 0)}');
    if (v > widget.wallet) return setState(() => _error = 'That is more than your wallet balance');
    Navigator.pop(context, {'amount': v, 'days': _days});
  }

  @override
  Widget build(BuildContext context) {
    final matures = DateTime.now().add(Duration(days: _days));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New fixed plan', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Wallet balance: ${widget.ccy.symbol}${money(widget.wallet)}',
                style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
            const SizedBox(height: 14),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: FT.inner, borderRadius: BorderRadius.circular(14), border: Border.all(color: FT.line)),
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
                        hintText: 'Amount to save',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Save for', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
            const SizedBox(height: 8),
            Row(
              children: _periods.map((d) {
                final sel = _days == d;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _days = d),
                    child: Container(
                      height: 46,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: sel ? const Color(0xFFFFB02E).withValues(alpha: 0.15) : FT.inner,
                        border: Border.all(color: sel ? const Color(0xFFFFB02E) : FT.line, width: sel ? 1.6 : 1),
                      ),
                      child: Center(
                        child: Text('$d days',
                            style: TextStyle(
                                color: sel ? const Color(0xFFFFB02E) : Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text('Matures on ${dateLabel(matures)}', style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error, style: const TextStyle(color: Color(0xFFFF5A67), fontSize: 13.5)),
              ),
            const SizedBox(height: 18),
            FinButton(label: 'Start plan', icon: Icons.check, onTap: _start),
          ],
        ),
      ),
    );
  }
}
