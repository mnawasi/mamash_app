import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _Msg {
  final String text;
  final bool fromUser;
  final DateTime time;
  _Msg(this.text, this.fromUser) : time = DateTime.now();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  static const String _welcome =
      'Hi! I\'m Mamash AI. Ask me about your transactions, bill payments, or how to use any feature in the app.';

  static const Color _navy = Color(0xFF0A2A8A);
  static const Color _blue = Color(0xFF1D6BFF);
  static const Color _ink = Color(0xFF1A2A4A);

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(_welcome, false));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _clear() {
    setState(() {
      _messages
        ..clear()
        ..add(_Msg(_welcome, false));
      _typing = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _typing) return;
    _controller.clear();
    setState(() {
      _messages.add(_Msg(text, true));
      _typing = true;
    });
    _scrollDown();

    final reply = await _reply(text);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _messages.add(_Msg(reply, false));
      _typing = false;
    });
    _scrollDown();
  }

  // Built-in answers. To connect a real AI model later, call it here from a secure backend
  // and return its answer. Don't put an AI API key inside the app.
  Future<String> _reply(String input) async {
    final t = input.toLowerCase();
    bool has(List<String> words) => words.any(t.contains);

    if (has(['account number', 'account no', 'my account'])) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'Please log in to see your account number.';
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final n = doc.data()?['accountNumber'];
        if (n is String && n.trim().isNotEmpty) {
          return 'Your Mamash account number is ${n.trim()}. You can also copy it from the Home screen.';
        }
      } catch (_) {}
      return 'I couldn\'t find an account number on your profile yet. Please contact support if this keeps happening.';
    }
    if (has(['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening']) && t.split(' ').length <= 3) {
      return 'Hello \u{1F44B} Welcome to Mamash! How can I help you today?';
    }
    if (has(['thank'])) return 'You\'re welcome! Is there anything else I can help with?';
    if (has(['airtime', 'recharge'])) {
      return 'To buy airtime, open Airtime from Quick services on the Home screen, choose your network, enter the number and amount, then tap Continue.';
    }
    if (has(['data', 'internet', 'mb', 'gb'])) {
      return 'To buy data, open Data from Quick services, choose the network and a plan, enter the phone number, then tap Continue.';
    }
    if (has(['bill', 'electricity', 'nepa', 'cable', 'dstv', 'gotv', 'water'])) {
      return 'You can pay bills from Bills on the Home screen. Pick the type of bill, enter your details and confirm.';
    }
    if (has(['international', 'abroad', 'dollar', 'pounds'])) {
      return 'For international transfers, open Transfer from Quick services, choose the country, enter the recipient\'s details and the amount. You\'ll see the estimated rate before you confirm.';
    }
    if (has(['send', 'transfer'])) {
      return 'Tap Send on the Home screen, then choose Transfer to Mamash, To Bank or QR Payment.';
    }
    if (has(['limit', 'tier', 'upgrade', 'verify', 'kyc', 'bvn'])) {
      return 'Your limits depend on your tier: Tier 1 up to \u20a6500,000 per day, Tier 2 up to \u20a65,000,000 and Tier 3 up to \u20a630,000,000. Open Profile, then Transaction Limits to see yours and upgrade.';
    }
    if (has(['balance'])) {
      return 'Your balance is shown at the top of the Home screen and on the Wallet page. Tap the eye icon to hide or show it.';
    }
    if (has(['password', 'forgot'])) {
      return 'To change your password, go to Profile, then Security. If you forgot it, use Forgot password on the login screen.';
    }
    if (has(['support', 'help', 'contact', 'call', 'email', 'complaint'])) {
      return 'You can reach our team at mamashpay0@gmail.com or call +234 813 747 9520. You can also open Profile, then Help & Support.';
    }
    return 'I\'m not sure about that yet. I can help with account numbers, airtime, data, bills, transfers and limits. For anything else, email mamashpay0@gmail.com.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF1FF),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEAF2FF), Color(0xFFF7FAFF), Color(0xFFE6E8FF)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -30,
                    top: 20,
                    child: Icon(Icons.public, size: 220, color: _blue.withValues(alpha: 0.07)),
                  ),
                  ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    itemCount: _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) return _typingBubble();
                      final m = _messages[i];
                      return m.fromUser ? _userBubble(m) : _botBubble(m);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xFFF1F5FF),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: _inputBar(),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _avatar(double size, {bool online = false}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4FA8FF), Color(0xFF1D4ED8)],
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.smart_toy, color: Colors.white, size: size * 0.55),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(6, MediaQuery.of(context).padding.top + 8, 4, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A2A8A), Color(0xFF1546C8), Color(0xFF0A2A8A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 26),
            ),
          ),
          _avatar(56, online: true),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mamash AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700)),
                Text('Your AI Assistant',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFFB9CBF5), fontSize: 13)),
              ],
            ),
          ),
          const Tooltip(
            message: 'Always here for you',
            child: Icon(Icons.verified_user, color: Color(0xFF6CC4FF), size: 28),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v == 'clear') _clear();
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'clear', child: Text('Clear chat'))],
          ),
        ],
      ),
    );
  }

  Widget _botBubble(_Msg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(46),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.text, style: const TextStyle(color: _ink, fontSize: 16, height: 1.35)),
                  const SizedBox(height: 6),
                  Text(_time(m.time), style: const TextStyle(color: Color(0xFF9AA6BE), fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userBubble(_Msg m) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 60),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1F7BFF), Color(0xFF0F5BE8)]),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.35)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_time(m.time), style: const TextStyle(color: Color(0xFFD5E4FF), fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Color(0xFF9FE8FF), size: 17),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _avatar(46),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(),
                SizedBox(width: 5),
                _Dot(),
                SizedBox(width: 5),
                _Dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _msg('Attachments coming soon...'),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEFF3FB)),
              child: const Icon(Icons.add, color: _ink, size: 26),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _send(),
              textInputAction: TextInputAction.send,
              cursorColor: _blue,
              style: const TextStyle(color: _ink, fontSize: 16),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'Ask Mamash AI...',
                hintStyle: TextStyle(color: Color(0xFF9AA6BE), fontSize: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _msg('Emoji keyboard: use the emoji key on your keyboard'),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.sentiment_satisfied_alt_outlined, color: Color(0xFF5A6A8A), size: 28),
            ),
          ),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A86FF), Color(0xFF0F5BE8)],
                ),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    Widget item(String code, String name) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FlagIcon(code),
              const SizedBox(height: 5),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, 10 + MediaQuery.of(context).padding.bottom),
      color: const Color(0xFF0A2A8A),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              item('NG', 'Nigeria'),
              item('GH', 'Ghana'),
              item('CA', 'Canada'),
              item('US', 'USA'),
              item('GB', 'England'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.public, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Mamash  \u2022  More countries coming soon',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Color(0xFFDDE7FF), fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFF0E7A6B).withValues(alpha: 0.4),
                  border: Border.all(color: const Color(0xFF3DE0B0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFF3DE0B0), size: 18),
                    SizedBox(width: 6),
                    Text('Secure & Private',
                        style: TextStyle(color: Color(0xFF3DE0B0), fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF9AA6BE)),
    );
  }
}


