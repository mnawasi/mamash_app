import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  CollectionReference<Map<String, dynamic>>? get _col {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications');
  }

  DateTime _dateOf(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final t = d.data()['createdAt'];
    return t is Timestamp ? t.toDate() : DateTime.now();
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  (IconData, Color) _look(String? type) {
    switch (type) {
      case 'credit':
        return (Icons.south_west, const Color(0xFF22C55E));
      case 'debit':
        return (Icons.north_east, const Color(0xFFFF8A3D));
      case 'gift':
        return (Icons.card_giftcard, const Color(0xFFEC4899));
      case 'reward':
        return (Icons.emoji_events, const Color(0xFFFFC53D));
      case 'security':
        return (Icons.shield, const Color(0xFF3B82F6));
      default:
        return (Icons.info_outline, const Color(0xFFB36BFF));
    }
  }

  Future<void> _markAllRead(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final d in docs) {
      if (d.data()['read'] != true) batch.update(d.reference, {'read': true});
    }
    try {
      await batch.commit();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not update. Please try again.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final col = _col;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: col == null
          ? _message(Icons.lock_outline, 'Please log in', 'Log in to see your notifications.')
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: col.orderBy('createdAt', descending: true).limit(100).snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return _message(Icons.error_outline, 'Could not load notifications', 'Please try again later.');
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _green));
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return _message(Icons.notifications_none, 'No notifications yet',
                      'Updates about your payments and rewards will show up here.');
                }
                final unread = docs.where((d) => d.data()['read'] != true).length;
                final groups = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
                for (final d in docs) {
                  groups.putIfAbsent(_dayLabel(_dateOf(d)), () => []).add(d);
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    if (unread > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _markAllRead(docs),
                          icon: const Icon(Icons.done_all, color: _green, size: 20),
                          label: Text('Mark all as read ($unread)', style: const TextStyle(color: _green)),
                        ),
                      ),
                    ...groups.entries.expand((e) => [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
                            child: Text(e.key,
                                style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5, fontWeight: FontWeight.w700)),
                          ),
                          ...e.value.map(_tile),
                        ]),
                  ],
                );
              },
            ),
    );
  }

  Widget _tile(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    final unread = m['read'] != true;
    final (icon, color) = _look(m['type'] as String?);
    return GestureDetector(
      onTap: () {
        if (unread) d.reference.update({'read': true}).catchError((_) {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFF0B2F28) : _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: unread ? _green.withValues(alpha: 0.5) : _line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color.withValues(alpha: 0.18)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text((m['title'] ?? '') as String,
                            style: TextStyle(
                                color: Colors.white, fontSize: 15.5, fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                      ),
                      if (unread) Container(width: 9, height: 9, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text((m['subtitle'] ?? '') as String,
                      style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13, height: 1.35)),
                  const SizedBox(height: 6),
                  Text(_time(_dateOf(d)), style: const TextStyle(color: Color(0xFF7FA39C), fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: 0.1),
                border: Border.all(color: _green.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: _green, size: 40),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13.5, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
