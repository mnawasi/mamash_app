import 'package:flutter/material.dart';

/// FinancePage
/// A Flutter page spiritually similar to the OPay "Finance" screen:
/// Savings/Loan tabs, a mint-green total balance card, an available
/// balance breakdown, a quick action row, and a promo banner.
///
/// Drop this file into lib/ and push/route to `const FinancePage()`.
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _bgDark = Color(0xFF111214);
  static const Color _cardDark = Color(0xFF1C1D20);
  static const Color _mint = Color(0xFF2ED9A5);
  static const Color _darkGreen = Color(0xFF13342B);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTabs(),
                const SizedBox(height: 16),
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildPromoBanner(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header: title + settings icon
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Finance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Savings / Loan tabs (with "Hot" badge on Loan)
  // ---------------------------------------------------------------------
  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      labelPadding: const EdgeInsets.only(right: 28),
      tabAlignment: TabAlignment.start,
      labelStyle: const TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
      ),
      tabs: [
        const Tab(text: 'Savings'),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Loan'),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8536B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Hot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Mint balance card + dark green available-balance breakdown
  // ---------------------------------------------------------------------
  Widget _buildBalanceCard() {
    return Column(
      children: [
        // Top mint section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: const BoxDecoration(
            color: _mint,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.remove_red_eye_outlined,
                          color: Colors.black54, size: 16),
                    ],
                  ),
                  const Text(
                    'Interest Credited Today',
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '₦ 4,715',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '.49',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: const [
                      Text(
                        '+₦ 0.09',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: Colors.black54, size: 18),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'Estimate interest ₦51 /month, beats 69% of others',
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black54, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom dark-green breakdown section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: const BoxDecoration(
            color: _darkGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 10),
              _balanceRow('Wallet', '₦ 0.00'),
              const SizedBox(height: 10),
              _balanceRow('OWealth', '₦ 4,309.40', extra: '+₦ 0.09'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white24, height: 1),
              ),
              const Text(
                'Savings',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 10),
              _balanceRow('Targets', '₦ 0.00'),
              const SizedBox(height: 10),
              _balanceRow('SafeBox', '₦ 0.63'),
              const SizedBox(height: 10),
              _balanceRow('Spend & Save', '₦ 405.46'),
              const SizedBox(height: 8),
              const Center(
                child: Icon(Icons.keyboard_arrow_up,
                    color: _accentGreen, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _balanceRow(String label, String amount, {String? extra}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              amount,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (extra != null) ...[
              const SizedBox(width: 10),
              Text(
                extra,
                style: const TextStyle(
                  color: _accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions row (OWealth / Targets / SafeBox / Fixed / Spend & Save)
  // ---------------------------------------------------------------------
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(label: 'OWealth', icon: Icons.waves),
      _QuickAction(label: 'Targets', icon: Icons.track_changes),
      _QuickAction(label: 'SafeBox', icon: Icons.savings_outlined),
      _QuickAction(label: 'Fixed', icon: Icons.lock_outline, badge: 'New'),
      _QuickAction(label: 'Spend & Save', icon: Icons.savings),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => _quickActionTile(a)).toList(),
    );
  }

  Widget _quickActionTile(_QuickAction action) {
    return Expanded(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: _cardDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: _accentGreen, size: 22),
              ),
              if (action.badge != null)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8536B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      action.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Promo banner: "Saving Challenge 2026"
  // ---------------------------------------------------------------------
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B1F), Color(0xFF1B4D3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saving Challenge 2026',
            style: TextStyle(
              color: Color(0xFFF4C15C),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start small daily, finish big in 2026',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4C15C),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'Start Saving Now',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(Icons.verified_outlined, color: Colors.white38, size: 14),
              SizedBox(width: 4),
              Text(
                'Licensed by CBN  •  Insured by the NDIC  •  Powered by OPay MFB',
                style: TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Small data holder
// ---------------------------------------------------------------------
class _QuickAction {
  final String label;
  final IconData icon;
  final String? badge;

  _QuickAction({required this.label, required this.icon, this.badge});
}
