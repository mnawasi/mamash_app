import 'package:flutter/material.dart';
import 'add_money_page.dart';
import 'send_money_page.dart';
import 'transaction_history_page.dart';
import 'notification_page.dart';
import 'bill_payment_page.dart';
import 'profile_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Placeholder balances. Connect these to your real wallet data.
  static const double _ngn = 0.00;
  static const double _usd = 0.00;
  static const double _locked = 0.00;
  static const double _inTransit = 0.00;

  // Sample rate for the "approximately" lines. Replace with a live rate.
  static const double _ngnPerUsd = 1450;

  static const Color _bg = Color(0xFF040E16);
  static const Color _panel = Color(0xFF0A1A24);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF16424A);

  static const _ngFlag = '\u{1F1F3}\u{1F1EC}';
  static const _usFlag = '\u{1F1FA}\u{1F1F8}';

  bool _hidden = false;

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String _money(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final s = parts[0];
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '$b.${parts[1]}';
  }

  String _n(double v) => _hidden ? '\u20a6****' : '\u20a6${_money(v)}';
  String _d(double v) => _hidden ? '\$****' : '\$${_money(v)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07302C), Color(0xFF040E16)],
            stops: [0, .4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 14),
                _balanceCard(),
                const SizedBox(height: 14),
                _actions(),
                const SizedBox(height: 14),
                _quickCurrency(),
                const SizedBox(height: 14),
                _recent(),
                const SizedBox(height: 14),
                _banner(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  BoxDecoration _card({Color? border}) => BoxDecoration(
        color: _panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border ?? _line),
      );

  // ---------- Header ----------
  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Container(
          width: 52,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [Color(0xFF2BE0A0), Color(0xFF0E8F70)]),
            boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 12)],
          ),
          child: const Icon(Icons.account_balance_wallet, color: Color(0xFF04201A), size: 30),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wallet', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Your money \u2022 Your freedom',
                    style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _goTo(const NotificationPage()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _panel,
                  border: Border.all(color: _green.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(color: Color(0xFFFF3B4D), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _msg('Region options coming soon...'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _green.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.public, color: _green, size: 20),
                SizedBox(width: 6),
                Text('Global', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Balance ----------
  Widget _balanceCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A33), Color(0xFF0A2230), Color(0xFF0B2A3F)]),
        border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 16)],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: 20,
            child: Icon(Icons.public, size: 190, color: _green.withValues(alpha: 0.22)),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Total Balance',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _hidden = !_hidden),
                          child: Icon(_hidden ? Icons.visibility_off : Icons.visibility, color: _green, size: 22),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF06141C).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _green.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.public, color: _green, size: 15),
                              SizedBox(width: 5),
                              Text('Worldwide', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _currencyBox(
                            flag: _ngFlag,
                            code: 'NGN',
                            amount: _n(_ngn),
                            approx: '\u2248 ${_d(_ngn / _ngnPerUsd)}',
                            colors: const [Color(0xFF0E4A3A), Color(0xFF0A2A2A)],
                            border: _green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _currencyBox(
                            flag: _usFlag,
                            code: 'USD',
                            amount: _d(_usd),
                            approx: '\u2248 ${_n(_usd * _ngnPerUsd)}',
                            colors: const [Color(0xFF123A7A), Color(0xFF0A2250)],
                            border: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: _green.withValues(alpha: 0.25)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: _stat(Icons.account_balance_wallet, 'Available', _ngn)),
                    Container(width: 1, height: 44, color: Colors.white12),
                    Expanded(child: _stat(Icons.lock, 'Locked', _locked)),
                    Container(width: 1, height: 44, color: Colors.white12),
                    Expanded(child: _stat(Icons.account_balance, 'In Transit', _inTransit)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyBox({
    required String flag,
    required String code,
    required String amount,
    required String approx,
    required List<Color> colors,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        border: Border.all(color: border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(4, 3, 12, 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(code, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(approx, style: const TextStyle(color: Color(0xFFC6DAD6), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String label, double ngn) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _green.withValues(alpha: 0.12),
            border: Border.all(color: _green.withValues(alpha: 0.6)),
          ),
          child: Icon(icon, color: _green, size: 22),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12)),
                Text(_n(ngn), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                Text(_d(ngn / _ngnPerUsd), style: const TextStyle(color: Color(0xFF8FB3B0), fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Actions ----------
  Widget _actions() {
    return Row(
      children: [
        _actionTile(Icons.add, 'Add Money', 'Fund your wallet', const Color(0xFF22C55E),
            const [Color(0xFF3DE08A), Color(0xFF16A34A)], true, () => _goTo(const AddMoneyPage())),
        const SizedBox(width: 8),
        _actionTile(Icons.send, 'Send', 'Transfer to anyone', const Color(0xFF3B82F6),
            const [Color(0xFF3B9BFF), Color(0xFF1D5FE8)], false, () => _goTo(const SendMoneyPage())),
        const SizedBox(width: 8),
        _actionTile(Icons.atm, 'Withdraw', 'Cash out to bank', const Color(0xFF8B5CF6),
            const [Color(0xFFB36BFF), Color(0xFF6D28D9)], true, () => _msg('Withdraw coming soon...')),
        const SizedBox(width: 8),
        _actionTile(Icons.receipt_long, 'History', 'View all transactions', const Color(0xFFF59E0B),
            const [Color(0xFFFFB23E), Color(0xFFE8890C)], false, () => _goTo(const TransactionHistoryPage())),
      ],
    );
  }

  Widget _actionTile(IconData icon, String title, String sub, Color border, List<Color> colors, bool chevron, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [border.withValues(alpha: 0.25), const Color(0xFF0A1A24)],
            ),
            border: Border.all(color: border.withValues(alpha: 0.85)),
          ),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                  boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 10)],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    if (chevron) Icon(Icons.chevron_right, color: border, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(sub, style: const TextStyle(color: Color(0xFFB0C4D0), fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Quick currency ----------
  Widget _quickCurrency() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: _green.withValues(alpha: 0.15),
                  border: Border.all(color: _green.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.sync, color: _green, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Quick Currency Access',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => _msg('Manage currencies coming soon...'),
                child: const Row(
                  children: [
                    Text('Manage Currencies', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, color: _green, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _currencyRow(_ngFlag, 'Nigerian Naira (NGN)', _n(_ngn), _green,
                    const [Color(0xFF0E4A3A), Color(0xFF0A2A2A)]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _currencyRow(_usFlag, 'US Dollar (USD)', _d(_usd), const Color(0xFF3B82F6),
                    const [Color(0xFF123A7A), Color(0xFF0A2250)]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyRow(String flag, String label, String amount, Color border, List<Color> colors) {
    return GestureDetector(
      onTap: () => _msg('$label wallet coming soon...'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: colors),
          border: Border.all(color: border.withValues(alpha: 0.85)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: const TextStyle(color: Color(0xFFC6DAD6), fontSize: 11)),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: border, size: 22),
          ],
        ),
      ),
    );
  }

  // ---------- Recent transactions ----------
  Widget _recent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  color: _green.withValues(alpha: 0.15),
                  border: Border.all(color: _green.withValues(alpha: 0.6)),
                ),
                child: const Icon(Icons.receipt_long, color: _green, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Recent Transactions',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => _goTo(const TransactionHistoryPage()),
                child: const Row(
                  children: [
                    Text('See all', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right, color: _green, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 90,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 62,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: _green.withValues(alpha: 0.12),
                    border: Border.all(color: _green, width: 1.6),
                  ),
                  child: const Icon(Icons.receipt_long, color: _green, size: 36),
                ),
                const Positioned(
                  right: 6,
                  bottom: 4,
                  child: CircleAvatar(radius: 14, backgroundColor: Color(0xFF14A877), child: Icon(Icons.schedule, color: Colors.white, size: 18)),
                ),
                const Positioned(left: 0, top: 4, child: Icon(Icons.auto_awesome, color: _green, size: 16)),
                const Positioned(right: 0, top: 0, child: Icon(Icons.auto_awesome, color: Color(0xFF7FE3C0), size: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('No transactions yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Your transactions will appear here once you start\nusing your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6FB0D8), fontSize: 12.5, height: 1.3)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------- Banner ----------
  Widget _banner() {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF0A2A3A), Color(0xFF0A2238), Color(0xFF0B3A4A)]),
        border: Border.all(color: _green.withValues(alpha: 0.45)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 6,
            top: -4,
            bottom: -4,
            child: SizedBox(
              width: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(colors: [Color(0xFF123A5E), Color(0xFF0A1B2E)]),
                      border: Border.all(color: _green, width: 1.4),
                      boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.5), blurRadius: 14)],
                    ),
                    child: const Center(
                      child: Text('M',
                          style: TextStyle(color: _green, fontSize: 34, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                    ),
                  ),
                  const Positioned(left: 0, top: 6, child: Text(_usFlag, style: TextStyle(fontSize: 24))),
                  const Positioned(right: 0, top: 4, child: Text(_ngFlag, style: TextStyle(fontSize: 22))),
                  const Positioned(
                    left: 6,
                    bottom: 8,
                    child: CircleAvatar(radius: 15, backgroundColor: Color(0xFFFFB02E), child: Text('\$', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
                  ),
                  const Positioned(
                    right: 2,
                    bottom: 4,
                    child: CircleAvatar(radius: 15, backgroundColor: Color(0xFFFFB02E), child: Text('\u20a6', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: _green.withValues(alpha: 0.15),
                      border: Border.all(color: _green.withValues(alpha: 0.6)),
                    ),
                    child: const Icon(Icons.bolt, color: _green, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text('Super Fast. Super Secure.',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const SizedBox(
                width: 210,
                child: Text('Enjoy instant transfers, low fees and global access.',
                    style: TextStyle(color: Color(0xFFC6DAD6), fontSize: 10.5)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _msg('Features coming soon...'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 10)],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Explore Features', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w800)),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right, color: Colors.black, size: 18),
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

  // ---------- Bottom bar ----------
  Widget _bottomBar() {
    Widget item(IconData icon, String label, bool sel, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? _green : Colors.white70, size: 28),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: sel ? _green : Colors.white70, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  color: sel ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _green.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            item(Icons.home_rounded, 'Home', true, () => Navigator.pop(context)),
            item(Icons.receipt_long, 'My Bills', false, () => _goTo(const BillPaymentPage())),
            item(Icons.history, 'History', false, () => _goTo(const TransactionHistoryPage())),
            item(Icons.person_outline, 'Profile', false, () => _goTo(const ProfilePage())),
          ],
        ),
      ),
    );
  }
}
