import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'face_verification_page.dart';

class VerificationKycPage extends StatefulWidget {
  const VerificationKycPage({super.key});

  @override
  State<VerificationKycPage> createState() => _VerificationKycPageState();
}

class _VerificationKycPageState extends State<VerificationKycPage> {
  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _green = Color(0xFF22C55E);
  static const Color _line = Color(0xFF1B2A44);

  static const _idTypes = ['NIN', 'Driver\'s licence', 'Voter\'s card', 'International passport'];

  final _bvn = TextEditingController();
  final _idNumber = TextEditingController();
  String _idType = '';
  String _status = 'none'; // none, pending, verified, rejected
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bvn.dispose();
    _idNumber.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    String status = 'none';
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final d = doc.data();
        if (d != null) {
          if (d['verified'] == true || d['isVerified'] == true || d['kycVerified'] == true) {
            status = 'verified';
          } else if (d['kycStatus'] is String) {
            status = d['kycStatus'] as String;
          }
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _status = status;
      _loading = false;
    });
  }

  Future<void> _pickIdType() async {
    final t = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _idTypes
            .map((t) => ListTile(
                  title: Text(t, style: const TextStyle(color: Colors.white)),
                  trailing: t == _idType ? const Icon(Icons.check, color: _gold) : null,
                  onTap: () => Navigator.pop(context, t),
                ))
            .toList(),
      ),
    );
    if (t != null) setState(() => _idType = t);
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _msg('Please log in again');
    final bvn = _bvn.text.trim();
    final idNum = _idNumber.text.trim();
    if (bvn.length != 11) return _msg('BVN must be 11 digits');
    if (_idType.isEmpty) return _msg('Select an ID type');
    if (idNum.length < 6) return _msg('Enter a valid ID number');

    setState(() => _saving = true);
    try {
      // IMPORTANT: the full BVN and ID number are NOT saved to Firestore.
      // Send them to your verification provider through a secure backend
      // (e.g. a Cloud Function) here. Only a masked reference is stored.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'kycStatus': 'pending',
        'kycBvnLast4': bvn.substring(7),
        'kycIdType': _idType,
        'kycSubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _status = 'pending';
        _bvn.clear();
        _idNumber.clear();
      });
      _msg('Submitted for verification');
    } catch (_) {
      _msg('Could not submit. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: const Text('Verification & KYC',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusCard(),
                  if (_status == 'none' || _status == 'rejected') ...[
                    _step(1, 'Identity', 'Your Bank Verification Number'),
                    _label('BVN (11 digits)'),
                    _input(_bvn, Icons.badge_outlined, 'Enter your BVN', numeric: true, max: 11),
                    _step(2, 'ID document', 'A valid government-issued ID'),
                    _label('ID type'),
                    GestureDetector(
                      onTap: _pickIdType,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: _box(),
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined, color: Color(0xFF9FB0D0), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_idType.isEmpty ? 'Select ID type' : _idType,
                                  style: TextStyle(
                                      color: _idType.isEmpty ? const Color(0xFF7D8DB0) : Colors.white, fontSize: 16)),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    _label('ID number'),
                    _input(_idNumber, Icons.pin_outlined, 'Enter your ID number'),
                    _step(3, 'Selfie', 'Take a quick photo to confirm it\'s you'),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FaceVerificationPage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _box(),
                        child: const Row(
                          children: [
                            Icon(Icons.face_retouching_natural, color: _gold, size: 30),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text('Start selfie check',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    GestureDetector(
                      onTap: _saving ? null : _submit,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
                          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 12)],
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3A2A00)))
                              : const Text('Submit for verification',
                                  style: TextStyle(color: Color(0xFF3A2A00), fontSize: 18, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _statusCard() {
    late Color color;
    late IconData icon;
    late String title;
    late String sub;
    switch (_status) {
      case 'verified':
        color = _green;
        icon = Icons.verified_user;
        title = 'Verified';
        sub = 'Your account is fully verified.';
        break;
      case 'pending':
        color = _gold;
        icon = Icons.hourglass_top;
        title = 'Under review';
        sub = 'We\'re checking your details. This can take a little while.';
        break;
      case 'rejected':
        color = const Color(0xFFFF5A67);
        icon = Icons.error_outline;
        title = 'Verification failed';
        sub = 'Please check your details and submit again.';
        break;
      default:
        color = const Color(0xFF8FA3C8);
        icon = Icons.shield_outlined;
        title = 'Not verified';
        sub = 'Verify your identity to unlock higher limits.';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: Color(0xFFC6D2EA), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int n, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: _gold,
            child: Text('$n', style: const TextStyle(color: Color(0xFF3A2A00), fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                Text(sub, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(t, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _input(TextEditingController c, IconData icon, String hint, {bool numeric = false, int? max}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _box(),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9FB0D0), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                if (numeric) FilteringTextInputFormatter.digitsOnly,
                if (max != null) LengthLimitingTextInputFormatter(max),
              ],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF7D8DB0), fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
