import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'wallet_page.dart';
import 'transaction_history_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  bool _balanceVisible = false;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _headerGreen = Color(0xFF0B3B2E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSafetyTipsBanner(),
              const SizedBox(height: 16),
              _buildAccountGroup(context),
              const SizedBox(height: 16),
              _buildSupportGroup(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: _headerGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF262626),
                  child: Icon(Icons.person, color: Colors.white38, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hi, there', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.workspace_premium, color: Colors.amber, size: 12),
                          SizedBox(width: 4),
                          Text('Tier 1', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Total balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                          child: Icon(
                            _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _balanceVisible ? '₦48,320.50' : '****',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Interest credited today ${_balanceVisible ? '₦2.10' : '****'}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentGreen.withOpacity(0.15),
                  border: Border.all(color: _accentGreen.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.shield, color: _accentGreen, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentGreen.withOpacity(0.9), _accentGreen.withOpacity(0.6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('5 Safety Tips', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700)),
                SizedBox(height: 2),
                Text('Make your account more secure.', style: TextStyle(color: Colors.black87, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountGroup(BuildContext context) {
    return _menuGroup([
      _menuItem(
        icon: Icons.receipt_long_outlined,
        title: 'Transaction History',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryPage())),
      ),
      _menuItem(
        icon: Icons.speed_outlined,
        title: 'Account Limits',
        subtitle: 'View your transaction limits',
        onTap: () {},
      ),
      _menuItem(
        icon: Icons.credit_card,
        title: 'Bank Card / Account',
        subtitle: 'Add payment option',
        onTap: () {},
      ),
      _menuItem(
        icon: Icons.storefront_outlined,
        title: 'My BizPayment',
        subtitle: 'Receive payment for business',
        badge: 'Fast TFR',
        onTap: () {},
      ),
      _menuItem(
        icon: Icons.family_restroom_outlined,
        title: 'Junior Account',
        subtitle: 'Create an account for your child/ward',
        onTap: () {},
      ),
      _menuItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'EaseMonit',
        subtitle: 'Buy Now Pay Later',
        badge: 'Enjoy ₦0',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage())),
      ),
    ]);
  }

  Widget _buildSupportGroup() {
    return _menuGroup([
      _menuItem(icon: Icons.shield_outlined, title: 'Security Center', subtitle: 'Protect your funds', onTap: () {}),
      _menuItem(icon: Icons.support_agent_outlined, title: 'Customer Service Center', onTap: () {}),
      _menuItem(icon: Icons.celebration_outlined, title: 'Invitation', subtitle: 'Invite friends and earn up to ₦6,300 Bonus', onTap: () {}),
      _menuItem(icon: Icons.dialpad_outlined, title: 'Mamash USSD', onTap: () {}),
      _menuItem(icon: Icons.star_border_rounded, title: 'Rate Us', onTap: () {}),
    ]);
  }

  Widget _menuGroup(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF163A2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _accentGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }
}
