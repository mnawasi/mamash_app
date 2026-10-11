import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalInformationPage extends StatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _line = Color(0xFF1B2A44);

  final _name = TextEditingController();
  final _address = TextEditingController();
  String _gender = '';
  String _email = '';
  String _phone = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    String name = user.displayName ?? '';
    String email = user.email ?? '';
    String phone = user.phoneNumber ?? '';
    String gender = '';
    String address = '';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = doc.data();
      if (d != null) {
        String pick(List<String> keys) {
          for (final k in keys) {
            final v = d[k];
            if (v is String && v.trim().isNotEmpty) return v.trim();
          }
          return '';
        }

        final n = pick(['fullName', 'name', 'displayName', 'username']);
        if (n.isNotEmpty) name = n;
        final e = pick(['email']);
        if (e.isNotEmpty) email = e;
        final p = pick(['phone', 'phoneNumber']);
        if (p.isNotEmpty) phone = p;
        gender = pick(['gender']);
        address = pick(['address']);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _name.text = name;
      _address.text = address;
      _gender = gender;
      _email = email;
      _phone = phone;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _msg('Please log in again');
    final name = _name.text.trim();
    if (name.length < 2) return _msg('Enter your full name');
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        'gender': _gender,
        'address': _address.text.trim(),
      }, SetOptions(merge: true));
      await user.updateDisplayName(name);
      if (!mounted) return;
      _msg('Personal information saved');
      Navigator.pop(context);
    } catch (_) {
      _msg('Could not save. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickGender() async {
    final g = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: ['Male', 'Female', 'Prefer not to say']
            .map((g) => ListTile(
                  title: Text(g, style: const TextStyle(color: Colors.white)),
                  trailing: g == _gender ? const Icon(Icons.check, color: _gold) : null,
                  onTap: () => Navigator.pop(context, g),
                ))
            .toList(),
      ),
    );
    if (g != null) setState(() => _gender = g);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Personal Information',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Full name'),
                  _input(_name, Icons.person_outline, 'Enter your full name'),
                  _label('Email'),
                  _readOnly(Icons.mail_outline, _email.isEmpty ? 'Not set' : _email),
                  _label('Phone number'),
                  _readOnly(Icons.phone_outlined, _phone.isEmpty ? 'Not set' : _phone),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Email and phone can\'t be changed here. Contact support to update them.',
                        style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 12)),
                  ),
                  _label('Gender'),
                  GestureDetector(
                    onTap: _pickGender,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: _box(),
                      child: Row(
                        children: [
                          const Icon(Icons.wc, color: Color(0xFF9FB0D0), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(_gender.isEmpty ? 'Select gender' : _gender,
                                style: TextStyle(
                                    color: _gender.isEmpty ? const Color(0xFF7D8DB0) : Colors.white, fontSize: 16)),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  _label('Address'),
                  _input(_address, Icons.home_outlined, 'House number, street, city, state', lines: 3),
                  const SizedBox(height: 26),
                  GestureDetector(
                    onTap: _saving ? null : _save,
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
                            : const Text('Save changes',
                                style: TextStyle(color: Color(0xFF3A2A00), fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _input(TextEditingController c, IconData icon, String hint, {int lines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: _box(),
      child: Row(
        crossAxisAlignment: lines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: lines > 1 ? 14 : 0),
            child: Icon(icon, color: const Color(0xFF9FB0D0), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: c,
              minLines: lines,
              maxLines: lines,
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

  Widget _readOnly(IconData icon, String value) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _box().copyWith(color: const Color(0xFF070D18)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6B7A9A), size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF9FB0D0), fontSize: 16))),
          const Icon(Icons.lock_outline, color: Color(0xFF6B7A9A), size: 18),
        ],
      ),
    );
  }
}
