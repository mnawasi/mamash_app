import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rewards/rewards_page.dart';

import 'send_money_page.dart';
import 'receive_money_page.dart';
import 'add_money_page.dart';
import 'airtime_page.dart';
import 'buy_data_page.dart';
import 'bill_payment_page.dart';
import 'betting_page.dart';
import 'survey_page.dart';
import 'international_transfer_page.dart';
import 'ai/ai_assistant_page.dart';
import 'transaction_history_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'wallet_page.dart';
import 'cards/cards_page.dart';
import 'finance_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const double _walletBalance = 0.00;

  bool _balanceHidden = false;
  int _selectedNavIndex = 0;
  String _accountNumber = '';

  static const Color _bgColor = Color(0xFF111214);
  static const Color _cardColor = Color(0xFF1C1D20);
  static const Color _accent = Color(0xFF16C784);

  @override
  void initState() {
    super.initState();
    _loadAccountNumber();
  }

  Future<void> _loadAccountNumber() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _accountNumber = doc.data()?['accountNumber'] ?? '';
      });
    }
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: _accent,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              "Hi, Mamash",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _goTo(const NotificationPage()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Available balance",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _balanceHidden = !_balanceHidden;
                              });
                            },
                            child: Icon(
                              _balanceHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _goTo(const TransactionHistoryPage()),
                        child: const Row(
                          children: [
                            Text(
                              "History",
                              style: TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _balanceHidden
                        ? "\u20a6 ****"
                        : "\u20a6${_walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Account No: $_accountNumber",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickAction(
                        Icons.send,
                        "Send",
                        () => _goTo(const SendMoneyPage()),
                      ),
                      _quickAction(
                        Icons.call_received,
                        "Receive",
                        () => _goTo(const ReceiveMoneyPage()),
                      ),
                      _quickAction(
                        Icons.arrow_downward,
                        "Withdraw",
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Withdraw coming soon...")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _goTo(const AddMoneyPage()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: _accent, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Add money to your wallet",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Quick services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 18,
              children: [
                _serviceTile(Icons.phone_android, "Airtime", () => _goTo(const AirtimePage())),
                _serviceTile(Icons.wifi, "Data", () => _goTo(const BuyDataPage())),
                _serviceTile(Icons.sports_esports, "Betting", () => _goTo(const BettingPage())),
                _serviceTile(Icons.lightbulb, "Bills", () => _goTo(const BillPaymentPage())),
                _serviceTile(Icons.assignment, "Survey", () => _goTo(const SurveyPage())),
                _serviceTile(Icons.public, "Transfer", () => _goTo(const InternationalTransferPage())),
                _serviceTile(Icons.smart_toy, "Mamash AI", () => _goTo(const AIAssistantPage())),
                _serviceTile(Icons.account_balance_wallet, "Wallet", () => _goTo(const WalletPage())),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });

          if (index == 1) {
            _goTo(const RewardsPage());
          } else if (index == 2) {
            _goTo(const FinancePage());
          } else if (index == 3) {
            _goTo(const CardsPage());
          } else if (index == 4) {
            _goTo(const ProfilePage());
          }
        },
        backgroundColor: _bgColor,
        selectedItemColor: _accent,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard_outlined), label: "Rewards"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Finance"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: "Cards"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Me"),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _serviceTile(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _accent, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
