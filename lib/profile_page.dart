import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarSection(),
                    const SizedBox(height: 16),
                    _buildFieldsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'My Profile',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFF262626),
                child: Icon(Icons.person, color: Colors.white38, size: 44),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.black87, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your name',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          _accountRow('Account number', '—', trailingIcon: Icons.copy, iconColor: Colors.white38),
          const SizedBox(height: 14),
          _accountRow(
            'Account tier',
            null,
            customTrailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.workspace_premium, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text('Tier 1', style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            trailingIcon: Icons.chevron_right,
          ),
        ],
      ),
    );
  }

  Widget _accountRow(String label, String? value, {IconData? trailingIcon, Color? iconColor, Widget? customTrailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Row(
          children: [
            if (customTrailing != null) customTrailing,
            if (value != null)
              Text(value, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, color: iconColor ?? Colors.white38, size: 16),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFieldsCard() {
    final fields = [
      {'label': 'Full name', 'value': '—', 'editable': true},
      {'label': 'Mobile number', 'value': '—', 'editable': true},
      {'label': 'Nickname', 'value': '—', 'editable': true},
      {'label': 'Gender', 'value': '—', 'editable': false},
      {'label': 'Date of birth', 'value': '—', 'editable': false},
      {'label': 'Email', 'value': '—', 'editable': true},
      {'label': 'Address', 'value': '—', 'editable': true},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: fields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          final isLast = index == fields.length - 1;
          return Column(
            children: [
              _fieldTile(field['label'] as String, field['value'] as String, field['editable'] as bool),
              if (!isLast) const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _fieldTile(String label, String value, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Row(
            children: [
              Text(value, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              if (editable) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
