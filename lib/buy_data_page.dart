import 'package:flutter/material.dart';

class BuyDataPage extends StatefulWidget {
  const BuyDataPage({super.key});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _Country {
  final String name;
  final String flag;
  final String dial;
  final List<String> networks;
  const _Country(this.name, this.flag, this.dial, this.networks);
}

class _Plan {
  final String size;
  final String validity;
  final int price;
  final int cashback;
  final String? tag; // POPULAR / BEST VALUE
  const _Plan(this.size, this.validity, this.price, this.cashback, {this.tag});
}

class _BuyDataPageState extends State<BuyDataPage> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _panel = Color(0xFF0A1422);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1B2B40);

  static const _countries = [
    _Country('Nigeria', '\u{1F1F3}\u{1F1EC}', '+234', ['MTN', 'Airtel', 'Glo', '9mobile']),
    _Country('Ghana', '\u{1F1EC}\u{1F1ED}', '+233', ['MTN', 'Vodafone', 'AirtelTigo']),
    _Country('Niger', '\u{1F1F3}\u{1F1EA}', '+227', ['Airtel', 'Moov']),
    _Country('Canada', '\u{1F1E8}\u{1F1E6}', '+1', ['Rogers', 'Bell', 'Telus']),
    _Country('USA', '\u{1F1FA}\u{1F1F8}', '+1', ['AT&T', 'T-Mobile', 'Verizon']),
    _Country('England', '\u{1F1EC}\u{1F1E7}', '+44', ['Vodafone', 'EE', 'O2']),
  ];

  static const _tabs = [
    ['Hot', Icons.local_fire_department],
    ['Daily', Icons.calendar_today],
    ['Weekly', Icons.calendar_view_week],
    ['Monthly', Icons.calendar_month],
    ['Night', Icons.nightlight_round],
    ['International', Icons.public],
  ];

  // Sample plans for the UI. Replace with your API plans (e.g. eBills) when you connect it.
  static const Map<String, List<_Plan>> _plans = {
    'Hot': [
      _Plan('1GB', '1 Day', 500, 10, tag: 'POPULAR'),
      _Plan('2.5GB', '2 Days', 750, 15),
      _Plan('5GB', '7 Days', 1000, 20, tag: 'BEST VALUE'),
      _Plan('10GB', '7 Days', 1800, 30),
      _Plan('20GB', '30 Days', 3500, 70),
      _Plan('50GB', '30 Days', 7500, 150),
    ],
    'Daily': [
      _Plan('200MB', '1 Day', 200, 4),
      _Plan('500MB', '1 Day', 350, 7),
      _Plan('1GB', '1 Day', 500, 10, tag: 'POPULAR'),
      _Plan('2GB', '1 Day', 700, 14),
    ],
    'Weekly': [
      _Plan('1.5GB', '7 Days', 600, 12),
      _Plan('5GB', '7 Days', 1000, 20, tag: 'BEST VALUE'),
      _Plan('10GB', '7 Days', 1800, 30),
      _Plan('15GB', '7 Days', 2500, 45),
    ],
    'Monthly': [
      _Plan('10GB', '30 Days', 3000, 60),
      _Plan('20GB', '30 Days', 3500, 70, tag: 'POPULAR'),
      _Plan('36GB', '30 Days', 5500, 110),
      _Plan('50GB', '30 Days', 7500, 150),
    ],
    'Night': [
      _Plan('3GB', 'Night (12am-5am)', 200, 4),
      _Plan('10GB', 'Night (12am-5am)', 500, 10, tag: 'BEST VALUE'),
    ],
    'International': [
      _Plan('1GB', '7 Days', 3000, 60),
      _Plan('3GB', '14 Days', 7000, 140),
      _Plan('5GB', '30 Days', 10000, 200),
    ],
  };

  _Country _country = _countries.first;
  String _network = 'MTN';
  String _tab = 'Hot';
  int _selected = 0;
  final _phone = TextEditingController();

  List<_Plan> get _current => _plans[_tab]!;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Color _netColor(String n) {
    switch (n) {
      case 'MTN':
        return const Color(0xFFFFCC00);
      case 'Airtel':
        return const Color(0xFFE4002B);
      case 'Glo':
        return const Color(0xFF2DAA3F);
      case '9mobile':
        return const Color(0xFF0B6B3A);
      default:
        return const Color(0xFF2A5BD7);
    }
  }

  // ---------- Actions ----------
  Future<void> _pickCountry() async {
    final c = await showModalBottomSheet<_Country>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _countries
            .map((c) => ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(c.name, style: const TextStyle(color: Colors.white)),
                  trailing: Text(c.dial, style: const TextStyle(color: Colors.white54)),
                  onTap: () => Navigator.pop(context, c),
                ))
            .toList(),
      ),
    );
    if (c == null) return;
    setState(() {
      _country = c;
      _network = c.networks.first;
    });
  }

  Future<void> _pickNetwork() async {
    final n = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _country.networks
            .map((n) => ListTile(
                  leading: _badge(n),
                  title: Text(n, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, n),
                ))
            .toList(),
      ),
    );
    if (n != null) setState(() => _network = n);
  }

  Future<void> _continue() async {
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) return _msg('Enter a valid phone number');
    final plan = _current[_selected];

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Confirm purchase', style: TextStyle(color: Colors.white)),
        content: Text(
          '${plan.size} $_network data (${plan.validity})\n\u20a6${_fmt(plan.price)}\nto ${_country.dial} ${_phone.text.trim()}',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (ok == true) _purchase(plan);
  }

  // TODO: connect your existing data purchase logic here.
  // Available: _country, _network, _phone.text, plan.size, plan.price.
  void _purchase(_Plan plan) {
    _msg('Data purchase is not connected yet');
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 12),
                _banner(),
                const SizedBox(height: 10),
                _selectors(),
                const SizedBox(height: 10),
                _phoneCard(),
                const SizedBox(height: 10),
                _tabBar(),
                const SizedBox(height: 10),
                _planGrid(),
                const SizedBox(height: 12),
                _continueButton(),
                const SizedBox(height: 10),
                _supported(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: _panel.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      );

  BoxDecoration _inner() => BoxDecoration(
        color: const Color(0xFF070F1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3C55)),
      );

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF2B8CFF)]),
          ),
          child: const Text('M',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mamash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
              Text('More Than Payments', style: TextStyle(color: Colors.white60, fontSize: 10)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _green.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.public, color: _green, size: 16),
              SizedBox(width: 5),
              Text('Worldwide', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _msg('History coming soon...'),
          child: const Row(
            children: [
              Icon(Icons.history, color: Colors.white, size: 20),
              SizedBox(width: 3),
              Text('History', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF08283A), Color(0xFF0A1B3A), Color(0xFF0B3A7A)]),
        border: Border.all(color: _green.withValues(alpha: 0.45)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -10,
            child: Icon(Icons.public, size: 150, color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
          ),
          Positioned(right: 70, top: 6, child: _orb(Icons.flight)),
          Positioned(right: 0, top: 22, child: _orb(Icons.wifi)),
          Positioned(right: 150, bottom: 14, child: _orb(Icons.public)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Icon(Icons.cell_tower, color: _green, size: 18),
                  SizedBox(width: 6),
                  Text('Global Data', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Stay Connected',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
              const Text('Anywhere',
                  style: TextStyle(color: _green, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: 8),
              const Text('Fast  \u2022  Secure  \u2022  Worldwide',
                  style: TextStyle(color: Color(0xFFB5C4DA), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orb(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A2238),
        border: Border.all(color: _green.withValues(alpha: 0.5)),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _selectors() {
    Widget box(IconData icon, String label, Widget child) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: _card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        box(
          Icons.language,
          'Country / Region',
          GestureDetector(
            onTap: _pickCountry,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: _inner(),
              child: Row(
                children: [
                  Text(_country.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_country.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        box(
          Icons.signal_cellular_alt,
          'Mobile Network',
          GestureDetector(
            onTap: _pickNetwork,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: _inner(),
              child: Row(
                children: [
                  _badge(_network),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_network,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _badge(String n) {
    final dark = n == 'MTN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(color: _netColor(n), borderRadius: BorderRadius.circular(20)),
      child: Text(
        n.length > 6 ? n.substring(0, 3).toUpperCase() : n.toUpperCase(),
        style: TextStyle(
          color: dark ? Colors.black : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _phoneCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Phone Number', style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(width: 6),
              Icon(Icons.info_outline, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: _inner(),
                  child: Row(
                    children: [
                      Text(_country.dial,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 24, color: Colors.white24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0801 234 5678',
                            hintStyle: TextStyle(color: Colors.white30, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _msg('Add contact coming soon...'),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: _green.withValues(alpha: 0.12),
                    border: Border.all(color: _green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.person, color: _green, size: 22),
                      SizedBox(width: 6),
                      Text('Add\nContact', style: TextStyle(color: _green, fontSize: 11, height: 1.2)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _card(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((t) {
            final name = t[0] as String;
            final icon = t[1] as IconData;
            final sel = _tab == name;
            return GestureDetector(
              onTap: () => setState(() {
                _tab = name;
                _selected = 0;
              }),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: sel ? const LinearGradient(colors: [Color(0xFF0E6B4E), Color(0xFF14A877)]) : null,
                  border: sel ? Border.all(color: _green) : null,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: sel ? _green : Colors.white70),
                    const SizedBox(width: 6),
                    Text(name,
                        style: TextStyle(
                            color: sel ? Colors.white : Colors.white70,
                            fontSize: 13,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _planGrid() {
    final plans = _current;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: List.generate(plans.length, (i) => _planCard(plans[i], i)),
    );
  }

  Widget _planCard(_Plan p, int i) {
    final sel = _selected == i;
    return GestureDetector(
      onTap: () => setState(() => _selected = i),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: sel
                ? [const Color(0xFF0C3A38), const Color(0xFF0A2230)]
                : [const Color(0xFF0B1B2E), const Color(0xFF08121F)],
          ),
          border: Border.all(color: sel ? _green : const Color(0xFF1E3350), width: sel ? 1.8 : 1),
          boxShadow: sel ? [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 12)] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF38C8FF), Color(0xFF1D6BFF)],
                ),
              ),
              child: const Icon(Icons.wifi, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(p.size,
                              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      if (p.tag != null) _tag(p.tag!),
                    ],
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(p.validity, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('\u20a6${_fmt(p.price)}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      sel
                          ? const CircleAvatar(
                              radius: 11, backgroundColor: _green, child: Icon(Icons.check, size: 15, color: Colors.black))
                          : Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54)),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: _green, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text('\u20a6${_fmt(p.cashback)} Cashback',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: _green, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String t) {
    final popular = t == 'POPULAR';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: popular ? const Color(0xFF0E6B4E) : const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: popular ? _green : const Color(0xFF5B8DFF)),
      ),
      child: Text(t,
          style: TextStyle(
              color: popular ? _green : Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
    );
  }

  Widget _continueButton() {
    return GestureDetector(
      onTap: _continue,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF3CF08A), Color(0xFF18D5D5)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: Color(0xFF04201A), size: 24),
            SizedBox(width: 8),
            Text('Continue', style: TextStyle(color: Color(0xFF04201A), fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _supported() {
    Widget item(String flag, String name) => Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 6),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
            Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.white24),
          ],
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, color: _green, size: 18),
              SizedBox(width: 8),
              Text('Supported Countries & Networks',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ..._countries.map((c) => item(c.flag, c.name)),
                const Icon(Icons.public, color: _green, size: 22),
                const SizedBox(width: 6),
                const Text('and more...', style: TextStyle(color: Colors.white, fontSize: 11)),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
