import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ai/ai_assistant_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _line = Color(0xFF1B2A44);

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

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) _msg(context, 'Copied $text');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Help & Support',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How would you like help?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Choose one of the two options below.',
                style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 14)),
            const SizedBox(height: 18),
            _aiCard(context),
            const SizedBox(height: 16),
            _contactCard(context),
          ],
        ),
      ),
    );
  }

  Widget _aiCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1A6E), Color(0xFF1B2A6E), Color(0xFF0E1A3A)],
        ),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFFB36BFF), Color(0xFF6D28D9)]),
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Support',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text('Ask Mamash AI and get answers instantly',
                        style: TextStyle(color: Color(0xFFC9D2F5), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AIAssistantPage()),
            ),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: const Color(0xFF8B5CF6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text('Chat with AI',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: _panel,
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: _gold, size: 30),
              SizedBox(width: 12),
              Text('Contact us',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 42),
            child: Text('Call or email our team',
                style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 13)),
          ),
          const SizedBox(height: 16),
          _contactRow(
            context,
            icon: Icons.call,
            colors: const [Color(0xFF22C55E), Color(0xFF15803D)],
            label: 'Call us',
            value: _phoneShown,
            action: 'Call',
            onAction: () => _open(context, Uri(scheme: 'tel', path: _phoneRaw), _phoneRaw, 'the phone app'),
            onCopy: () => _copy(context, _phoneRaw),
          ),
          const SizedBox(height: 12),
          _contactRow(
            context,
            icon: Icons.mail,
            colors: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            label: 'Email us',
            value: _email,
            action: 'Email',
            onAction: () => _open(
              context,
              Uri(scheme: 'mailto', path: _email, queryParameters: {'subject': 'Mamash Pay support'}),
              _email,
              'the email app',
            ),
            onCopy: () => _copy(context, _email),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(
    BuildContext context, {
    required IconData icon,
    required List<Color> colors,
    required String label,
    required String value,
    required String action,
    required VoidCallback onAction,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF070D18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 12)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCopy,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.copy, color: Color(0xFF8FA3C8), size: 20),
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
              ),
              child: Text(action,
                  style: const TextStyle(color: Color(0xFF3A2A00), fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
