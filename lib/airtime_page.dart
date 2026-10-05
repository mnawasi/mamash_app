import 'package:flutter/material.dart';

class AirtimePage extends StatefulWidget {
  const AirtimePage({super.key});

  @override
  State<AirtimePage> createState() => _AirtimePageState();
}

class _Country {
  final String name;
  final String flag;
  final String dial;
  final List<String> networks;
  const _Country(this.name, this.flag, this.dial, this.networks);
}

class _AirtimePageState extends State<AirtimePage> {
  static const Color _bg = Color(0xFF050B14);
  static const Color _panel = Color(0xFF0A1422);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1B2B40);

  // Placeholder rate for the USD hint. Replace with a live rate later.
  static const double _ngnPerUsd = 1450;

  static const _countries = [
    _Country('Nigeria', '\u{1F1F3}\u{1F1EC}', '+234', ['MTN', 'Airtel', 'Glo', '9mobile']),
    _Country('Ghana', '\u{1F1EC}\u{1F1ED}', '+233', ['MTN', 'Vodafone', 'AirtelTigo']),
    _Country('Canada', '\u{1F1E8}\u{1F1E6}', '+1', ['Rogers', 'Bell', 'Telus']),
    _Country('USA', '\u{1F1FA}\u{1F1F8}', '+1', ['AT&T', 'T-Mobile', 'Verizon']),
    _Country('England', '\u{1F1EC}\u{1F1E7}', '+44', ['Vodafone', 'EE', 'O2']),
  ];

  static const _presets = [100, 200, 500, 1000, 2000, 5000, 10000, 20000];

  _Country _country = _countries.first;
  String _network = 'MTN';
  int? _amount;
  final _phone = TextEditingController();

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

  String _usd(int n) => (n / _ngnPerUsd).toStringAsFixed(2);

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
                  leading: _badge(n, small: true),
                  title: Text(n, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, n),
                ))
            .toList(),
      ),
    );
    if (n != null) setState(() => _network = n);
  }

  Future<void> _customAmount() async {
    final ctrl = TextEditingController();
    final v = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Custom amount', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            prefixText: '\u20a6 ',
            prefixStyle: TextStyle(color: Colors.white),
            hintText: 'Enter amount',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text.trim())),
            child: const Text('OK', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (v == null) return;
    if (v < 50) return _msg('Minimum amount is \u20a650');
    setState(() => _amount = v);
  }

  Future<void> _continue() async {
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 7) return _msg('Enter a valid phone number');
    if (_amount == null) return _msg('Select an amount');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Confirm top-up', style: TextStyle(color: Colors.white)),
        content: Text(
          '\u20a6${_fmt(_amount!)} $_network airtime\nto ${_country.dial} ${_phone.text.trim()}\n(${_country.name})',
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
    if (ok == true) _purchase();
  }

  // TODO: connect your existing airtime purchase logic here.
  // Available: _country, _network, _phone.text, _amount.
  void _purchase() {
    _msg('Airtime purchase is not connected yet');
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 14),
                _banner(),
                const SizedBox(height: 12),
                _selectors(),
                const SizedBox(height: 12),
                _amountCard(),
                const SizedBox(height: 12),
                _continueButton(),
                const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      );

  BoxDecoration _inner() => BoxDecoration(
        color: const Color(0xFF070F1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3C55)),
      );

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Airtime', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              Text('Recharge your mobile balance instantly\nanywhere in the world \u{1F30D}',
                  style: TextStyle(color: Color(0xFF9FB3D1), fontSize: 13, height: 1.3)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _green.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.public, color: _green, size: 18),
              SizedBox(width: 6),
              Text('Worldwide', style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF0A2A3A), Color(0xFF0A1B3A), Color(0xFF0B3A7A)]),
        border: Border.all(color: _green.withValues(alpha: 0.35)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -6,
            child: Icon(Icons.public, size: 120, color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt, color: _green, size: 20),
                  SizedBox(width: 6),
                  Text('Global Airtime', style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Top Up Anywhere',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                  children: [
                    TextSpan(text: 'in the ', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'World', style: TextStyle(color: _green)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Fast  \u2022  Secure  \u2022  Reliable',
                  style: TextStyle(color: Color(0xFFB5C4DA), fontSize: 12)),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 230,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF061423).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _green.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: _green, child: Icon(Icons.check, size: 16, color: Colors.black)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Works in 5+ Countries',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('Nigeria, Ghana, Canada, USA, England and more...',
                                style: TextStyle(color: Colors.white70, fontSize: 9)),
                          ],
                        ),
                      ),
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

  Widget _selectors() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label(Icons.language, 'Country / Region'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickCountry,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: _inner(),
                        child: Row(
                          children: [
                            Text(_country.flag, style: const TextStyle(fontSize: 22)),
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
                  ],
                ),
              ),
              Container(width: 1, height: 80, margin: const EdgeInsets.symmetric(horizontal: 10), color: _line),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label(Icons.cell_tower, 'Mobile Network'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickNetwork,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: _inner(),
                        child: Row(
                          children: [
                            _badge(_network, small: true),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
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
                        height: 50,
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
                      onTap: () => _msg('Save contact coming soon...'),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _green.withValues(alpha: 0.12),
                              border: Border.all(color: _green),
                            ),
                            child: const Icon(Icons.person, color: _green),
                          ),
                          const SizedBox(width: 6),
                          const Text('Save\nContact', style: TextStyle(color: _green, fontSize: 11, height: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String n, {bool small = false}) {
    final c = _netColor(n);
    final dark = n == 'MTN';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 12, vertical: small ? 6 : 8),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(20)),
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

  Widget _amountCard() {
    final custom = _amount != null && !_presets.contains(_amount);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.layers, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Select Amount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.3,
            children: _presets.map((a) {
              final sel = _amount == a;
              return GestureDetector(
                onTap: () => setState(() => _amount = a),
                child: Container(
                  decoration: BoxDecoration(
                    color: sel ? _green.withValues(alpha: 0.15) : const Color(0xFF070F1B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: sel ? _green : const Color(0xFF2A3C55), width: sel ? 1.5 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('\u20a6${_fmt(a)}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('~ ${_usd(a)} USD', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _customAmount,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: custom ? _green.withValues(alpha: 0.12) : const Color(0xFF070F1B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: custom ? _green : const Color(0xFF2A3C55)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.dialpad, color: Colors.white70, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      custom ? '\u20a6${_fmt(_amount!)}  (~ ${_usd(_amount!)} USD)' : 'Or enter custom amount',
                      style: TextStyle(color: custom ? Colors.white : Colors.white70, fontSize: 15),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return GestureDetector(
      onTap: _continue,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF3CF08A), Color(0xFF18D5D5)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, color: Color(0xFF04201A), size: 22),
            SizedBox(width: 10),
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

class _Label extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Label(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}
