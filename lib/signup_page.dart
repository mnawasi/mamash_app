import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamash_app/main_shell.dart';
import 'package:mamash_app/country_config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  static const Color _bg = Color(0xFF030D0B);
  static const Color _card = Color(0xFF0A1715);
  static const Color _fieldBg = Color(0xFF0C1C1A);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1A3A33);
  static const String _brandTag = 'Tech'; // text in the green chip next to "Mamash"

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  CountryConfig? _country;
  String? _gender;
  bool _showPass = false;
  bool _showConfirm = false;
  bool _agree = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Try logging in.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      default:
        return 'Could not create your account. Please try again.';
    }
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');

    if (name.length < 2) return _msg('Enter your full name');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) return _msg('Enter a valid email address');
    if (_country == null) return _msg('Select your country');
    if (digits.length < 7 || digits.length > 11) return _msg('Enter a valid phone number');
    if (_gender == null) return _msg('Select your gender');
    if (_password.text.length < 8) return _msg('Password must be at least 8 characters');
    if (_password.text != _confirm.text) return _msg('Passwords do not match');
    if (!_agree) return _msg('Please agree to the Terms & Conditions');

    final c = _country!;
    final fullPhone = '${c.dial}$digits';
    setState(() => _busy = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: _password.text);
      final user = cred.user!;
      await user.updateDisplayName(name);

      // Account number = last 10 digits of the full phone number (unique per phone number).
      final all = '${c.dial.replaceAll('+', '')}$digits';
      final account = all.substring(all.length - 10);

      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': name,
          'name': name,
          'email': email,
          'phone': fullPhone,
          'phoneNumber': fullPhone,
          'country': c.name,
          'currency': c.currencyCode,
          'gender': _gender,
          'accountNumber': account,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // The account exists; the profile can be completed later.
      }
      try {
        await user.sendEmailVerification();
      } catch (_) {}

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _msg(_authMessage(e.code));
    } catch (_) {
      _msg('Could not create your account. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickCountry() async {
    final c = await showModalBottomSheet<CountryConfig>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: CountryConfig.all
              .map((c) => ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 28)),
                    title: Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    trailing: Text('${c.dial}  \u2022  ${c.currencyCode}', style: const TextStyle(color: Colors.white54)),
                    onTap: () => Navigator.pop(context, c),
                  ))
              .toList(),
        ),
      ),
    );
    if (c != null) setState(() => _country = c);
  }

  Future<void> _pickGender() async {
    final g = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: ['Male', 'Female', 'Prefer not to say']
              .map((g) => ListTile(
                    title: Text(g, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    trailing: g == _gender ? const Icon(Icons.check, color: _green) : null,
                    onTap: () => Navigator.pop(context, g),
                  ))
              .toList(),
        ),
      ),
    );
    if (g != null) setState(() => _gender = g);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF05241C), Color(0xFF030D0B), Color(0xFF04140F)],
                ),
              ),
            ),
          ),
          Positioned(top: -20, right: -50, child: Icon(Icons.public, size: 240, color: _green.withValues(alpha: 0.12))),
          Positioned(left: 0, right: 0, bottom: 0, height: 90, child: CustomPaint(painter: _WavePainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  _brand(),
                  const SizedBox(height: 18),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
                      children: [
                        TextSpan(text: 'Create '),
                        TextSpan(text: 'Account', style: TextStyle(color: _green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Join Mamash $_brandTag today and enjoy seamless financial services worldwide.',
                      style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 16, height: 1.35)),
                  const SizedBox(height: 18),
                  _formCard(),
                  const SizedBox(height: 22),
                  _footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)]),
                ),
                child: const Text('M',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Mamash', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1)),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(14)),
                    child: const Text(_brandTag,
                        style: TextStyle(color: Color(0xFF04201A), fontSize: 17, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Fast  \u2022  Secure  \u2022  Global', style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _formCard() {
    final c = _country;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          _shell(Icons.person_outline, 'Full Name', _text(_name, 'Enter your full name', type: TextInputType.name, caps: TextCapitalization.words)),
          _shell(Icons.mail_outline, 'Email Address', _text(_email, 'Enter your email address', type: TextInputType.emailAddress)),
          _shell(
            Icons.phone_outlined,
            'Phone Number',
            _text(_phone, 'Enter your phone number', type: TextInputType.phone, prefix: c == null ? null : '${c.dial} '),
          ),
          _shell(
            Icons.public,
            'Country',
            Text(c == null ? 'Select your country' : '${c.flag}  ${c.name}',
                style: TextStyle(color: c == null ? const Color(0xFF8FA39E) : Colors.white, fontSize: 15)),
            onTap: _pickCountry,
            trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 28),
          ),
          _shell(
            Icons.wc,
            'Gender',
            Text(_gender ?? 'Select your gender',
                style: TextStyle(color: _gender == null ? const Color(0xFF8FA39E) : Colors.white, fontSize: 15)),
            onTap: _pickGender,
            trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 28),
          ),
          _shell(
            Icons.lock_outline,
            'Password',
            _text(_password, 'Create a strong password', obscure: !_showPass),
            trailing: _eye(_showPass, () => setState(() => _showPass = !_showPass)),
          ),
          _shell(
            Icons.lock_reset,
            'Confirm Password',
            _text(_confirm, 'Re-enter your password', obscure: !_showConfirm),
            trailing: _eye(_showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
          ),
          const SizedBox(height: 2),
          _terms(),
          const SizedBox(height: 16),
          _button(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _line)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Already have an account?  ', style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 13.5)),
              ),
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: const Text('Login',
                    style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: _line)),
            ],
          ),
          const SizedBox(height: 16),
          _protected(),
        ],
      ),
    );
  }

  Widget _shell(IconData icon, String label, Widget child, {VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minHeight: 66),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Icon(icon, color: _green, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  child,
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _text(TextEditingController c, String hint,
      {TextInputType? type, bool obscure = false, String? prefix, TextCapitalization caps = TextCapitalization.none}) {
    return TextField(
      controller: c,
      keyboardType: type,
      obscureText: obscure,
      textCapitalization: caps,
      cursorColor: _green,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 3),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8FA39E), fontSize: 15),
        prefixText: prefix,
        prefixStyle: const TextStyle(color: Colors.white, fontSize: 15),
      ),
    );
  }

  Widget _eye(bool visible, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 26),
      ),
    );
  }

  Widget _terms() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _agree = !_agree),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _agree ? _green : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _agree ? _green : Colors.white54, width: 1.6),
            ),
            child: _agree ? const Icon(Icons.check, size: 18, color: Color(0xFF04201A)) : null,
          ),
        ),
        const SizedBox(width: 12),
        const Text('I agree to the ', style: TextStyle(color: Colors.white, fontSize: 14)),
        GestureDetector(
          onTap: () => _msg('Terms & Conditions coming soon'),
          child: const Text('Terms & Conditions',
              style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _button() {
    return GestureDetector(
      onTap: _busy ? null : _submit,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF14C98B)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: Center(
          child: _busy
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF04201A)))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CREATE ACCOUNT',
                        style: TextStyle(color: Color(0xFF04201A), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward, color: Color(0xFF04201A), size: 24),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _protected() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: _green, size: 28),
          Container(width: 1, height: 34, margin: const EdgeInsets.symmetric(horizontal: 12), color: _line),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your information is protected',
                    style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('using bank-level encryption.', style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline, color: _green, size: 24),
        ],
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: _line)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('MAMASH TECH', style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 11.5, letterSpacing: 3)),
            ),
            Expanded(child: Container(height: 1, color: _line)),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public, color: _green, size: 16),
            SizedBox(width: 8),
            Text('Nigeria to the World', style: TextStyle(color: Color(0xFFB5C4C0), fontSize: 12, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.6, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.7, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1FE5A0).withValues(alpha: 0.3), const Color(0xFF030D0B)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
