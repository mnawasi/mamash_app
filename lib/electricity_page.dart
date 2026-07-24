import 'package:flutter/material.dart';

class ElectricityPage extends StatefulWidget {
  const ElectricityPage({super.key});

  @override
  State<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  String _selectedDisco = 'IKEDC';
  String _meterType = 'Prepaid';
  final TextEditingController _meterController =
      TextEditingController(text: '04123456789');
  final TextEditingController _amountController = TextEditingController();

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, String>> _discos = [
    {'name': 'IKEDC', 'icon': 'I', 'color': '0xFF1976D2'},
    {'name': 'EKEDC', 'icon': 'E', 'color': '0xFFD32F2F'},
    {'name': 'AEDC', 'icon': 'A', 'color': '0xFF388E3C'},
  ];

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000, 20000, 50000];

  @override
  void dispose() {
    _meterController.dispose();
    _amountController.dispose();
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
                    _buildDiscoCard(),
                    const SizedBox(height: 16),
                    _buildVoucherRow(),
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
                'Electricity',
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
            'Never Run Out of Light Again',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Pay your electricity bill in seconds',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoCard() {
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
            children: [
              ..._discos.map((d) => _discoTile(d)),
              _moreDiscosTile(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _meterTypeToggle('Prepaid')),
              const SizedBox(width: 10),
              Expanded(child: _meterTypeToggle('Postpaid')),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Meter Number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _meterController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Select Amount', style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _quickAmounts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final amount = _quickAmounts[index];
              return InkWell(
                onTap: () => _amountController.text = amount.toString(),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('₦$amount', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    children: [
                      const Text('₦', style: TextStyle(color: Colors.white54, fontSize: 15)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: '1,000-100,000',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  elevation: 0,
                ),
                child: const Text('Pay', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _discoTile(Map<String, String> disco) {
    final bool selected = disco['name'] == _selectedDisco;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDisco = disco['name']!),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(int.parse(disco['color']!)),
                borderRadius: BorderRadius.circular(12),
                border: selected ? Border.all(color: _accentGreen, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  disco['icon']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              disco['name']!,
              style: TextStyle(
                color: selected ? _accentGreen : Colors.white70,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreDiscosTile() {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white38),
            ),
            child: const Icon(Icons.more_horiz, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          const Text('More', style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _meterTypeToggle(String type) {
    final bool selected = _meterType == type;
    return GestureDetector(
      onTap: () => setState(() => _meterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _accentGreen.withOpacity(0.15) : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: _accentGreen) : null,
        ),
        child: Text(
          type,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? _accentGreen : Colors.white70,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
}
