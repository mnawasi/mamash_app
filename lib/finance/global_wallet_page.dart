import 'package:flutter/material.dart';
import '../country_config.dart';
import '../add_money_page.dart';
import '../convert_page.dart';
import '../international_transfer_page.dart';
import 'finance_common.dart';

class GlobalWalletPage extends StatefulWidget {
  const GlobalWalletPage({super.key});

  @override
  State<GlobalWalletPage> createState() => _GlobalWalletPageState();
}

class _GlobalWalletPageState extends State<GlobalWalletPage> {
  // Placeholder balances. Connect these to your real wallet data.
  static const double _balance = 0.00;

  CountryConfig _country = CountryConfig.all.first;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    financeCountry().then((c) {
      if (mounted) setState(() => _country = c);
    });
  }

  void _go(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final mine = _country;
    final second = CountryConfig.secondaryFor(mine);
    final others = CountryConfig.all.where((c) => c.currencyCode != mine.currencyCode && c.currencyCode != second.currencyCode).toList();
    return FinScaffold(
      title: 'Global Wallet',
      subtitle: 'Hold and move money in many currencies',
      children: [
        _walletCard(mine, const [Color(0xFF0E7A57), Color(0xFF0A4A38)]),
        _walletCard(second, const [Color(0xFF123A7A), Color(0xFF0A2250)]),
        const SizedBox(height: 4),
        const Text('More currencies', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        ...others.map((c) => FinPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(c.flag, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.currencyName} wallet', style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                        Text(c.currencyCode, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A2E0A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8B83D)),
                    ),
                    child: const Text('Coming soon', style: TextStyle(color: Color(0xFFFFD66B), fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _walletCard(CountryConfig c, List<Color> colors) {
    final amount = _hidden ? '${c.symbol} ****' : '${c.symbol} ${money(_balance)}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        border: Border.all(color: FT.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c.flag, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 10),
              Expanded(
                child: Text('${c.currencyName} Wallet',
                    style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(_hidden ? Icons.visibility_off : Icons.visibility, color: Colors.white70, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _action(Icons.add, 'Add money', () => _go(const AddMoneyPage())),
              const SizedBox(width: 10),
              _action(Icons.swap_horiz, 'Convert', () => _go(const ConvertPage())),
              const SizedBox(width: 10),
              _action(Icons.send, 'Send', () => _go(const InternationalTransferPage())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
