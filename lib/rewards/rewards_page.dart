import 'package:flutter/material.dart';

/// RewardsPage
/// A Flutter page spiritually similar to the OPay "Rewards" screen:
/// dark green header with cashback/voucher summary, a 4-icon quick
/// action row, a tabbed "Hot Vouchers" card, and a "Daily Bonus" list.
///
/// Drop this file into lib/ and push/route to `const RewardsPage()`.
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Colors pulled to roughly match the screenshot's palette.
  static const Color _bgDark = Color(0xFF121212);
  static const Color _headerGreen = Color(0xFF0B3B2E);
  static const Color _accentGreen = Color(0xFF1DBF8A);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _voucherGreen = Color(0xFF1B4438);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildHotVouchersSection(),
              const SizedBox(height: 24),
              _buildDailyBonusSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header: title + cashback / voucher summary cards
  // ---------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rewards',
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
                child: const Icon(Icons.more_horiz, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _cashbackSummary()),
              Expanded(child: _voucherSummary()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cashbackSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Cashback',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(width: 4),
            Icon(Icons.help_outline, color: Colors.white54, size: 14),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber,
              ),
              child: const Center(
                child: Text('₦', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '₦ 30.60',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _voucherSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Voucher',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _accentGreen,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '₦85',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.confirmation_number_outlined,
                color: Colors.white70, size: 20),
            SizedBox(width: 6),
            Text(
              '5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Quick actions row (Friday Bonus / Refer Friends / Play4aChild / Voucher Pack)
  // ---------------------------------------------------------------------
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        label: 'Friday Bonus',
        icon: Icons.calendar_today,
        iconBg: const Color(0xFF16382C),
        iconColor: _accentGreen,
      ),
      _QuickAction(
        label: 'Refer Friends',
        icon: Icons.favorite,
        iconBg: const Color(0xFFF6D9DC),
        iconColor: const Color(0xFFE0507A),
      ),
      _QuickAction(
        label: 'Play4aChild',
        icon: Icons.star,
        iconBg: const Color(0xFF3A2A12),
        iconColor: Colors.amber,
      ),
      _QuickAction(
        label: 'Voucher Pack',
        icon: Icons.card_giftcard,
        iconBg: const Color(0xFF163A2E),
        iconColor: _accentGreen,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) => _quickActionTile(a)).toList(),
      ),
    );
  }

  Widget _quickActionTile(_QuickAction action) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: action.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(action.icon, color: action.iconColor, size: 20),
                ),
              ),
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
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Hot Vouchers: tabbed card (Data / Betting) with voucher rows
  // ---------------------------------------------------------------------
  Widget _buildHotVouchersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Hot Vouchers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.confirmation_number_outlined,
                  color: _accentGreen, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicatorColor: _accentGreen,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: const EdgeInsets.only(right: 24),
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Data'),
                    Tab(text: 'Betting'),
                  ],
                ),
                const SizedBox(height: 16),
                _voucherRow(amount: '₦40', title: 'Data Voucher', sub: '₦3,000 available'),
                const SizedBox(height: 10),
                _voucherRow(amount: '₦10', title: 'Data Voucher', sub: '₦1,000 available'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucherRow({
    required String amount,
    required String title,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _voucherGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Container(width: 1, height: 30, color: Colors.white24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Use', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Daily Bonus: list of bonus offers with a "Go" button each
  // ---------------------------------------------------------------------
  Widget _buildDailyBonusSection() {
    final bonuses = [
      _DailyBonus(
        title: 'Share OPay',
        reward: '+200',
        subtitle: 'Help a loved one get an account and get ₦200 Cashback',
        icon: Icons.people_alt,
        iconBg: Colors.white,
        iconColor: _headerGreen,
      ),
      _DailyBonus(
        title: 'Glo Airtime',
        reward: '+Up to 6%',
        subtitle: 'Buy Airtime and get up to 6% Cashback',
        icon: Icons.phone_android,
        iconBg: const Color(0xFF2A2A2A),
        iconColor: Colors.greenAccent,
      ),
      _DailyBonus(
        title: '9 Mobile Airtime',
        reward: '+Up to 5%',
        subtitle: 'Buy Airtime and get up to 5% Cashback',
        icon: Icons.phone_android,
        iconBg: const Color(0xFF2A2A2A),
        iconColor: Colors.green,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Bonus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: bonuses
                  .map((b) => _dailyBonusTile(b))
                  .expand((w) => [w, const Divider(color: Colors.white12, height: 1)])
                  .toList()
                ..removeLast(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyBonusTile(_DailyBonus bonus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bonus.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(bonus.icon, color: bonus.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bonus.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      bonus.reward,
                      style: const TextStyle(
                        color: _accentGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  bonus.subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentGreen,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Go', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Small data holders
// ---------------------------------------------------------------------
class _QuickAction {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  _QuickAction({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}

class _DailyBonus {
  final String title;
  final String reward;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  _DailyBonus({
    required this.title,
    required this.reward,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}
