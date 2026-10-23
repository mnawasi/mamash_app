import 'global_wallet_page.dart';
import 'goals_page.dart';
import 'feature_pages.dart';
import 'package:flutter/material.dart';
import '../wallet_page.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _Ccy {
  final String code;
  final String flag;
  final String symbol;
  final double ngnPerUnit; // sample rate
  const _Ccy(this.code, this.flag, this.symbol, this.ngnPerUnit);
}

class _Row {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _Row(this.icon, this.title, this.sub, this.onTap);
}

class _FinancePageState extends State<FinancePage> {
  // Placeholder balances (in the selected currency). Connect to real data.
  static const double _total = 0.00;
  static const double _interestToday = 0.00;
  static const double _mainWallet = 0.00;
  static const double _globalWallet = 0.00;
  static const double _goals = 0.00;
  static const double _safeBox = 0.00;
  static const double _spendSave = 0.00;

  // Sample rates. Replace with live rates.
  static const _currencies = [
    _Ccy('NGN', '\u{1F1F3}\u{1F1EC}', '\u20a6', 1),
    _Ccy('USD', '\u{1F1FA}\u{1F1F8}', '\$', 1450),
    _Ccy('GBP', '\u{1F1EC}\u{1F1E7}', '\u00a3', 1850),
    _Ccy('GHS', '\u{1F1EC}\u{1F1ED}', 'GH\u20b5', 95),
  ];

  static const Color _bg = Color(0xFF020F0C);
  static const Color _green = Color(0xFF2BE0A0);
  static const Color _panel = Color(0xFF07201A);
  static const Color _line = Color(0xFF14543F);

  _Ccy _ccy = _currencies.first;
  bool _hidden = false;

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _num(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final s = parts[0];
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '$b.${parts[1]}';
  }

  String _amt(double v) => _hidden ? '${_ccy.symbol} ****' : '${_ccy.symbol} ${_num(v)}';

  String get _equiv {
    if (_hidden) return '\$**** USD';
    final ngn = _total * _ccy.ngnPerUnit;
    return '\$${_num(ngn / 1450)} USD';
  }

