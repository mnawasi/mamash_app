import 'package:flutter/material.dart';

class BuyDataPage extends StatefulWidget {
  const BuyDataPage({super.key});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends State<BuyDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedNetwork = 'MTN';
  final TextEditingController _phoneController =
      TextEditingController(text: '0813 7479 520');

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<String> _tabs = ['Hot', 'Extra Night', 'Daily', 'Weekly', 'Monthly'];

  final List<Map<String, String>> _plans = [
    {'size': '1GB', 'days': '1 Day', 'price': '₦500', 'cashback': '₦10 Cashback', 'tag': '1GB+1.5mins'},
    {'size': '2.5GB', 'days': '1 Day', 'price': '₦750', 'cashback': '₦15 Cashback'},
    {'size': '2.5GB', 'days': '2 Days', 'price': '₦900', 'cashback': '₦18 Cashback'},
    {'size': '500MB', 'days': '7 Days', 'price': '₦500', 'cashback': '₦10 Cashback', 'tag': 'Extra Night Data'},
    {'size': '1GB', 'days': '7 Days', 'price': '₦800', 'cashback': '₦16 Cashback'},
    {'size': '3.5GB', 'days': '7 Days', 'price': '₦1,490', 'oldPrice': '₦1,500', 'cashback': '₦30 Cashback', 'discount': 'true'},
    {'size': '7GB', 'days': '30 Days', 'price': '₦3,500', 'cashback': '₦70 Cashback', 'discount': 'true'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
                    _buildPromoBanner(),
                    const SizedBox(height: 16),
                    _buildNetworkSelector(),
                    const SizedBox(height: 12),
                    _buildVoucherRow(),
                    const SizedBox(height: 16),
                    _buildDataPlansSection(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Mobile Data',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text('History', style: TextStyle(color: _accentGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Think Fixed Savings Is Only for Millions?',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Think again. Start with just ₦1,000 today',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Saving Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(_selectedNetwork, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: Colors.white24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
          const Icon(Icons.expand_more, color: Colors.white54),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 14,
            backgroundColor: _accentGreen,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_activity_outlined, color: Colors.purpleAccent),
          const SizedBox(width: 10),
          const Text('Voucher', style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 10),
          const Text('₦40', style: TextStyle(color: Colors.white38, decoration: TextDecoration.lineThrough, fontSize: 12)),
          const SizedBox(width: 6),
          const Text('₦10', style: TextStyle(color: Colors.white38, decoration: TextDecoration.lineThrough, fontSize: 12)),
          const Spacer(),
          Row(
            children: const [
              Text('More', style: TextStyle(color: Colors.white54, fontSize: 13)),
              Icon(Icons.chevron_right, color: Colors.white54, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataPlansSection() {
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
          const Text(
            'Data Plans',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: _accentGreen,
            unselectedLabelColor: Colors.white54,
            indicatorColor: _accentGreen,
            indicatorSize: TabBarIndicatorSize.label,
            labelPadding: const EdgeInsets.only(right: 20),
            tabAlignment: TabAlignment.start,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _plans.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) => _planCard(_plans[index]),
          ),
        ],
      ),
    );
  }

  Widget _planCard(Map<String, String> plan) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF262626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan['size']!,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(plan['days']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 6),
              if (plan['oldPrice'] != null)
                Text(plan['oldPrice']!,
                    style: const TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.lineThrough)),
              Text(plan['price']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(plan['cashback']!, style: const TextStyle(color: _accentGreen, fontSize: 10)),
              if (plan['tag'] != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(plan['tag']!, style: const TextStyle(color: Colors.amber, fontSize: 9)),
                ),
              ],
            ],
          ),
          if (plan['discount'] == 'true')
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.local_offer, color: Colors.redAccent, size: 16),
            ),
        ],
      ),
    );
  }
}
