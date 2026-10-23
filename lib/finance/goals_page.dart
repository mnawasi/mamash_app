import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../country_config.dart';
import 'finance_common.dart';

const Map<String, IconData> _goalIcons = {
  'flight': Icons.flight_takeoff,
  'home': Icons.home_outlined,
  'school': Icons.school_outlined,
  'car': Icons.directions_car_outlined,
  'phone': Icons.smartphone,
  'gift': Icons.card_giftcard,
  'business': Icons.storefront_outlined,
  'health': Icons.favorite_border,
};

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  CountryConfig _country = CountryConfig.all.first;

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('goals');
  }

  @override
  void initState() {
    super.initState();
    financeCountry().then((c) {
      if (mounted) setState(() => _country = c);
    });
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _create() async {
    final col = _col;
    if (col == null) return _msg('Please log in again');
    final data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FT.panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NewGoalSheet(symbol: _country.symbol),
    );
    if (data == null) return;
    try {
      await col.add({
        ...data,
        'saved': 0,
        'currency': _country.currencyCode,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _msg('Goal created');
    } catch (_) {
      _msg('Could not save your goal. Please try again.');
    }
  }

  Future<void> _delete(QueryDocumentSnapshot<Map<String, dynamic>> d) async {
    final saved = (d.data()['saved'] as num?) ?? 0;
    if (saved > 0) return _msg('Withdraw the money from this goal before deleting it');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: FT.panel,
        title: const Text('Delete goal?', style: TextStyle(color: Colors.white)),
        content: Text('"${d.data()['name']}" will be removed.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF5A67))),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await d.reference.delete();
      } catch (_) {
        _msg('Could not delete. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = _col;
    return FinScaffold(
      title: 'Goals',
      subtitle: 'Save for the things that matter',
      accent: const Color(0xFFFF8A3D),
      children: [
        if (col == null)
          const FinEmpty(icon: Icons.lock_outline, title: 'Please log in', sub: 'Log in to see your goals.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: col.orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return const FinEmpty(icon: Icons.error_outline, title: 'Could not load goals', sub: 'Please try again later.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator(color: FT.green)),
                );
              }
              final docs = snap.data!.docs;
              final totalSaved = docs.fold<num>(0, (a, d) => a + ((d.data()['saved'] as num?) ?? 0));
              return Column(
                children: [
                  _summary(docs.length, totalSaved),
                  if (docs.isEmpty)
                    const FinEmpty(
                      icon: Icons.track_changes,
                      title: 'No goals yet',
                      sub: 'Create a goal, set a target and watch your progress.',
                    )
                  else
                    ...docs.map(_goalCard),
                ],
              );
            },
          ),
        FinButton(label: 'Create a goal', icon: Icons.add, onTap: _create),
      ],
    );
  }

  Widget _summary(int count, num saved) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF7A3E0B), Color(0xFF4A2608), Color(0xFF2A1606)]),
        border: Border.all(color: const Color(0xFFFF8A3D).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total saved in goals', style: TextStyle(color: Color(0xFFFFD9B8), fontSize: 13.5)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('${_country.symbol}${money(saved)}',
                      style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text('$count', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              Text(count == 1 ? 'goal' : 'goals', style: const TextStyle(color: Color(0xFFFFD9B8), fontSize: 12.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalCard(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final target = ((m['target'] as num?) ?? 0).toDouble();
    final saved = ((m['saved'] as num?) ?? 0).toDouble();
    final progress = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0);
    final sym = symbolFor(m['currency'] as String?);
    final icon = _goalIcons[m['icon']] ?? Icons.savings_outlined;
    final date = m['targetDate'];
    String? by;
    if (date is Timestamp) {
      const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final t = date.toDate();
      by = 'by ${mo[t.month - 1]} ${t.day}, ${t.year}';
    }
    return FinPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFFF8A3D).withValues(alpha: 0.18),
                ),
                child: Icon(icon, color: const Color(0xFFFF8A3D), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((m['name'] ?? '') as String,
                        style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800)),
                    if (by != null) Text(by, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: FT.panel,
                onSelected: (v) {
                  if (v == 'delete') _delete(d);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete goal', style: TextStyle(color: Colors.white))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFF16352F),
              valueColor: const AlwaysStoppedAnimation<Color>(FT.green),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text('$sym${money(saved)} of $sym${money(target)}',
                    style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
              ),
              Text('${(progress * 100).round()}%',
                  style: const TextStyle(color: FT.green, fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          FinButton(label: 'Add money', icon: Icons.add, outline: true, onTap: () => _msg('Adding money to goals is coming soon')),
        ],
      ),
    );
  }
}

class _NewGoalSheet extends StatefulWidget {
  final String symbol;
  const _NewGoalSheet({required this.symbol});

  @override
  State<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends State<_NewGoalSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  String _icon = 'flight';
  DateTime? _date;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: FT.green)),
        child: child!,
      ),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    final name = _name.text.trim();
    final target = int.tryParse(_amount.text.trim()) ?? 0;
    if (name.length < 2) return setState(() => _error = 'Give your goal a name');
    if (target <= 0) return setState(() => _error = 'Enter a target amount');
    Navigator.pop(context, {
      'name': name,
      'target': target,
      'icon': _icon,
      if (_date != null) 'targetDate': Timestamp.fromDate(_date!),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New goal', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _box(TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              cursorColor: FT.green,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _dec('Goal name (for example, New phone)'),
            )),
            const SizedBox(height: 10),
            _box(Row(
              children: [
                Text(widget.symbol, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _amount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    cursorColor: FT.green,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: _dec('Target amount'),
                  ),
                ),
              ],
            )),
            const SizedBox(height: 14),
            const Text('Choose an icon', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _goalIcons.entries.map((e) {
                final sel = _icon == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _icon = e.key),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: sel ? FT.green.withValues(alpha: 0.18) : FT.inner,
                      border: Border.all(color: sel ? FT.green : FT.line, width: sel ? 1.6 : 1),
                    ),
                    child: Icon(e.value, color: sel ? FT.green : Colors.white70),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: _box(Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white54, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _date == null ? 'Target date (optional)' : '${_date!.day}/${_date!.month}/${_date!.year}',
                      style: TextStyle(color: _date == null ? Colors.white38 : Colors.white, fontSize: 15.5),
                    ),
                  ),
                  if (_date != null)
                    GestureDetector(
                      onTap: () => setState(() => _date = null),
                      child: const Icon(Icons.close, color: Colors.white54, size: 20),
                    ),
                ],
              )),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error, style: const TextStyle(color: Color(0xFFFF5A67), fontSize: 13.5)),
              ),
            const SizedBox(height: 18),
            FinButton(label: 'Save goal', icon: Icons.check, onTap: _save),
          ],
        ),
      ),
    );
  }

  Widget _box(Widget child) => Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: FT.inner,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FT.line),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 15),
      );
}