  @override
  Widget build(BuildContext context) {
    final rows = [
      _Row(Icons.account_balance_wallet_outlined, 'Main Wallet', 'Daily spending & transfers', () => _goTo(const WalletPage())),
      _Row(Icons.public, 'Global Wallet', 'Multi-currency \u2022 Worldwide', () => _goTo(const GlobalWalletPage())),
      _Row(Icons.track_changes, 'Goals', 'Save for your dreams', () => _goTo(const GoalsPage())),
      _Row(Icons.lock_outline, 'SafeBox', 'Extra security, higher rewards', () => _goTo(const SafeBoxPage())),
      _Row(Icons.spa_outlined, 'Spend & Save', 'Save automatically', () => _goTo(const SpendSavePage())),
    ];
    final amounts = [_mainWallet, _globalWallet, _goals, _safeBox, _spendSave];

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF063A2C), Color(0xFF020F0C)],
            stops: [0, .45],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 14),
                _currencyChips(),
                const SizedBox(height: 14),
                _tabs(),
                const SizedBox(height: 14),
                _totalCard(),
                const SizedBox(height: 14),
                _balanceList(rows, amounts),
                const SizedBox(height: 16),
                _shortcuts(),
                const SizedBox(height: 16),
                _challenge(),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                  children: [
                    TextSpan(text: 'Mamash '),
                    TextSpan(text: 'Pay', style: TextStyle(color: _green)),
                  ],
                ),
              ),
              const Text('Your money, worldwide', style: TextStyle(color: Color(0xFFB5D4C8), fontSize: 15)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _msg('Settings coming soon...'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _panel,
              border: Border.all(color: _green.withValues(alpha: 0.6)),
            ),
            child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }

  Widget _currencyChips() {
    return Row(
      children: _currencies.map((c) {
        final sel = c == _ccy;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _ccy = c),
            child: Container(
              height: 48,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: sel ? const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF0FA672)]) : null,
                color: sel ? null : _panel,
                border: Border.all(color: sel ? _green : _line),
                boxShadow: sel ? [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 12)] : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  Text(c.code,
                      style: TextStyle(
                          color: sel ? Colors.black : Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _tabs() {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF163A30)))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8, right: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _green, width: 3))),
            child: const Text('Savings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 26),
          GestureDetector(
            onTap: () => _msg('Loans are coming soon'),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text('Loans', style: TextStyle(color: Color(0xFFA9B8B2), fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2E0A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8B83D)),
                    ),
                    child: const Text('Coming soon',
                        style: TextStyle(color: Color(0xFFFFD66B), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalCard() {
    final whole = _hidden ? '${_ccy.symbol} ****' : '${_ccy.symbol} ${_num(_total).split('.')[0]}';
    final dec = _hidden ? '' : '.${_num(_total).split('.')[1]}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF117A57), Color(0xFF0A4A38), Color(0xFF0B5A42)],
        ),
        border: Border.all(color: _green.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.25), blurRadius: 18)],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: 10,
            child: Icon(Icons.public, size: 130, color: _green.withValues(alpha: 0.35)),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Total savings', style: TextStyle(color: Colors.white, fontSize: 17)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _hidden = !_hidden),
                              child: Icon(_hidden ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                              children: [
                                TextSpan(text: whole, style: const TextStyle(fontSize: 46)),
                                TextSpan(text: dec, style: const TextStyle(fontSize: 30)),
                              ],
                            ),
                          ),
                        ),
                        Text(_equiv, style: const TextStyle(color: Color(0xFFD0E8DE), fontSize: 15)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 80, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.white24),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Interest earned today', style: TextStyle(color: Color(0xFFD0E8DE), fontSize: 13)),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(_hidden ? '+${_ccy.symbol} ****' : '+${_ccy.symbol} ${_num(_interestToday)}',
                              style: const TextStyle(color: Color(0xFF5CFFC0), fontSize: 26, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _msg('Projected returns coming soon...'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bar_chart, color: _green, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Projected returns  \u2022  View details',
                            style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceList(List<_Row> rows, List<double> amounts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3A2E), Color(0xFF07201A)],
        ),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(color: Color(0xFFC6DAD2), fontSize: 14)),
          const SizedBox(height: 4),
          ...List.generate(rows.length, (i) {
            final r = rows[i];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: r.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  border: i == rows.length - 1 ? null : const Border(bottom: BorderSide(color: Color(0xFF14403A))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _green.withValues(alpha: 0.1),
                        border: Border.all(color: _green.withValues(alpha: 0.6)),
                      ),
                      child: Icon(r.icon, color: _green, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(r.sub, style: const TextStyle(color: Color(0xFFB5D4C8), fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    Text(_amt(amounts[i]),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right, color: _green, size: 22),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _shortcuts() {
    Widget item(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(colors: [Color(0xFF0E5A45), Color(0xFF07281F)]),
                  border: Border.all(color: _green.withValues(alpha: 0.7), width: 1.4),
                  boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 10)],
                ),
                child: Icon(icon, color: _green, size: 32),
              ),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.2)),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item(Icons.public, 'Global\nWallet', () => _goTo(const GlobalWalletPage())),
        item(Icons.track_changes, 'Goals', () => _goTo(const GoalsPage())),
        item(Icons.lock_outline, 'SafeBox', () => _goTo(const SafeBoxPage())),
        item(Icons.bar_chart, 'Fixed\nSavings', () => _goTo(const FixedSavingsPage())),
        item(Icons.spa_outlined, 'Spend & Save', () => _goTo(const SpendSavePage())),
      ],
    );
  }

  Widget _challenge() {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A2E), Color(0xFF07201A), Color(0xFF0A4A38)]),
        border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -6,
            child: Icon(Icons.public, size: 120, color: _green.withValues(alpha: 0.4)),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Row(
              children: ['\u{1F1F3}\u{1F1EC}|NG', '\u{1F1FA}\u{1F1F8}|US', '\u{1F1EC}\u{1F1E7}|UK', '\u{1F1EC}\u{1F1ED}|GH']
                  .map((s) {
                final p = s.split('|');
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF07201A),
                          border: Border.all(color: _green.withValues(alpha: 0.7)),
                        ),
                        child: Text(p[0], style: const TextStyle(fontSize: 18)),
                      ),
                      Text(p[1], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 26, height: 3, color: const Color(0xFFFFC83D)),
              const SizedBox(height: 8),
              const Text('Global Savings',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
              const Text('Challenge 2026',
                  style: TextStyle(color: Color(0xFFFFC83D), fontSize: 24, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 6),
              const Text('Small steps. Worldwide possibilities.',
                  style: TextStyle(color: Color(0xFFD0E8DE), fontSize: 12.5)),
              const Spacer(),
              GestureDetector(
                onTap: () => _goTo(const GoalsPage()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFFFC83D).withValues(alpha: 0.35), blurRadius: 10)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.track_changes, color: Color(0xFF3A2A00), size: 22),
                      SizedBox(width: 8),
                      Text('Create a savings goal',
                          style: TextStyle(color: Color(0xFF3A2A00), fontSize: 15, fontWeight: FontWeight.w800)),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: Color(0xFF3A2A00), size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
