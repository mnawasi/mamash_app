import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'verification_kyc_page.dart';

class Tier3VerificationPage extends StatefulWidget {
  const Tier3VerificationPage({super.key});

  @override
  State<Tier3VerificationPage> createState() => _Tier3VerificationPageState();
}

class _Tier3VerificationPageState extends State<Tier3VerificationPage> {
  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _green = Color(0xFF22C55E);
  static const Color _line = Color(0xFF1B2A44);

  final _address = TextEditingController();
  final _picker = ImagePicker();
  XFile? _image;
  int _tier = 1;
  String _status = 'none'; // none, pending, rejected
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    int tier = 1;
    String status = 'none';
    String address = '';
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final d = doc.data();
        if (d != null) {
          final t = d['tier'];
          if (t is num) tier = t.toInt();
          if (t is String) tier = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          final verified = d['verified'] == true || d['isVerified'] == true || d['kycVerified'] == true;
          if (verified && tier < 2) tier = 2;
          if (d['tier3Status'] is String) status = d['tier3Status'] as String;
          if (d['address'] is String) address = (d['address'] as String).trim();
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _tier = tier;
      _status = status;
      _address.text = address;
      _loading = false;
    });
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
      if (x != null && mounted) setState(() => _image = x);
    } catch (_) {
      _msg('Could not open the ${source == ImageSource.camera ? 'camera' : 'gallery'}');
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _msg('Please log in again');
    if (_address.text.trim().length < 10) return _msg('Enter the full address on your bill');
    if (_image == null) return _msg('Add a photo of your NEPA bill');

    setState(() => _busy = true);
    try {
      final path = 'kyc/${user.uid}/utility_bill_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref(path);
      await ref.putFile(File(_image!.path), SettableMetadata(contentType: 'image/jpeg'));
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'tier3Status': 'pending',
        'tier3Address': _address.text.trim(),
        'tier3BillPath': path,
        'tier3SubmittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() {
        _status = 'pending';
        _image = null;
      });
      _msg('Submitted. We\'ll review your bill.');
    } catch (_) {
      _msg('Upload failed. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
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
        title: const Text('Tier 3 Verification',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: _content(),
            ),
    );
  }

  Widget _content() {
    if (_tier >= 3) {
      return _banner(Icons.verified_user, _green, 'You\'re on Tier 3', 'You can send up to \u20a630,000,000 per day.');
    }
    if (_tier < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _banner(Icons.lock_outline, _gold, 'Complete Tier 2 first',
              'Verify your BVN and ID, then come back to unlock Tier 3.'),
          const SizedBox(height: 18),
          _goldButton('Go to verification', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationKycPage()));
          }),
        ],
      );
    }
    if (_status == 'pending') {
      return _banner(Icons.hourglass_top, _gold, 'Under review',
          'We\'re checking your NEPA bill. This can take a little while.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_status == 'rejected') ...[
          _banner(Icons.error_outline, const Color(0xFFFF5A67), 'Verification failed',
              'Please upload a clearer, recent bill and try again.'),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: _gold.withValues(alpha: 0.08),
            border: Border.all(color: _gold.withValues(alpha: 0.5)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt, color: _gold, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Upload a recent NEPA (electricity) bill with your name and address on it. '
                  'This proves where you live and unlocks Tier 3.',
                  style: TextStyle(color: Color(0xFFD5DEF2), fontSize: 13.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        _label('Address on the bill'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: _box(),
          child: TextField(
            controller: _address,
            minLines: 3,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'House number, street, city, state',
              hintStyle: TextStyle(color: Color(0xFF7D8DB0), fontSize: 16),
            ),
          ),
        ),
        _label('Photo of your NEPA bill'),
        _imageBox(),
        const SizedBox(height: 22),
        _goldButton(_busy ? null : 'Submit for review', _busy ? null : _submit, busy: _busy),
      ],
    );
  }

  Widget _imageBox() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: _box(),
          clipBehavior: Clip.antiAlias,
          child: _image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, color: Color(0xFF6B7A9A), size: 48),
                    SizedBox(height: 8),
                    Text('No photo yet', style: TextStyle(color: Color(0xFF8FA3C8))),
                  ],
                )
              : Image.file(File(_image!.path), fit: BoxFit.cover),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _smallButton(Icons.photo_camera, 'Take photo', () => _pick(ImageSource.camera))),
            const SizedBox(width: 10),
            Expanded(child: _smallButton(Icons.photo_library, 'Choose photo', () => _pick(ImageSource.gallery))),
          ],
        ),
      ],
    );
  }

  Widget _smallButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _gold.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _gold, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: _gold, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _goldButton(String? label, VoidCallback? onTap, {bool busy = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Center(
          child: busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3A2A00)))
              : Text(label ?? '',
                  style: const TextStyle(color: Color(0xFF3A2A00), fontSize: 17, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _banner(IconData icon, Color color, String title, String sub) {
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

  BoxDecoration _box() => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(t, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 14, fontWeight: FontWeight.w600)),
      );
}
