import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingChallengePage extends StatelessWidget {
  const SavingChallengePage({super.key});

  static const Color _bgDark = Color(0xFF111214);
  static const Color _cardDark = Color(0xFF1C1D20);
  static const Color _gold = Color(0xFFF4C15C);

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get _stream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savingChallenge')
        .doc('2026')
        .snapshots();
  }

  Future<void> _joinChallenge(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savingChallenge')
        .doc('2026')
        .set({
      'joined': true,
      'streakDays': 0,
      'totalSaved': 0,
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You\'re in! Start saving daily.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text('Saving Challenge 2026',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final joined = data?['joined'] as bool? ?? false;
            final streakDays = (data?['streakDays'] as num?)?.toInt() ?? 0;
            final totalSaved =
                (data?['totalSaved'] as num?)?.toDouble() ?? 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B2B1F), Color(0xFF1B4D3A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start small daily, finish big in 2026',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _statTile('Streak', '$streakDays days'),
                          ),
                          Expanded(
                            child: _statTile(
                              'Total Saved',
                              '₦${totalSaved.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (!joined)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _joinChallenge(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Start Saving Now',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "You're enrolled. Keep your streak going by saving "
                      "something every day.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
