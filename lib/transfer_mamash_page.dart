import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'country_config.dart';
import 'send_common.dart';

class TransferMamashPage extends StatefulWidget {
  const TransferMamashPage({super.key});

  @override
  State<TransferMamashPage> createState() => _TransferMamashPageState();
}

class _TransferMamashPageState extends State<TransferMamashPage> {
  CountryConfig _country = CountryConfig.all.first;
  bool _phoneMode = true;
  final _recipient = TextEditingController();
  final _note = TextEditingController();
  int? _amount;

  @override
  void initState() {
    super.initState();
    loadUserCountry().then((c) {
      if (mounted) setState(() => _country = c);
    });
  }

  @override
  void dispose() {
    _recipient.dispose();
    _note.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String get _digits => _recipient.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');

  Future<void> _continue() async {
    if (_phoneMode) {
      if (_digits.length < 7 || _digits.length > 11) return _msg('Enter a valid phone number');
    } else {
      if (!RegExp(r'^[A-Za-z0-9_.]{3,}$').hasMatch(_recipient.text.trim())) {
        return _msg('Enter a valid username');
      }
    }
    final amt = _amount;
    if (amt == null || amt < minAmount(_country)) {
      return _msg('Minimum amount is ${_country.symbol}${fmtNumber(minAmount(_country))}');
    }

    final to = _phoneMode ? '${_country.dial} $_digits' : '@${_recipient.text.trim()}';
    final ok = await confirmSend(context, 'Confirm transfer', [
      'To: $to',
      'Amount: ${_country.symbol}${fmtNumber(amt)} ${_country.currencyCode}',
      if (_note.text.trim().isNotEmpty) 'Note: ${_note.text.trim()}',
    ]);
    if (ok) _send();
  }

  // TODO: connect real sending here. It must run on your server (a Cloud Function) that finds
  // the recipient, checks the balance and the user's tier limit, then moves the money in one step.
  void _send() {
    _msg('Sending is not connected yet');
  }

  @override
  Widget build(BuildContext context) {
    return SendShell(
      title: 'Transfer to Mamash',
      subtitle: 'Send money to another Mamash wallet',
      children: [
        const SendBanner(
          icon: Icons.send,
          title: 'Send to a Mamash user',
          subtitle: 'Enter their phone number or username and choose an amount.',
        ),
        SendPanel(
          title: 'Recipient',
          icon: Icons.person_outline,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SendTheme.inner,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: SendTheme.innerLine),
                ),
                child: Row(
                  children: [
                    _modeTab('Phone number', true),
                    _modeTab('Username', false),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SendField(
                controller: _recipient,
                hint: _phoneMode ? 'Phone number' : 'Username',
                icon: _phoneMode ? null : Icons.alternate_email,
                prefix: _phoneMode
                    ? Text(_country.dial, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))
                    : null,
                keyboard: _phoneMode ? TextInputType.phone : TextInputType.text,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
              ),
              const SizedBox(height: 8),
              _recent(),
            ],
          ),
        ),
        SendPanel(
          title: 'Amount',
          icon: Icons.payments_outlined,
          child: Column(
            children: [
              AmountPicker(country: _country, onChanged: (v) => setState(() => _amount = v)),
              const SizedBox(height: 10),
              SendField(
                controller: _note,
                hint: 'Add a note (optional)',
                icon: Icons.edit_note,
                maxLength: 60,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SendButton(label: 'Continue', icon: Icons.send, onTap: _continue),
      ],
    );
  }

  Widget _modeTab(String label, bool phone) {
    final sel = _phoneMode == phone;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _phoneMode = phone;
          _recipient.clear();
        }),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: sel ? const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF14C98B)]) : null,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: sel ? Colors.black : Colors.white70, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _recent() {
    const empty = Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Text('No recent transfers yet', style: TextStyle(color: Colors.white38, fontSize: 13.5)),
    );
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return empty;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recentRecipients')
          .orderBy('lastAt', descending: true)
          .limit(6)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return empty;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: docs.map((d) {
              final m = d.data();
              final name = (m['name'] ?? '') as String;
              final phone = (m['phone'] ?? '') as String;
              final initials = name.trim().isEmpty
                  ? '?'
                  : name.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0].toUpperCase()).join();
              return GestureDetector(
                onTap: () {
                  if (phone.isEmpty) return;
                  setState(() {
                    _phoneMode = true;
                    _recipient.text = phone.startsWith(_country.dial)
                        ? phone.substring(_country.dial.length)
                        : phone.replaceFirst('+', '');
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: SendTheme.green.withValues(alpha: 0.2),
                        child: Text(initials, style: const TextStyle(color: SendTheme.green, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: Text(name.split(' ').first,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
