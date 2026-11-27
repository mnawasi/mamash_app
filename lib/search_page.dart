import 'package:flutter/material.dart';
import 'package:mamash_app/add_money_page.dart';
import 'package:mamash_app/ai/ai_assistant_page.dart';
import 'package:mamash_app/airtime_page.dart';
import 'package:mamash_app/betting_page.dart';
import 'package:mamash_app/bill_payment_page.dart';
import 'package:mamash_app/buy_data_page.dart';
import 'package:mamash_app/convert_page.dart';
import 'package:mamash_app/flight_pay_page.dart';
import 'package:mamash_app/international_transfer_page.dart';
import 'package:mamash_app/notification_page.dart';
import 'package:mamash_app/profile_page.dart';
import 'package:mamash_app/receive_money_page.dart';
import 'package:mamash_app/send_money_page.dart';
import 'package:mamash_app/survey_page.dart';
import 'package:mamash_app/wallet_page.dart';
import 'package:mamash_app/withdraw_page.dart';

class _Item {
  final IconData icon;
  final String title;
  final String subtitle;
  final String keywords;
  final Widget Function() page;
  const _Item(this.icon, this.title, this.subtitle, this.keywords, this.page);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _bg = Color(0xFF040C0B);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  final _ctrl = TextEditingController();

  static final List<_Item> _items = [
    _Item(Icons.send, 'Send Money', 'To anyone, anywhere',
        'send transfer pay money friend family', () => const SendMoneyPage()),
    _Item(Icons.download, 'Receive Money', 'Get money globally',
        'receive account number qr code collect', () => const ReceiveMoneyPage()),
    _Item(Icons.account_balance_wallet, 'Withdraw', 'Cash out at a merchant',
        'withdraw cash out merchant agent atm pos', () => const WithdrawPage()),
    _Item(Icons.add, 'Add Money', 'Top up your wallet',
        'add fund top up deposit load', () => const AddMoneyPage()),
    _Item(Icons.swap_horiz, 'Convert', 'Swap between currencies',
        'convert exchange swap currency rate dollar naira cedi pound',
        () => const ConvertPage()),
    _Item(Icons.flight, 'Flight Pay', 'Book flights worldwide',
        'flight book ticket travel plane airline', () => const FlightPayPage()),
    _Item(Icons.smartphone, 'Airtime', 'Buy airtime instantly',
        'airtime credit recharge phone mtn glo airtel', () => const AirtimePage()),
    _Item(Icons.language, 'Data', 'Buy data for all networks',
        'data bundle internet mb gb network', () => const BuyDataPage()),
    _Item(Icons.sports_esports, 'Betting', 'Play and win',
        'betting bet game sport fund wallet', () => const BettingPage()),
    _Item(Icons.receipt_long, 'Bills', 'Electricity, DSTV, water and more',
        'bills electricity light nepa dstv tv water utility pay',
        () => const BillPaymentPage()),
    _Item(Icons.assignment_turned_in, 'Survey', 'Earn rewards',
        'survey earn reward questions', () => const SurveyPage()),
    _Item(Icons.public, 'International Transfer', 'Send money abroad',
        'international abroad global overseas transfer countries',
        () => const InternationalTransferPage()),
    _Item(Icons.smart_toy, 'Mamash AI', 'Your personal assistant',
        'ai assistant help chat ask gemini', () => const AIAssistantPage()),
    _Item(Icons.account_balance_wallet_outlined, 'Wallet', 'Manage your funds',
        'wallet balance funds history transactions', () => const WalletPage()),
    _Item(Icons.notifications_none, 'Notifications', 'Your alerts',
        'notification alert message inbox', () => const NotificationPage()),
    _Item(Icons.settings_outlined, 'Settings and Profile', 'Account and security',
        'settings profile account personal information security pin password',
        () => const ProfilePage()),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<_Item> get _results {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    final words = q.split(RegExp(r'\s+'));
    return _items.where((i) {
      final hay = '${i.title} ${i.subtitle} ${i.keywords}'.toLowerCase();
      return words.every(hay.contains);
    }).toList();
  }

  void _open(_Item i) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => i.page()));
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
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
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search Mamash Pay',
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white54),
                          suffixIcon: _ctrl.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white54),
                                  onPressed: () =>
                                      setState(() => _ctrl.clear())),
                          filled: true,
                          fillColor: _panel,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: _line)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: _line)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: _green)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text('Nothing found. Try another word.',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: results.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                  _ctrl.text.trim().isEmpty
                                      ? 'Everything in the app'
                                      : '${results.length} result${results.length == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 13)),
                            );
                          }
                          final i = results[index - 1];
                          return GestureDetector(
                            onTap: () => _open(i),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _panel,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: _line),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(i.icon, color: _green),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(i.title,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        Text(i.subtitle,
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.white38),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
