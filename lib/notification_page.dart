import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final Map<String, List<Map<String, dynamic>>> _grouped = {
    'Today': [
      {
        'title': 'Money received',
        'subtitle': 'You received ₦20,000 from Amina Yusuf',
        'time': '10:24 AM',
        'icon': Icons.arrow_downward_rounded,
        'iconColor': _accentGreen,
        'iconBg': const Color(0xFF163A2E),
        'read': false,
      },
      {
        'title': 'Cashback earned',
        'subtitle': 'You earned ₦15 cashback on a data purchase',
        'time': '10:26 AM',
        'icon': Icons.card_giftcard,
        'iconColor': Colors.amber,
        'iconBg': const Color(0xFF3A2A12),
        'read': false,
      },
    ],
    'Yesterday': [
      {
        'title': 'Bill payment successful',
        'subtitle': 'Your IKEDC electricity bill of ₦5,000 was paid',
        'time': '1:18 PM',
        'icon': Icons.bolt,
        'iconColor': Colors.lightBlueAccent,
        'iconBg': const Color(0xFF122A3A),
        'read': true,
      },
      {
        'title': 'Security alert',
        'subtitle': 'A new device logged into your account',
        'time': '8:02 AM',
        'icon': Icons.shield_outlined,
        'iconColor': Colors.redAccent,
        'iconBg': const Color(0xFF3A1212),
        'read': true,
      },
    ],
    'Jul 20, 2026': [
      {
        'title': 'Welcome to Mamash Pay',
        'subtitle': 'Complete your KYC to unlock higher limits',
        'time': '9:00 AM',
        'icon': Icons.info_outline,
        'iconColor': Colors.purpleAccent,
        'iconBg': const Color(0xFF2E1636),
        'read': true,
      },
    ],
  };

  void _markAllRead() {
    setState(() {
      for (final list in _grouped.values) {
        for (final n in list) {
          n['read'] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _grouped.values.every((l) => l.isEmpty)
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: _grouped.entries
                          .where((e) => e.value.isNotEmpty)
                          .map((e) => _buildGroup(e.key, e.value))
                          .toList(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Notifications',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: _accentGreen, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String label, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _cardDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  _notificationTile(entry.value),
                  if (!isLast) const Divider(color: Colors.white12, height: 1),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _notificationTile(Map<String, dynamic> n) {
    final bool read = n['read'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: n['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(n['icon'] as IconData, color: n['iconColor'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n['title'] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: read ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  n['subtitle'] as String,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  n['time'] as String,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, color: Colors.white24, size: 56),
          SizedBox(height: 12),
          Text('No notifications yet', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}
