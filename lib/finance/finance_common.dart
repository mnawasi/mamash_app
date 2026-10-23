import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../country_config.dart';

class FT {
  static const Color bg = Color(0xFF03110F);
  static const Color panel = Color(0xFF08201D);
  static const Color inner = Color(0xFF051A17);
  static const Color line = Color(0xFF15463E);
  static const Color green = Color(0xFF1FE5A0);
}

Future<CountryConfig> financeCountry() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return CountryConfig.all.first;
  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return CountryConfig.fromName(doc.data()?['country'] as String?);
  } catch (_) {
    return CountryConfig.all.first;
  }
}

String symbolFor(String? code) {
  for (final c in CountryConfig.all) {
    if (c.currencyCode == code) return c.symbol;
  }
  return '\u20a6';
}

String money(num v, {int decimals = 2}) {
  final parts = v.toStringAsFixed(decimals).split('.');
  final s = parts[0];
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return decimals > 0 ? '$b.${parts[1]}' : b.toString();
}

class FinScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final List<Widget> children;
  const FinScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.accent = FT.green,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FT.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accent.withValues(alpha: 0.28), FT.bg],
            stops: const [0, .4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                          Text(subtitle, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? border;
  const FinPanel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: padding,
      decoration: BoxDecoration(
        color: FT.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border ?? FT.line),
      ),
      child: child,
    );
  }
}

class FinButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  final bool outline;
  const FinButton({super.key, required this.label, this.icon, this.onTap, this.busy = false, this.outline = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: outline ? null : const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
          border: outline ? Border.all(color: FT.green) : null,
          boxShadow: outline ? null : [BoxShadow(color: FT.green.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Center(
          child: busy
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF04201A)))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: outline ? FT.green : const Color(0xFF04201A), size: 22),
                      const SizedBox(width: 8),
                    ],
                    Text(label,
                        style: TextStyle(
                            color: outline ? FT.green : const Color(0xFF04201A), fontSize: 16.5, fontWeight: FontWeight.w800)),
                  ],
                ),
        ),
      ),
    );
  }
}

class FinEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const FinEmpty({super.key, required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return FinPanel(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FT.green.withValues(alpha: 0.1),
              border: Border.all(color: FT.green.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: FT.green, size: 36),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5, height: 1.4)),
        ],
      ),
    );
  }
}
