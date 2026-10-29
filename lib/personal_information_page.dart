import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'country_config.dart';

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
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _gender = '';
  String _email = '';
  CountryConfig _country = CountryConfig.all.first;
  bool _loading = true;
  bool _saving = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
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
    CountryConfig country = CountryConfig.all.first;
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
        country = CountryConfig.fromName(d['country'] as String?);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load your details: $e');
    }
    // Show the phone number without the country code.
    String local = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (local.startsWith(country.dial)) {
      local = local.substring(country.dial.length);
    }
    local = local.replaceAll('+', '').replaceFirst(RegExp(r'^0+'), '');
    if (!mounted) return;
    setState(() {
      _name.text = name;
      _phone.text = local;
      _address.text = address;
      _gender = gender;
      _email = email;
      _country = country;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return setState(() => _error = 'Please log in again');
    final name = _name.text.trim();
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');
    if (name.length < 2) return setState(() => _error = 'Enter your full name');
    if (digits.isNotEmpty && (digits.length < 7 || digits.length > 11)) {
      return setState(() => _error = 'Enter a valid phone number');
    }
    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      final full = digits.isEmpty ? null : '${_country.dial}$digits';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fullName': name,
        'name': name,
        'gender': _gender,
        'address': _address.text.trim(),
        if (full != null) ...{'phone': full, 'phoneNumber': full},
      }, SetOptions(merge: true));
      try {
        await user.updateDisplayName(name);
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal information saved')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickGender() async {
    final g = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: ['Male', 'Female', 'Prefer not to say']
              .map((g) => ListTile(
                    title: Text(g, style: const TextStyle(color: Colors.white)),
                    trailing: g == _gender ? const Icon(Icons.check, color: _gold) : null,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Full name'),
                  _box(TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: _gold,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: _dec('Enter your full name'),
                  ), Icons.person_outline),
                  _label('Email'),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070D18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Color(0xFF6B7A9A), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_email.isEmpty ? 'Not set' : _email,
                              style: const TextStyle(color: Color(0xFF9FB0D0), fontSize: 16)),
                        ),
                        const Icon(Icons.lock_outline, color: Color(0xFF6B7A9A), size: 18),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Your email can\'t be changed here.', style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 12)),
                  ),
                  _label('Phone number'),
                  _box(
                    Row(
                      children: [
                        Text('${_country.flag} ${_country.dial}',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Container(width: 1, height: 24, color: Colors.white24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]'))],
                            cursorColor: _gold,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: _dec('Phone number'),
                          ),
                        ),
                      ],
                    ),
                    Icons.phone_outlined,
                  ),
                  _label('Gender'),
                  GestureDetector(
                    onTap: _pickGender,
                    child: _box(
                      Row(
                        children: [
                          Expanded(
                            child: Text(_gender.isEmpty ? 'Select gender' : _gender,
                                style: TextStyle(color: _gender.isEmpty ? const Color(0xFF7D8DB0) : Colors.white, fontSize: 16)),
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        ],
                      ),
                      Icons.wc,
                    ),
                  ),
                  _label('Address'),
                  _box(
                    TextField(
                      controller: _address,
                      minLines: 3,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: _gold,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: _dec('House number, street, city, state'),
                    ),
                    Icons.home_outlined,
                    tall: true,
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(_error, style: const TextStyle(color: Color(0xFFFF5A67), fontSize: 13.5, height: 1.4)),
                    ),
                  const SizedBox(height: 22),
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(t, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _box(Widget child, IconData icon, {bool tall = false}) {
    return Container(
      constraints: BoxConstraints(minHeight: tall ? 96 : 56),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: tall ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: tall ? 14 : 0),
            child: Icon(icon, color: const Color(0xFF9FB0D0), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
        isDense: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7D8DB0), fontSize: 16),
      );
}
