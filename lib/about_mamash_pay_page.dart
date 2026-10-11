import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMamashPayPage extends StatelessWidget {
  const AboutMamashPayPage({super.key});

  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1B2A44);

  static const String _version = '1.0.0';
  static const String _phoneRaw = '+2348137479520';
  static const String _phoneShown = '+234 813 747 9520';
  static const String _email = 'mamashpay0@gmail.com';

  void _msg(BuildContext context, String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _open(BuildContext context, Uri uri, String copyText, String label) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      await Clipboard.setData(ClipboardData(text: copyText));
      if (context.mounted) _msg(context, 'Couldn\'t open $label. Copied $copyText instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('About Mamash Pay',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(),
            const SizedBox(height: 18),
            _card(
              title: 'Our mission',
              icon: Icons.flag,
              child: const Text(
                'Mamash Pay is a digital wallet built for everyday Nigerians, including traders, '
                'small businesses and anyone who works outside traditional banking. We want to make '
                'sending, saving and paying simple, and to take that experience beyond Nigeria so your '
                'money works wherever you are.',
                style: TextStyle(color: Color(0xFFD5DEF2), fontSize: 14.5, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            _card(
              title: 'What you can do',
              icon: Icons.apps,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _Chip(Icons.send, 'Send & receive money'),
                  _Chip(Icons.smartphone, 'Airtime & data'),
                  _Chip(Icons.receipt_long, 'Pay bills'),
                  _Chip(Icons.public, 'International transfers'),
                  _Chip(Icons.card_giftcard, 'Rewards'),
                  _Chip(Icons.smart_toy, 'Mamash AI assistant'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _card(
              title: 'Contact us',
              icon: Icons.support_agent,
              child: Column(
                children: [
                  _contact(
                    Icons.mail,
                    const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    _email,
                    () => _open(
                      context,
                      Uri(scheme: 'mailto', path: _email, queryParameters: {'subject': 'Mamash Pay'}),
                      _email,
                      'the email app',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _contact(
                    Icons.call,
                    const [Color(0xFF22C55E), Color(0xFF15803D)],
                    _phoneShown,
                    () => _open(context, Uri(scheme: 'tel', path: _phoneRaw), _phoneRaw, 'the phone app'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  _linkRow(context, Icons.description_outlined, 'Terms of Service', true),
                  _linkRow(context, Icons.privacy_tip_outlined, 'Privacy Policy', false),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text('\u00a9 2026 Mamash Pay. All rights reserved.',
                  style: TextStyle(color: Color(0xFF6B7A9A), fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3A33), Color(0xFF0A1B2E), Color(0xFF2A2210)],
        ),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)],
              ),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 18)],
            ),
            child: const Text('M',
                style: TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
              children: [
                TextSpan(text: 'Mamash '),
                TextSpan(text: 'Pay', style: TextStyle(color: _green)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Your money, worldwide', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 15)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text('Version $_version',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _gold, size: 24),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _contact(IconData icon, List<Color> colors, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF070D18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w600)),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _linkRow(BuildContext context, IconData icon, String title, bool divider) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _msg(context, '$title coming soon...'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: divider ? const Border(bottom: BorderSide(color: Color(0xFF1B2A44))) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9FB0D0), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1FE5A0).withValues(alpha: 0.1),
        border: Border.all(color: const Color(0xFF1FE5A0).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1FE5A0), size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
