import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockPage extends StatefulWidget {
  final VoidCallback onUnlocked;
  const AppLockPage({super.key, required this.onUnlocked});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _bg = Color(0xFF040C0B);

  final _pin = TextEditingController();
  final _password = TextEditingController();
  final _pinFocus = FocusNode();
  bool _usePassword = false;
  bool _obscure = true;
  bool _isVerifying = false;
  String? _error;
  String _masked = '';

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  @override
  void dispose() {
    _pin.dispose();
    _password.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _loadPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('saved_phone') ?? '';
      var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
      if (d.length > 10) d = d.substring(d.length - 10);
      if (d.length > 4) {
        d = d.substring(0, 2) + 'X' * (d.length - 4) + d.substring(d.length - 2);
      }
      if (!mounted) return;
      setState(() => _masked = d);
    } catch (_) {}
  }

  Future<void> _verify(String secret) async {
    if (_isVerifying) return;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      setState(() => _error = 'No signed-in user found.');
      return;
    }
    if (secret.isEmpty) {
      setState(() => _error = _usePassword
          ? 'Please enter your password.'
          : 'Please enter your 6-digit PIN.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: secret);
      await user.reauthenticateWithCredential(credential);
      if (!mounted) return;
      widget.onUnlocked();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = _usePassword
              ? 'Incorrect password. Try again.'
              : 'Incorrect PIN. Try again.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please wait and try again.';
          break;
        case 'network-request-failed':
          message = 'No internet connection.';
          break;
        default:
          message = 'Could not verify. Please try again.';
      }
      _pin.clear();
      if (mounted) setState(() => _error = message);
    } catch (_) {
      _pin.clear();
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) widget.onUnlocked();
  }

  Widget _pinCircles() {
    return GestureDetector(
      onTap: () => _pinFocus.requestFocus(),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green.withValues(alpha: 0.3)),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: TextField(
                controller: _pin,
                focusNode: _pinFocus,
                autofocus: true,
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
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  setState(() => _error = null);
                  if (v.length == 6) _verify(v);
                },
              ),
            ),
            IgnorePointer(
              child: Row(
                children: [
                  for (int i = 0; i < 6; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 14),
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

  Widget _passwordField() {
    return Container(
      height: 64,
      padding: const EdgeInsets.only(left: 22, right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _green.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _password,
        obscureText: _obscure,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        onSubmitted: _verify,
        decoration: InputDecoration(
          border: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.white38),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF062A22), Color(0xFF040C0B), Color(0xFF040C0B)],
            stops: [0, .4, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 40, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 36),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                    children: [
                      TextSpan(
                          text: 'Welcome ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'back', style: TextStyle(color: _green)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                    _usePassword
                        ? 'Enter your password to continue'
                        : (_masked.isEmpty
                            ? 'Enter your PIN to continue'
                            : 'Enter your PIN for $_masked'),
                    style: const TextStyle(color: Colors.white54, fontSize: 17)),
                const SizedBox(height: 28),
                _usePassword ? _passwordField() : _pinCircles(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Color(0xFFFF6B6B), fontSize: 14)),
                  ),
                const SizedBox(height: 22),
                if (_usePassword)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          _isVerifying ? null : () => _verify(_password.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27)),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.black))
                          : const Text('Unlock',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                    ),
                  )
                else if (_isVerifying)
                  const Center(child: CircularProgressIndicator(color: _green)),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _usePassword = !_usePassword;
                      _error = null;
                      _pin.clear();
                      _password.clear();
                    }),
                    child: Text(
                        _usePassword ? 'Use PIN instead' : 'Use password instead',
                        style: const TextStyle(
                            color: _green,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: _green)),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _logout,
                    child: const Text('Log out instead',
                        style: TextStyle(color: Colors.white54, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
