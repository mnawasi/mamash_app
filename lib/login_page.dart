import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_page.dart';
import 'dashboard_page.dart';
import 'forgot_password_page.dart';

enum _LoginMode { phone, email }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginMode _mode = _LoginMode.phone;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _normalizedPhone(String raw) {
    final digits = raw.trim();
    if (digits.startsWith('0')) {
      return '+234${digits.substring(1)}';
    }
    if (digits.startsWith('+234')) {
      return digits;
    }
    return '+234$digits';
  }

  Future<void> _handleLogin() async {
    setState(() {
      _error = null;
    });

    if (_passwordController.text.isEmpty) {
      setState(() => _error = "Please enter your password.");
      return;
    }

    String? email;

    if (_mode == _LoginMode.email) {
      if (_emailController.text.trim().isEmpty) {
        setState(() => _error = "Please enter your email address.");
        return;
      }
      email = _emailController.text.trim();
    } else {
      if (_phoneController.text.trim().isEmpty) {
        setState(() => _error = "Please enter your phone number.");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_mode == _LoginMode.phone) {
        // Look up the account's email by phone number in Firestore,
        // since accounts are created with email/password at signup.
        final phone = _normalizedPhone(_phoneController.text);
        final query = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _error = "No account found with this phone number.";
          });
          return;
        }

        email = query.docs.first.data()['email'] as String?;

        if (email == null) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _error = "This account has no email on file. Try logging in with email instead.";
          });
          return;
        }
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No account found with these details.";
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = "Incorrect password. Try again.";
          break;
        case 'invalid-email':
          message = "Enter a valid email address.";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Please wait and try again.";
          break;
        case 'network-request-failed':
          message = "No internet connection. Check your network and try again.";
          break;
        default:
          message = "Login failed. Please try again.";
      }
      setState(() => _error = message);
    } catch (e) {
      setState(() => _error = "Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _accentGreen.withOpacity(0.18),
                      _accentGreen.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 32),
              const Text(
                'Welcome back',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Log in to continue to your wallet',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildModeToggle(),
              const SizedBox(height: 20),
              if (_mode == _LoginMode.phone) _buildPhoneField() else _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text('Forgot password?', style: TextStyle(color: _accentGreen, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 16),
              _buildLoginButton(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildBiometricOption(),
              const SizedBox(height: 32),
              _buildSignUpPrompt(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_accentGreen, Color(0xFF0FA968)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'M',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(text: 'Mamash ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Pay', style: TextStyle(color: _accentGreen, fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'FAST  •  SAFE  •  GLOBAL',
                style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.2),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: -0.3,
                child: Container(
                  width: 56,
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: _accentGreen.withOpacity(0.5), width: 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Icon(Icons.public, color: _accentGreen.withOpacity(0.6), size: 34),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('Phone', _LoginMode.phone, Icons.phone_android)),
          Expanded(child: _modeButton('Email', _LoginMode.email, Icons.mail_outline)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, _LoginMode mode, IconData icon) {
    final bool selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        _error = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.black : Colors.white54),
            const SizedBox(width: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white54,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🇳🇬 +234', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white38, size: 18),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: Colors.white24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Phone number',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const Icon(Icons.phone_outlined, color: _accentGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Email address',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20),
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_accentGreen, Color(0xFF0FA968)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('Log in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildBiometricOption() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _cardDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint, color: _accentGreen, size: 28),
            ),
            const SizedBox(height: 8),
            const Text('Use biometrics', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Sign up',
              style: const TextStyle(color: _accentGreen, fontWeight: FontWeight.w600),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
