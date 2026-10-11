import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _line = Color(0xFF1B2A44);

  void _msg(BuildContext context, String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _changePassword(BuildContext context) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _ChangePasswordSheet(),
      ),
    );
    if (done == true && context.mounted) _msg(context, 'Password updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Security', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  _row(Icons.password, const [Color(0xFFFFA23E), Color(0xFFC2570C)], 'Change password',
                      'Update your login password', () => _changePassword(context)),
                  _row(Icons.pin, const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], 'Transaction PIN',
                      'Approve payments with a PIN', () => _msg(context, 'Transaction PIN coming soon...')),
                  _row(Icons.fingerprint, const [Color(0xFF22C55E), Color(0xFF15803D)], 'Biometric login',
                      'Fingerprint or face unlock', () => _msg(context, 'Biometric settings coming soon...')),
                  _row(Icons.devices, const [Color(0xFF8B5CF6), Color(0xFF5B21B6)], 'Device management',
                      'See where you\'re logged in', () => _msg(context, 'Device management coming soon...'),
                      last: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _gold.withValues(alpha: 0.08),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: _gold, size: 24),
                      SizedBox(width: 10),
                      Text('Stay safe', style: TextStyle(color: _gold, fontSize: 17, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _Tip('Never share your password, PIN or OTP with anyone, including people who say they work for Mamash Pay.'),
                  _Tip('Use a password you don\'t use on any other app.'),
                  _Tip('Log out on shared or public phones.'),
                  _Tip('Check your transaction history often and report anything you don\'t recognise.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, List<Color> colors, String title, String sub, VoidCallback onTap, {bool last = false}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: Color(0xFF1B2A44))),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 26),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFD5DEF2), fontSize: 13.5, height: 1.35))),
        ],
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  static const Color _gold = Color(0xFFFFC83D);

  final _current = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _busy = false;
  String _error = '';

  @override
  void dispose() {
    _current.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      setState(() => _error = 'Please log in again and retry.');
      return;
    }
    if (_current.text.isEmpty) return setState(() => _error = 'Enter your current password');
    if (_new1.text.length < 8) return setState(() => _error = 'New password must be at least 8 characters');
    if (_new1.text != _new2.text) return setState(() => _error = 'New passwords don\'t match');
    if (_new1.text == _current.text) return setState(() => _error = 'New password must be different');

    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final cred = EmailAuthProvider.credential(email: email, password: _current.text);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_new1.text);
      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String m;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          m = 'Your current password is incorrect';
          break;
        case 'weak-password':
          m = 'Choose a stronger password';
          break;
        case 'too-many-requests':
          m = 'Too many attempts. Try again later.';
          break;
        default:
          m = e.message ?? 'Could not update password';
      }
      if (mounted) setState(() => _error = m);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not update password. Check your connection.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(String hint, TextEditingController c, bool visible, VoidCallback toggle) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF070D18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B2A44)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF9FB0D0), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: c,
              obscureText: !visible,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF7D8DB0), fontSize: 16),
              ),
            ),
          ),
          GestureDetector(
            onTap: toggle,
            child: Icon(visible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF9FB0D0), size: 22),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Change password',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _field('Current password', _current, _showCurrent, () => setState(() => _showCurrent = !_showCurrent)),
          _field('New password (8+ characters)', _new1, _showNew, () => setState(() => _showNew = !_showNew)),
          _field('Confirm new password', _new2, _showNew, () => setState(() => _showNew = !_showNew)),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(_error, style: const TextStyle(color: Color(0xFFFF5A67), fontSize: 13.5)),
            ),
          GestureDetector(
            onTap: _busy ? null : _submit,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27),
                gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
                boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 12)],
              ),
              child: Center(
                child: _busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3A2A00)))
                    : const Text('Update password',
                        style: TextStyle(color: Color(0xFF3A2A00), fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
