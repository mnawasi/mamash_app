import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamash_app/dashboard_page.dart';
import 'package:mamash_app/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  static const Color _bg = Color(0xFF040C0B);
  static const Color _field = Color(0xFF0B1A1C);
  static const Color _green = Color(0xFF1FE5A0);

  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _phoneMode = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<String?> _emailForPhone(String input) async {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0'), '');
    final variants = ['+234$digits', '234$digits', '0$digits', digits];
    final users = FirebaseFirestore.instance.collection('users');
    for (final field in ['phoneNumber', 'phone']) {
      final q = await users.where(field, whereIn: variants).limit(1).get();
      if (q.docs.isNotEmpty) return q.docs.first.data()['email'] as String?;
    }
    return null;
  }

  Future<void> _login() async {
    final pass = _password.text;
    if (pass.isEmpty) return _msg('Enter your password');
    setState(() => _loading = true);
    try {
      String? email;
      if (_phoneMode) {
        if (_phone.text.trim().isEmpty) {
          _msg('Enter your phone number');
          return;
        }
        email = await _emailForPhone(_phone.text.trim());
        if (email == null) {
          _msg('No account found for this phone number');
          return;
        }
      } else {
        email = _email.text.trim();
        if (email.isEmpty) {
          _msg('Enter your email');
          return;
        }
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? 'Login failed');
    } catch (_) {
      _msg('Login failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgot() async {
    final email = _email.text.trim();
    if (_phoneMode || email.isEmpty) {
      return _msg('Switch to Email, enter your email, then tap Forgot password');
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _msg('Password reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? 'Could not send reset link');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Positioned(left: 0, right: 0, bottom: 0, height: 120, child: CustomPaint(painter: _WavePainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 22),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
                      children: [
                        TextSpan(text: 'Welcome '),
                        TextSpan(text: 'back', style: TextStyle(color: _green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Log in to continue to your wallet',
                      style: TextStyle(color: Color(0xFF8C9AA8), fontSize: 16)),
                  const SizedBox(height: 22),
                  _toggle(),
                  const SizedBox(height: 16),
                  _phoneMode ? _phoneField() : _emailField(),
                  const SizedBox(height: 14),
                  _passwordField(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _forgot,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Forgot password?',
                              style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: _green, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _loginButton(),
                  const SizedBox(height: 22),
                  _orDivider(),
                  const SizedBox(height: 18),
                  Center(child: _biometrics()),
                  const SizedBox(height: 26),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Don't have an account?  ", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())),
                          child: const Row(
                            children: [
                              Text('Sign up',
                                  style: TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: _green, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -10,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(colors: [Color(0xFF0E3A33), Color(0xFF05140F)]),
                border: Border.all(color: _green.withValues(alpha: 0.5), width: 1.2),
                boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.25), blurRadius: 20)],
              ),
              child: Icon(Icons.public, color: _green.withValues(alpha: 0.35), size: 80),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)],
                  ),
                  boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
                ),
                child: const Text('M',
                    style: TextStyle(
                        color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
                      children: [
                        TextSpan(text: 'Mamash '),
                        TextSpan(text: 'Pay', style: TextStyle(color: _green)),
                      ],
                    ),
                  ),
                  const Text('FAST  \u2022  SAFE  \u2022  GLOBAL',
                      style: TextStyle(color: Color(0xFF7D8A96), fontSize: 11, letterSpacing: 2.2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggle() {
    Widget tab(String label, IconData icon, bool selected, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: selected
                  ? const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF14C98B)])
                  : null,
              boxShadow: selected ? [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)] : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: selected ? Colors.black : Colors.white70),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: selected ? Colors.black : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          tab('Phone', Icons.smartphone, _phoneMode, () => setState(() => _phoneMode = true)),
          tab('Email', Icons.mail, !_phoneMode, () => setState(() => _phoneMode = false)),
        ],
      ),
    );
  }

  BoxDecoration _fieldBox() => BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.22)),
      );

  InputDecoration _hint(String t) => InputDecoration(
        border: InputBorder.none,
        hintText: t,
        hintStyle: const TextStyle(color: Color(0xFF7D8A96), fontSize: 16),
      );

  Widget _phoneField() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _fieldBox(),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 20,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Expanded(child: Container(color: const Color(0xFF008751))),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: const Color(0xFF008751))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text('+234', style: TextStyle(color: Colors.white, fontSize: 16)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Container(width: 1.5, height: 28, color: _green.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _hint('Phone number'),
            ),
          ),
          const Icon(Icons.phone, color: _green, size: 20),
        ],
      ),
    );
  }

  Widget _emailField() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _fieldBox(),
      child: Row(
        children: [
          const Icon(Icons.mail_outline, color: Color(0xFF9FB0C3), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _hint('Email address'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _fieldBox(),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Color(0xFF9FB0C3), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _password,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: _hint('Password'),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9FB0C3), size: 22),
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return GestureDetector(
      onTap: _loading ? null : _login,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF14C98B)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.45), blurRadius: 18)],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                  )
                : const Text('Log in',
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800)),
            Positioned(
              right: 8,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF04201A)),
                child: const Icon(Icons.arrow_forward, color: _green, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white24)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text('Or', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ),
        Expanded(child: Container(height: 1, color: Colors.white24)),
      ],
    );
  }

  Widget _biometrics() {
    return GestureDetector(
      onTap: () => _msg('Biometric login coming soon...'),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _field,
              border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.4),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 16)],
            ),
            child: const Icon(Icons.fingerprint, color: _green, size: 42),
          ),
          const SizedBox(height: 8),
          const Text('Use biometrics',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1, size.width * 0.6, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.62, size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      back,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1FE5A0).withValues(alpha: 0.35), const Color(0xFF040C0B)],
        ).createShader(Offset.zero & size),
    );
    final front = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.45, size.width * 0.7, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.85, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF14C98B).withValues(alpha: 0.5), const Color(0xFF040C0B)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
