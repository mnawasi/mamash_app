import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _balanceVisible = true;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, String>> _transactions = [
    {'title': 'Data Purchase', 'subtitle': 'MTN 1GB', 'amount': '-₦500', 'time': 'Today, 10:24 AM', 'type': 'debit'},
    {'title': 'Wallet Funding', 'subtitle': 'Bank Transfer', 'amount': '+₦20,000', 'time': 'Yesterday, 3:12 PM', 'type': 'credit'},
    {'title': 'Airtime Purchase', 'subtitle': 'Airtel ₦200', 'amount': '-₦200', 'time': 'Jul 22, 9:05 AM', 'type': 'debit'},
    {'title': 'Cashback', 'subtitle': 'Data voucher reward', 'amount': '+₦15', 'time': 'Jul 21, 6:40 PM', 'type': 'credit'},
    {'title': 'Electricity Bill', 'subtitle': 'IKEDC Prepaid', 'amount': '-₦5,000', 'time': 'Jul 20, 1:18 PM', 'type': 'debit'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildTransactionsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Wallet',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Wallet balance', style: TextStyle(color: Colors.black87, fontSize: 13)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.black54,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _balanceVisible ? '₦48,320.50' : '₦ ••••••',
            style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.add, 'Add Money'),
          _actionItem(Icons.arrow_upward_rounded, 'Send'),
          _actionItem(Icons.account_balance_wallet_outlined, 'Withdraw'),
          _actionItem(Icons.receipt_long_outlined, 'History'),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF163A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accentGreen, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent transactions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Text('See all', style: TextStyle(color: _accentGreen, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ..._transactions.map((tx) => _transactionTile(tx)),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, String> tx) {
    final bool isCredit = tx['type'] == 'credit';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCredit ? _accentGreen.withOpacity(0.15) : const Color(0xFF3A1212),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? _accentGreen : Colors.redAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(tx['subtitle']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx['amount']!,
                style: TextStyle(
                  color: isCredit ? _accentGreen : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(tx['time']!, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
