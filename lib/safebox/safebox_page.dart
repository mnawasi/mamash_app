import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// SafeBoxPage
/// A locked savings space — funds a user sets aside and can't touch
/// until a chosen date. Balance is per-user and starts at 0.
class SafeBoxPage extends StatelessWidget {
  const SafeBoxPage({super.key});

  static const Color _bgDark = Color(0xFF111214);
  static const Color _cardDark = Color(0xFF1C1D20);
  static const Color _mint = Color(0xFF2ED9A5);

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get _stream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('finance')
        .doc('summary')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text('SafeBox', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snapshot) {
            final balance =
                (snapshot.data?.data()?['safeBox'] as num?)?.toDouble() ?? 0.0;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SafeBox Balance',
                          style: TextStyle(color: Colors.black87, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '₦ ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cardDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Lock Funds in SafeBox'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
