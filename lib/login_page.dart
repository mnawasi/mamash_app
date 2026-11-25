import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamash_app/country_config.dart';
import 'package:mamash_app/main_shell.dart';
import 'package:mamash_app/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kSavedPhone = 'saved_phone';
const String _kSavedEmail = 'saved_email';

/// Remembers the phone and email on this device so the login page can show them.
Future<void> rememberLogin(String phone, String email) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedPhone, phone);
    await prefs.setString(_kSavedEmail, email);
  } catch (_) {}
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _bg = Color(0xFF040C0B);

  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _pinFocus = FocusNode();
  String? _savedPhone;
  String? _savedEmail;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _savedPhone = prefs.getString(_kSavedPhone);
        _savedEmail = prefs.getString(_kSavedEmail);
      });
    } catch (_) {}
  }

  Future<void> _forgetPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSavedPhone);
      await prefs.remove(_kSavedEmail);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _savedPhone = null;
      _savedEmail = null;
      _pin.clear();
    });
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  /// The number without the country code and without a leading zero.
  String _national(String raw) {
    final d = _digits(raw);
    for (final c in CountryConfig.all) {
      final code = _digits(c.dial);
      if (d.startsWith(code) && d.length >= code.length + 9) {
        return d.substring(code.length).replaceFirst(RegExp(r'^0'), '');
      }
    }
    return d.replaceFirst(RegExp(r'^0'), '');
  }

  String _mask(String raw) {
    final n = _national(raw);
    if (n.length <= 4) return n;
    return n.substring(0, 2) + 'X' * (n.length - 4) + n.substring(n.length - 2);
  }

  List<String> _variants(String raw) {
    final all = _digits(raw);
    final n = _national(raw);
    final set = <String>{raw.trim(), all, n, '0$n', '+$all'};
    for (final c in CountryConfig.all) {
      final d = _digits(c.dial);
      set.add('+$d$n');
      set.add('$d$n');
    }
    set.removeWhere((e) => e.isEmpty);
    return set.toList();
  }

  Future<String?> _emailForPhone(String raw, {bool exact = false}) async {
    final vars = exact ? [raw] : _variants(raw);
    final users = FirebaseFirestore.instance.collection('users');
    for (final field in ['phoneNumber', 'phone']) {
      final q = await users.where(field, whereIn: vars).limit(1).get();
      if (q.docs.isNotEmpty) return q.docs.first.data()['email'] as String?;
    }
    return null;
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-not-found':
        return 'Incorrect PIN. Try again.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return e.message ?? 'Login failed';
    }
  }

  Future<void> _login() async {
    if (_loading) return;
    final raw = _savedPhone ?? _phone.text.trim();
    final pin = _pin.text;
    if (raw.isEmpty) return _msg('Enter your phone number');
    if (pin.length != 6) return _msg('Enter your 6-digit PIN');
    setState(() => _loading = true);
    try {
      String? email = _savedPhone != null ? _savedEmail : null;
      email ??= await _emailForPhone(raw, exact: _savedPhone != null);
      if (email == null || email.isEmpty) {
        _pin.clear();
        _msg('No account found for this phone number');
        return;
      }
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pin);
      var phone = raw;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .get();
        final d = doc.data();
        final p = (d?['phoneNumber'] ?? d?['phone']) as String?;
        if (p != null && p.trim().isNotEmpty) phone = p.trim();
      } catch (_) {}
      await rememberLogin(phone, email);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _pin.clear();
      _msg(_authMessage(e));
    } catch (_) {
      _pin.clear();
      _msg('Login failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final c = TextEditingController(text: _savedEmail ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1F1A),
        title: const Text('Reset PIN', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email and we will send you a reset link.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send link')),
        ],
      ),
    );
    final email = c.text.trim();
    if (ok != true) return;
    if (email.isEmpty) return _msg('Enter your email');
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _msg('Reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? 'Could not send reset link');
    }
  }

  Widget _row(String label, Widget child, {Widget? trailing}) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 104,
            height: 64,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 22),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(20)),
            ),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 24),
          Expanded(child: child),
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 18), child: trailing),
        ],
      ),
    );
  }

  Widget _usernameField() {
    final saved = _savedPhone;
    if (saved != null) {
      return Text(_mask(saved),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1));
    }
    return TextField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white, fontSize: 20),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Phone number',
        hintStyle: TextStyle(color: Colors.white38),
      ),
    );
  }

  Widget _pinField() {
    return GestureDetector(
      onTap: () => _pinFocus.requestFocus(),
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: TextField(
                controller: _pin,
                focusNode: _pinFocus,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  setState(() {});
                  if (v.length == 6) _login();
                },
              ),
            ),
            IgnorePointer(
              child: Row(
                children: [
                  for (int i = 0; i < 6; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.text.length
                            ? Colors.white
                            : Colors.transparent,
                        border: Border.all(color: Colors.white70, width: 1.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = _savedPhone;
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF062A22), Color(0xFF040C0B), Color(0xFF040C0B)],
                  stops: [0, .4, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: CustomPaint(painter: _WavePainter()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1FE5A0), Color(0xFF0E9B63)],
                          ),
                        ),
                        child: const Text('M',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic)),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(
                                    text: 'Mamash ',
                                    style: TextStyle(color: Colors.white)),
                                TextSpan(
                                    text: 'Pay',
                                    style: TextStyle(color: _green)),
                              ],
                            ),
                          ),
                          const Text('FAST  •  SAFE  •  GLOBAL',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  letterSpacing: 4)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 44),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
                      children: [
                        TextSpan(
                            text: 'Welcome ',
                            style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'back', style: TextStyle(color: _green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Log in to continue to your wallet',
                      style: TextStyle(color: Colors.white54, fontSize: 18)),
                  const SizedBox(height: 28),
                  _row('Username', _usernameField()),
                  const SizedBox(height: 16),
                  _row(
                    'PIN',
                    _pinField(),
                    trailing: GestureDetector(
                      onTap: _forgot,
                      child: const Text('Forgot?',
                          style: TextStyle(
                              color: _green,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationColor: _green)),
                    ),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                          child: CircularProgressIndicator(color: _green)),
                    ),
                  if (saved != null) ...[
                    const SizedBox(height: 40),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text('Not ${_mask(saved)} ? ',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          GestureDetector(
                            onTap: _forgetPhone,
                            child: const Text('CLICK HERE',
                                style: TextStyle(
                                    color: _green,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _green)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => _msg('Agent locations are coming soon'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 26),
                          SizedBox(width: 6),
                          Text('Find Agents',
                              style: TextStyle(
                                  color: _green,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  Center(
                    child: GestureDetector(
                      onTap: () => _msg('Biometric login is coming soon'),
                      child: Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _green, width: 2),
                              boxShadow: [
                                BoxShadow(
                                    color: _green.withValues(alpha: 0.35),
                                    blurRadius: 24),
                              ],
                            ),
                            child: const Icon(Icons.fingerprint,
                                color: _green, size: 62),
                          ),
                          const SizedBox(height: 14),
                          const Text('Use biometrics',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SignupPage())),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Don't have an account? ",
                        style: TextStyle(color: Colors.white, fontSize: 17)),
                    Text('Sign up',
                        style: TextStyle(
                            color: _green,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: _green, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.05,
          size.width * 0.55, size.height * 0.30)
      ..quadraticBezierTo(
          size.width * 0.80, size.height * 0.50, size.width, size.height * 0.12)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16B97A), Color(0xFF062A22)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
