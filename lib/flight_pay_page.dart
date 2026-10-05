import 'package:flutter/material.dart';

class FlightPayPage extends StatefulWidget {
  const FlightPayPage({super.key});

  @override
  State<FlightPayPage> createState() => _FlightPayPageState();
}

class _FlightPayPageState extends State<FlightPayPage> {
  static const Color _bg = Color(0xFF050A0D);
  static const Color _panel = Color(0xFF0A1A1F);
  static const Color _green = Color(0xFF16C784);

  int _tripType = 0; // 0 one-way, 1 round trip
  String _from = 'Katsina (DKA)';
  String _to = 'Lagos (LOS)';
  DateTime? _depart;
  DateTime? _return;
  int _adults = 1;
  int _children = 0;
  String _cabin = 'Economy';

  static const _cities = [
    'Katsina (DKA)',
    'Kano (KAN)',
    'Kaduna (KAD)',
    'Abuja (ABV)',
    'Lagos (LOS)',
    'Port Harcourt (PHC)',
    'Accra (ACC)',
    'Dubai (DXB)',
    'Jeddah (JED)',
    'London (LHR)',
  ];

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate(bool isReturn) async {
    final now = DateTime.now();
    final first = isReturn ? (_depart ?? now) : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _green, surface: Color(0xFF111214)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isReturn) {
        _return = picked;
      } else {
        _depart = picked;
        if (_return != null && _return!.isBefore(picked)) _return = null;
      }
    });
  }

  Future<void> _pickCity(bool isFrom) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _cities
            .map((c) => ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: _green),
                  title: Text(c, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, c),
                ))
            .toList(),
      ),
    );
    if (choice == null) return;
    setState(() => isFrom ? _from = choice : _to = choice);
  }

  void _swap() => setState(() {
        final t = _from;
        _from = _to;
        _to = t;
      });

  void _search() {
    if (_from == _to) {
      _msg('Origin and destination must be different');
      return;
    }
    if (_depart == null) {
      _msg('Select a departure date');
      return;
    }
    if (_tripType == 1 && _return == null) {
      _msg('Select a return date');
      return;
    }
    _msg('Flight search coming soon...');
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Flight Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(),
            const SizedBox(height: 16),
            _tripToggle(),
            const SizedBox(height: 12),
            _routeCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field('Departure', _fmt(_depart), Icons.calendar_today, () => _pickDate(false))),
                if (_tripType == 1) ...[
                  const SizedBox(width: 10),
                  Expanded(child: _field('Return', _fmt(_return), Icons.event, () => _pickDate(true))),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _passengers(),
            const SizedBox(height: 12),
            _cabinPicker(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: const Text('Search Flights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Why Flight Pay?', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _perk(Icons.public, '200+ Countries', 'Book flights worldwide'),
            _perk(Icons.verified_user, 'Best Rates', 'Pay from your Naira or Dollar wallet'),
            _perk(Icons.bolt, 'Instant Booking', 'Get your ticket in minutes'),
          ],
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A6B), Color(0xFF0A1A2A)]),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.flight, color: Colors.white, size: 46),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Fly Beyond ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  Text('Borders', style: TextStyle(color: _green, fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                SizedBox(height: 4),
                Text('Book flights worldwide with ease.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripToggle() {
    Widget tab(String label, int i) {
      final sel = _tripType == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tripType = i),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _green : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _green.withValues(alpha: 0.25)),
      ),
      child: Row(children: [tab('One way', 0), tab('Round trip', 1)]),
    );
  }

  Widget _routeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _routeItem('From', _from, () => _pickCity(true)),
                const Divider(color: Colors.white12, height: 20),
                _routeItem('To', _to, () => _pickCity(false)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _swap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E2A33),
                border: Border.all(color: _green.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.swap_vert, color: _green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeItem(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _field(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _box(),
        child: Row(
          children: [
            Icon(icon, color: _green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passengers() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _box(),
      child: Column(
        children: [
          _counter('Adults', '12+ years', _adults, 1, (v) => setState(() => _adults = v)),
          const Divider(color: Colors.white12, height: 20),
          _counter('Children', '2-11 years', _children, 0, (v) => setState(() => _children = v)),
        ],
      ),
    );
  }

  Widget _counter(String title, String sub, int value, int min, ValueChanged<int> onChanged) {
    Widget btn(IconData i, VoidCallback? f) => GestureDetector(
          onTap: f,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: f == null ? Colors.white12 : _green),
            ),
            child: Icon(i, size: 16, color: f == null ? Colors.white24 : _green),
          ),
        );
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        btn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
        SizedBox(
          width: 36,
          child: Center(child: Text('$value', style: const TextStyle(color: Colors.white, fontSize: 16))),
        ),
        btn(Icons.add, value < 9 ? () => onChanged(value + 1) : null),
      ],
    );
  }

  Widget _cabinPicker() {
    const cabins = ['Economy', 'Premium', 'Business'];
    return Row(
      children: cabins.map((c) {
        final sel = _cabin == c;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _cabin = c),
            child: Container(
              margin: EdgeInsets.only(right: c == cabins.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? _green.withValues(alpha: 0.15) : _panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? _green : Colors.white12),
              ),
              child: Center(
                child: Text(c,
                    style: TextStyle(
                        color: sel ? _green : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _perk(IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _panel, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
            child: Icon(icon, color: _green, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.25)),
      );
}
