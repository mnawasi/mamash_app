import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'country_config.dart';

class SendTheme {
  static const Color bg = Color(0xFF050B14);
  static const Color panel = Color(0xFF0A1422);
  static const Color inner = Color(0xFF070F1B);
  static const Color line = Color(0xFF1B2B40);
  static const Color innerLine = Color(0xFF2A3C55);
  static const Color green = Color(0xFF1FE5A0);
}

Future<CountryConfig> loadUserCountry() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return CountryConfig.all.first;
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return CountryConfig.fromName(doc.data()?['country'] as String?);
  } catch (_) {
    return CountryConfig.all.first;
  }
}

String fmtNumber(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// Quick amounts in each country's own currency (SAMPLE values, edit freely).
List<int> amountPresets(CountryConfig c) {
  switch (c.name) {
    case 'Nigeria':
      return [500, 1000, 2000, 5000, 10000, 20000, 50000, 100000];
    case 'Ghana':
    case 'England':
      return [10, 20, 50, 100, 200, 500];
    default:
      return [20, 50, 100, 200, 500, 1000];
  }
}

int minAmount(CountryConfig c) => c.name == 'Nigeria' ? 100 : 1;

class SendShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const SendShell({super.key, required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SendTheme.bg,
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                          Text(subtitle, style: const TextStyle(color: Color(0xFF9FB3D1), fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SendBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const SendBanner({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF0A2A3A), Color(0xFF0A1B3A), Color(0xFF0B3A7A)]),
        border: Border.all(color: SendTheme.green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)]),
            ),
            child: Icon(icon, color: const Color(0xFF04201A), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFFC6D2EA), fontSize: 12.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SendPanel extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Widget child;
  const SendPanel({super.key, this.title, this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SendTheme.panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SendTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                Text(title!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class SendField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final Widget? prefix;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  const SendField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.prefix,
    this.keyboard,
    this.formatters,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: SendTheme.inner,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SendTheme.innerLine),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: const Color(0xFF9FB0D0), size: 22), const SizedBox(width: 10)],
          if (prefix != null) ...[prefix!, const SizedBox(width: 8)],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              inputFormatters: formatters,
              maxLength: maxLength,
              onChanged: onChanged,
              cursorColor: SendTheme.green,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AmountPicker extends StatefulWidget {
  final CountryConfig country;
  final ValueChanged<int?> onChanged;
  const AmountPicker({super.key, required this.country, required this.onChanged});

  @override
  State<AmountPicker> createState() => _AmountPickerState();
}

class _AmountPickerState extends State<AmountPicker> {
  final _ctrl = TextEditingController();
  int? _amount;

  @override
  void didUpdateWidget(covariant AmountPicker old) {
    super.didUpdateWidget(old);
    if (old.country.name != widget.country.name) {
      _ctrl.clear();
      _amount = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged(null));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _set(int? v) {
    setState(() => _amount = v);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.country;
    final presets = amountPresets(c);
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.7,
          children: presets.map((a) {
            final sel = _amount == a;
            return GestureDetector(
              onTap: () {
                _ctrl.clear();
                _set(a);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: sel ? SendTheme.green.withValues(alpha: 0.15) : SendTheme.inner,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? SendTheme.green : SendTheme.innerLine, width: sel ? 1.5 : 1),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('${c.symbol}${fmtNumber(a)}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        SendField(
          controller: _ctrl,
          hint: 'Or enter another amount',
          prefix: Text(c.symbol, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          keyboard: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _set(int.tryParse(v)),
        ),
      ],
    );
  }
}

class SendButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const SendButton({super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF3CF08A), Color(0xFF18D5D5)]),
          boxShadow: [BoxShadow(color: SendTheme.green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF04201A), size: 22),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Color(0xFF04201A), fontSize: 19, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmSend(BuildContext context, String title, List<String> lines) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: SendTheme.panel,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(lines.join('\n'), style: const TextStyle(color: Colors.white70, height: 1.6)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm', style: TextStyle(color: SendTheme.green)),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<String?> pickFromList(BuildContext context, String title, List<String> items) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SendTheme.panel,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => _PickerSheet(title: title, items: items),
  );
}

class _PickerSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  const _PickerSheet({required this.title, required this.items});

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = widget.items.where((e) => q.isEmpty || e.toLowerCase().contains(q)).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: SendTheme.inner,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SendTheme.innerLine),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        cursorColor: SendTheme.green,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: TextStyle(color: Colors.white30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('Nothing found', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(list[i], style: const TextStyle(color: Colors.white, fontSize: 16)),
                        onTap: () => Navigator.pop(context, list[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
