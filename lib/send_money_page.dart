import 'package:flutter/material.dart';
import 'transfer_mamash_page.dart';
import 'transfer_bank_page.dart';

class SendMoneyPage extends StatelessWidget {
  const SendMoneyPage({super.key});

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRecentRecipients(),
                    const SizedBox(height: 16),
                    _buildOptionsCard(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Send Money',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecipients() {
    final recents = [
      {'initials': 'AY', 'name': 'Amina'},
      {'initials': 'CO', 'name': 'Chidi'},
      {'initials': 'FB', 'name': 'Fatima'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Recent', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recents.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final r = recents[index];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _accentGreen.withOpacity(0.15),
                      child: Text(r['initials']!, style: const TextStyle(color: _accentGreen, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    Text(r['name']!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context) {
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
          const Text('Send via', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          _optionTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            iconBg: const Color(0xFF163A2E),
            iconColor: _accentGreen,
            title: 'To Mamash user',
            subtitle: 'Send instantly to another Mamash wallet',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferMamashPage())),
          ),
          const SizedBox(height: 10),
          _optionTile(
            context,
            icon: Icons.account_balance_outlined,
            iconBg: const Color(0xFF16232E),
            iconColor: Colors.lightBlueAccent,
            title: 'To bank account',
            subtitle: 'Transfer to any Nigerian bank',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferBankPage())),
          ),
          const SizedBox(height: 10),
          _optionTile(
            context,
            icon: Icons.qr_code_scanner,
            iconBg: const Color(0xFF2E1636),
            iconColor: Colors.purpleAccent,
            title: 'Scan QR code',
            subtitle: 'Scan to send to a merchant or contact',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
