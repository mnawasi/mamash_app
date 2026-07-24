import 'package:flutter/material.dart';
import 'electricity_page.dart';
import 'airtime_page.dart';
import 'buy_data_page.dart';

class BillPaymentPage extends StatelessWidget {
  const BillPaymentPage({super.key});

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  Widget build(BuildContext context) {
    final bills = [
      _BillCategory('Electricity', Icons.lightbulb_outline, const Color(0xFF3A2A12), Colors.amber,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricityPage()))),
      _BillCategory('Airtime', Icons.phone_android, const Color(0xFF16382C), _accentGreen,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AirtimePage()))),
      _BillCategory('Data', Icons.wifi, const Color(0xFF16382C), _accentGreen,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyDataPage()))),
      _BillCategory('Cable TV', Icons.tv, const Color(0xFF2A1230), Colors.purpleAccent, () {}),
      _BillCategory('Internet', Icons.router_outlined, const Color(0xFF122A3A), Colors.lightBlueAccent, () {}),
      _BillCategory('Water', Icons.water_drop_outlined, const Color(0xFF122A3A), Colors.blueAccent, () {}),
      _BillCategory('Education', Icons.school_outlined, const Color(0xFF3A1212), Colors.redAccent, () {}),
      _BillCategory('Insurance', Icons.shield_outlined, const Color(0xFF163A2E), _accentGreen, () {}),
    ];

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
                    _buildPromoBanner(),
                    const SizedBox(height: 16),
                    _buildVoucherRow(),
                    const SizedBox(height: 16),
                    _buildCategoriesGrid(bills),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Bill Payment',
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
        children: const [
          Text(
            'Pay All Your Bills in One Place',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Fast, secure, and reliable — every time',
            style: TextStyle(color: Colors.black54, fontSize: 12),
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

  Widget _buildCategoriesGrid(List<_BillCategory> bills) {
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
            'All Bills',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bills.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) => _categoryTile(bills[index]),
          ),
        ],
      ),
    );
  }

  Widget _categoryTile(_BillCategory bill) {
    return GestureDetector(
      onTap: bill.onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bill.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(bill.icon, color: bill.iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            bill.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _BillCategory {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  _BillCategory(this.label, this.icon, this.iconBg, this.iconColor, this.onTap);
}
