import 'package:flutter/material.dart';

class TvSubscriptionPage extends StatefulWidget {
  const TvSubscriptionPage({super.key});

  @override
  State<TvSubscriptionPage> createState() => _TvSubscriptionPageState();
}

class _TvSubscriptionPageState extends State<TvSubscriptionPage> {
  String _selectedProvider = 'DStv';
  final TextEditingController _smartCardController =
      TextEditingController(text: '1234567890');
  String? _selectedPlan;
  String? _resolvedCustomerName;
  bool _isResolving = false;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, String>> _providers = [
    {'name': 'DStv', 'icon': 'D', 'color': '0xFF1565C0'},
    {'name': 'GOtv', 'icon': 'G', 'color': '0xFF2E7D32'},
    {'name': 'Startimes', 'icon': 'S', 'color': '0xFFD32F2F'},
  ];

  final List<Map<String, String>> _plans = [
    {'name': 'Padi', 'price': '₦1,850', 'duration': '1 Month'},
    {'name': 'Yanga', 'price': '₦2,565', 'duration': '1 Month'},
    {'name': 'Confam', 'price': '₦4,615', 'duration': '1 Month'},
    {'name': 'Premium', 'price': '₦29,500', 'duration': '1 Month'},
    {'name': 'Compact', 'price': '₦19,000', 'duration': '1 Month'},
    {'name': 'Compact Plus', 'price': '₦30,000', 'duration': '1 Month'},
  ];

  void _resolveCustomer() {
    setState(() => _isResolving = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isResolving = false;
          _resolvedCustomerName = 'Ibrahim Suleiman';
        });
      }
    });
  }

  @override
  void dispose() {
    _smartCardController.dispose();
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
                    _buildProviderCard(),
                    const SizedBox(height: 16),
                    _buildPlansCard(),
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
                'TV Subscription',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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
            'Never Miss Your Favorite Shows',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Renew your subscription in seconds',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard() {
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
            children: _providers.map((p) => _providerTile(p)).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Smart card / IUC number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _smartCardController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _resolveCustomer,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _accentGreen),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Verify', style: TextStyle(color: _accentGreen)),
            ),
          ),
          if (_isResolving) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: _accentGreen)),
                SizedBox(width: 10),
                Text('Verifying...', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
          if (_resolvedCustomerName != null && !_isResolving) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accentGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: _accentGreen, size: 18),
                  const SizedBox(width: 10),
                  Text(_resolvedCustomerName!, style: const TextStyle(color: _accentGreen, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _providerTile(Map<String, String> provider) {
    final bool selected = provider['name'] == _selectedProvider;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedProvider = provider['name']!;
          _resolvedCustomerName = null;
        }),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(int.parse(provider['color']!)),
                borderRadius: BorderRadius.circular(12),
                border: selected ? Border.all(color: _accentGreen, width: 2) : null,
              ),
              child: Center(
                child: Text(provider['icon']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              provider['name']!,
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

  Widget _buildPlansCard() {
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
          const Text('Select a plan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ..._plans.map((plan) => _planTile(plan)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedPlan == null ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGreen,
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF2A2A2A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile(Map<String, String> plan) {
    final bool selected = plan['name'] == _selectedPlan;
    return InkWell(
      onTap: () => setState(() => _selectedPlan = plan['name']),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _accentGreen.withOpacity(0.12) : const Color(0xFF262626),
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: _accentGreen) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan['name']!, style: TextStyle(color: selected ? _accentGreen : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(plan['duration']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Text(plan['price']!, style: TextStyle(color: selected ? _accentGreen : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            if (selected) ...[
              const SizedBox(width: 10),
              const Icon(Icons.check_circle, color: _accentGreen, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
