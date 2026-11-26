import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mamash_app/country_config.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveMoneyPage extends StatefulWidget {
  const ReceiveMoneyPage({super.key});

  @override
  State<ReceiveMoneyPage> createState() => _ReceiveMoneyPageState();
}

class _ReceiveMoneyPageState extends State<ReceiveMoneyPage> {
  static const Color _bg = Color(0xFF040C0B);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  bool _loading = true;
  String _name = '';
  String _account = '';
  String _phone = '';
  CountryConfig _country = CountryConfig.current;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    var name = user?.displayName ?? '';
    var account = '';
    var phone = '';
    var country = CountryConfig.current;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final d = doc.data();
        if (d != null) {
          for (final k in ['fullName', 'name', 'displayName']) {
            final v = d[k];
            if (v is String && v.trim().isNotEmpty) {
              name = v.trim();
              break;
            }
          }
          phone = ((d['phoneNumber'] ?? d['phone']) as String?)?.trim() ?? '';
          account = (d['accountNumber'] as String?)?.trim() ?? '';
          country = CountryConfig.fromName(d['country'] as String?);
        }
      } catch (_) {}
    }
    if (account.isEmpty && phone.isNotEmpty) {
      final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
      account =
          digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    }
    if (!mounted) return;
    setState(() {
      _name = name;
      _account = account;
      _phone = phone;
      _country = country;
      _loading = false;
    });
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label copied')));
  }

  void _copyAll() {
    final text = 'Send money to me on Mamash Pay\n'
        'Name: $_name\n'
        'Account number: $_account\n'
        'Wallet: ${_country.currencyName} (${_country.currencyCode})';
    _copy('Account details', text);
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text('Receive Money',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _qrCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: QrImageView(
              data: _account,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(_name.isEmpty ? 'Mamash Pay user' : _name.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          const Text('Scan to pay me on Mamash Pay',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {String? copyLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (copyLabel != null)
            IconButton(
              onPressed: () => _copy(copyLabel, value),
              icon: const Icon(Icons.copy, color: _green, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          _row('Account name', _name.isEmpty ? '-' : _name),
          const Divider(color: _line, height: 1),
          _row('Account number', _account, copyLabel: 'Account number'),
          const Divider(color: _line, height: 1),
          _row('Wallet',
              '${_country.currencyName} (${_country.currencyCode})'),
          if (_phone.isNotEmpty) ...[
            const Divider(color: _line, height: 1),
            _row('Phone', _phone, copyLabel: 'Phone number'),
          ],
        ],
      ),
    );
  }

  Widget _buttons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _copy('Account number', _account),
            icon: const Icon(Icons.copy, color: Colors.black),
            label: const Text('Copy account number',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _copyAll,
            icon: const Icon(Icons.share, color: _green),
            label: const Text('Copy all details',
                style: TextStyle(
                    color: _green, fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _note() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: _green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Other Mamash Pay users can send money to this account number '
              'or scan the QR code. Bank transfers will be available once '
              'we connect a banking partner.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
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
          child: Column(
            children: [
              _header(),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: _green))
                    : _account.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                  'We could not load your account details. '
                                  'Please try again.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70)),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                            child: Column(
                              children: [
                                _qrCard(),
                                const SizedBox(height: 16),
                                _detailsCard(),
                                const SizedBox(height: 20),
                                _buttons(),
                                const SizedBox(height: 16),
                                _note(),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
