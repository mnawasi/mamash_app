import 'package:flutter/material.dart';
import 'airtime_page.dart';
import 'buy_data_page.dart';
import 'profile_page.dart';
import 'electricity_page.dart';

class BillPaymentPage extends StatefulWidget {
  const BillPaymentPage({super.key});

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _Bill {
  final String title;
  final String sub;
  final IconData icon;
  final List<Color> colors;
  final Color border;
  final VoidCallback onTap;
  const _Bill(this.title, this.sub, this.icon, this.colors, this.border, this.onTap);
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _panel = Color(0xFF0A1422);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1B2B40);

  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  List<_Bill> get _bills => [
        _Bill('Electricity', 'Pay for your PHCN/DisCo bill', Icons.lightbulb,
            const [Color(0xFFFFB23E), Color(0xFFE8590C)], const Color(0xFFE8892E), () => Navigator.push(context, MaterialPageRoute(builder: (_) => ElectricityPage()))),
        _Bill('Airtime', 'Top up all networks instantly', Icons.smartphone,
            const [Color(0xFF45A5FF), Color(0xFF1D5FE8)], const Color(0xFF2E7BE8), () => _goTo(const AirtimePage())),
        _Bill('Data', 'Buy data for all networks', Icons.wifi,
            const [Color(0xFF2BE07A), Color(0xFF0E9F4A)], const Color(0xFF1FB863), () => _goTo(const BuyDataPage())),
        _Bill('Cable TV', 'DSTV, GOTV, Startimes and more', Icons.tv,
            const [Color(0xFFB36BFF), Color(0xFF6D28D9)], const Color(0xFF8B5CF6), () => _msg('Cable TV coming soon...')),
        _Bill('Internet', 'Pay for your internet subscription', Icons.router,
            const [Color(0xFF3FC8FF), Color(0xFF0E8FE0)], const Color(0xFF1E9BD8), () => _msg('Internet coming soon...')),
        _Bill('Water', 'Pay your water bills anytime', Icons.water_drop,
            const [Color(0xFF4A9BFF), Color(0xFF1D4ED8)], const Color(0xFF2E6BE0), () => _msg('Water coming soon...')),
        _Bill('Education', 'School fees & other payments', Icons.school,
            const [Color(0xFFFF6B6B), Color(0xFFD62828)], const Color(0xFFE04848), () => _msg('Education coming soon...')),
        _Bill('Insurance', 'Health, life & other policies', Icons.shield,
            const [Color(0xFF3DDC84), Color(0xFF16A34A)], const Color(0xFF22B866), () => _msg('Insurance coming soon...')),
      ];

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shown = _bills.where((b) => q.isEmpty || b.title.toLowerCase().contains(q) || b.sub.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08203A), Color(0xFF050B14)],
            stops: [0, .35],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 14),
                _banner(),
                const SizedBox(height: 14),
                _searchBar(),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Popular Bills',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: () => _msg('All billers coming soon...'),
                      child: const Row(
                        children: [
                          Text('View All', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w600)),
                          Icon(Icons.chevron_right, color: _green, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                shown.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('No billers found', style: TextStyle(color: Colors.white54))),
                      )
                    : GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.64,
                        children: shown.map(_billTile).toList(),
                      ),
                const SizedBox(height: 14),
                _quickPay(),
                const SizedBox(height: 14),
                _autoPay(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _panel,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(colors: [Color(0xFF2BE0A0), Color(0xFF0E8F70)]),
          ),
          child: const Icon(Icons.receipt_long, color: Color(0xFF04201A), size: 26),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bill Payment', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Pay Bills \u2022 Recharge \u2022 Stay Connected',
                    style: TextStyle(color: Color(0xFFB5C4DA), fontSize: 12)),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _msg('History coming soon...'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _green.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.history, color: _green, size: 22),
                SizedBox(width: 6),
                Text('History', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0A2A3A), Color(0xFF0A1B3A), Color(0xFF0B3A5A)]),
        border: Border.all(color: _green.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.18), blurRadius: 16)],
      ),
      child: Stack(
        children: [
          // illustration
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF123A5E), Color(0xFF0A1B2E)],
                      ),
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.4), blurRadius: 14)],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 20, backgroundColor: _green, child: Icon(Icons.check, color: Colors.black, size: 26)),
                        SizedBox(height: 8),
                        Text('Payment\nSuccessful',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Positioned(left: 0, top: 6, child: _orb(Icons.lightbulb, const [Color(0xFFFFB23E), Color(0xFFE8590C)], 44)),
                  Positioned(left: 4, bottom: 18, child: _orb(Icons.water_drop, const [Color(0xFF4A9BFF), Color(0xFF1D4ED8)], 40)),
                  Positioned(right: 0, top: 0, child: _orb(Icons.wifi, const [Color(0xFF45A5FF), Color(0xFF1D5FE8)], 44)),
                  Positioned(right: -6, top: 62, child: _orb(Icons.tv, const [Color(0xFFB36BFF), Color(0xFF6D28D9)], 40)),
                  Positioned(right: 4, bottom: 8, child: _orb(Icons.shield, const [Color(0xFF3DDC84), Color(0xFF16A34A)], 40)),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _green.withValues(alpha: 0.6)),
                ),
                child: const Text('FAST \u2022 SECURE \u2022 RELIABLE',
                    style: TextStyle(color: Color(0xFFB5E8D8), fontSize: 10, letterSpacing: 1)),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.15, color: Colors.white),
                  children: [
                    TextSpan(text: 'Pay All Your '),
                    TextSpan(text: 'Bills', style: TextStyle(color: _green)),
                    TextSpan(text: '\nin One Place', style: TextStyle(color: _green)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                width: 200,
                child: Text('Electricity, Airtime, Data, Cable TV and more...',
                    style: TextStyle(color: Color(0xFFD0DDE8), fontSize: 11.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orb(IconData icon, List<Color> colors, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.5), blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A4A6A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white70, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for a biller or service...',
                      hintStyle: TextStyle(color: Color(0xFF8C9BB0), fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _msg('Filters coming soon...'),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A4A6A)),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _billTile(_Bill b) {
    return GestureDetector(
      onTap: b.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(7, 8, 5, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [b.border.withValues(alpha: 0.18), const Color(0xFF0A1422)],
          ),
          border: Border.all(color: b.border.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: b.colors),
                    boxShadow: [BoxShadow(color: b.colors.first.withValues(alpha: 0.45), blurRadius: 8)],
                  ),
                  child: Icon(b.icon, color: Colors.white, size: 24),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(b.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(b.sub,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF9FB0C3), fontSize: 8.5, height: 1.25)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickPay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _green.withValues(alpha: 0.12),
              border: Border.all(color: _green.withValues(alpha: 0.6)),
            ),
            child: const Icon(Icons.bolt, color: _green, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Pay', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                Text('Recently used services for faster payments',
                    style: TextStyle(color: Color(0xFF9FB0C3), fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _msg('History coming soon...'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _green.withValues(alpha: 0.6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.history, color: _green, size: 18),
                  SizedBox(width: 4),
                  Text('View History', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700)),
                  Icon(Icons.chevron_right, color: _green, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _autoPay() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF1A2A6E), Color(0xFF2B2A9E), Color(0xFF3B1F8A)]),
        border: Border.all(color: const Color(0xFF6D6DF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [Color(0xFF1D3A8A), Color(0xFF0E1F5A)]),
                  border: Border.all(color: const Color(0xFF5B8DFF)),
                ),
                child: const Center(
                  child: CircleAvatar(radius: 20, backgroundColor: Color(0xFF3B6BFF), child: Icon(Icons.bolt, color: Colors.white, size: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF8E9BFF)),
                      ),
                      child: const Text('Never Miss a Payment', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                    const SizedBox(height: 6),
                    const Text('Set Up AutoPay',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const Text('Save time, avoid late fees, and keep\nyour services active.',
                        style: TextStyle(color: Color(0xFFC9D2F5), fontSize: 11.5)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _msg('AutoPay coming soon...'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B2A9E),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFF8E9BFF)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Setup Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (i) => Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? _green : Colors.white30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    Widget item(IconData icon, String label, bool sel, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? _green : Colors.white60, size: 28),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: sel ? _green : Colors.white60, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  color: sel ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            item(Icons.home_rounded, 'Home', true, () => Navigator.pop(context)),
            item(Icons.receipt_long, 'My Bills', false, () => _msg('My Bills coming soon...')),
            item(Icons.history, 'History', false, () => _msg('History coming soon...')),
            item(Icons.person_outline, 'Profile', false, () => _goTo(const ProfilePage())),
          ],
        ),
      ),
    );
  }
}
