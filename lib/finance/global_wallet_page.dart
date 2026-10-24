import 'package:flutter/material.dart';
import '../country_config.dart';
import '../add_money_page.dart';
import '../convert_page.dart';
import '../international_transfer_page.dart';
import 'finance_common.dart';
import 'savings_common.dart';

class GlobalWalletPage extends StatefulWidget {
  const GlobalWalletPage({super.key});

  @override
  State<GlobalWalletPage> createState() => _GlobalWalletPageState();
}

class _GlobalWalletPageState extends State<GlobalWalletPage> {
  final _wallets = walletStream();
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
    final order = <CountryConfig>[
      mine,
      second,
      ...CountryConfig.all.where((c) => c.currencyCode != mine.currencyCode && c.currencyCode != second.currencyCode),
    ];
    const palettes = [
      [Color(0xFF0E7A57), Color(0xFF0A4A38)],
      [Color(0xFF123A7A), Color(0xFF0A2250)],
      [Color(0xFF5B21B6), Color(0xFF2E1065)],
      [Color(0xFF9A3412), Color(0xFF431407)],
      [Color(0xFF0F766E), Color(0xFF042F2E)],
    ];
    return FinScaffold(
      title: 'Global Wallet',
      subtitle: 'Hold and move money in many currencies',
      children: [
        StreamBuilder<Map<String, double>>(
          stream: _wallets,
          builder: (context, snap) {
            final w = snap.data ?? <String, double>{};
            return Column(
              children: [
                for (int i = 0; i < order.length; i++) _walletCard(order[i], w[order[i].currencyCode] ?? 0, palettes[i % palettes.length]),
              ],
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Text(
            'Adding money and converting work once your payment provider is connected.',
            style: TextStyle(color: Color(0xFF8FB3B0), fontSize: 12.5, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _walletCard(CountryConfig c, double balance, List<Color> colors) {
    final amount = _hidden ? '${c.symbol} ****' : '${c.symbol} ${money(balance)}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        border: Border.all(color: FT.green.withValues(alpha: 0.35)),
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
            child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
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
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