class _FlagIcon extends StatelessWidget {
  final String code;
  const _FlagIcon(this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 24,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white54, width: 0.8),
      ),
      child: _flag(),
    );
  }

  Widget _flag() {
    switch (code) {
      case 'NG':
        return const Row(
          children: [
            Expanded(child: ColoredBox(color: Color(0xFF008751))),
            Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(child: ColoredBox(color: Color(0xFF008751))),
          ],
        );
      case 'GH':
        return Column(
          children: [
            const Expanded(child: ColoredBox(color: Color(0xFFCE1126))),
            Expanded(
              child: Container(
                color: const Color(0xFFFCD116),
                alignment: Alignment.center,
                child: const Icon(Icons.star, color: Colors.black, size: 9),
              ),
            ),
            const Expanded(child: ColoredBox(color: Color(0xFF006B3F))),
          ],
        );
      case 'CA':
        return Row(
          children: [
            const Expanded(child: ColoredBox(color: Color(0xFFD52B1E))),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: const Icon(Icons.eco, color: Color(0xFFD52B1E), size: 14),
              ),
            ),
            const Expanded(child: ColoredBox(color: Color(0xFFD52B1E))),
          ],
        );
      case 'US':
        return Stack(
          children: [
            Column(
              children: List.generate(
                7,
                (i) => Expanded(child: ColoredBox(color: i.isEven ? const Color(0xFFB22234) : Colors.white)),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 16,
              height: 13,
              child: Container(
                color: const Color(0xFF3C3B6E),
                alignment: Alignment.center,
                child: const Icon(Icons.star, color: Colors.white, size: 7),
              ),
            ),
          ],
        );
      case 'GB':
        return Stack(
          children: [
            const SizedBox.expand(child: ColoredBox(color: Colors.white)),
            Center(child: Container(height: 6, color: const Color(0xFFCF142B))),
            Center(child: Container(width: 6, color: const Color(0xFFCF142B))),
          ],
        );
      default:
        return const ColoredBox(color: Colors.grey);
    }
  }
}
