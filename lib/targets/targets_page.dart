import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// TargetsPage
/// Lets a user create a named savings target (e.g. "New Phone",
/// "Rent 2027") with a goal amount, then track progress toward it.
/// Each user only ever sees their own targets — nothing is shared.
class TargetsPage extends StatefulWidget {
  const TargetsPage({super.key});

  @override
  State<TargetsPage> createState() => _TargetsPageState();
}

class _TargetsPageState extends State<TargetsPage> {
  static const Color _bgDark = Color(0xFF111214);
  static const Color _cardDark = Color(0xFF1C1D20);
  static const Color _mint = Color(0xFF2ED9A5);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _targetsRef {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('targets');
  }

  Future<void> _createTarget() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Target',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Target name (e.g. New Phone)',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Target amount (₦)',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final amount = double.tryParse(amountController.text.trim());
                    if (name.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a name and a valid amount'),
                        ),
                      );
                      return;
                    }
                    final ref = _targetsRef;
                    if (ref == null) return;
                    await ref.add({
                      'name': name,
                      'targetAmount': amount,
                      'savedAmount': 0,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mint,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Create Target',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target created')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = _targetsRef;

    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text('Targets', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTarget,
        backgroundColor: _mint,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('New Target',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ref == null
          ? const Center(
              child: Text('Sign in to view your targets',
                  style: TextStyle(color: Colors.white54)),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ref.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No targets yet. Tap "New Target" to fix a goal '
                        'and start saving toward it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final name = d['name'] as String? ?? 'Target';
                    final targetAmount =
                        (d['targetAmount'] as num?)?.toDouble() ?? 0.0;
                    final savedAmount =
                        (d['savedAmount'] as num?)?.toDouble() ?? 0.0;
                    final progress = targetAmount > 0
                        ? (savedAmount / targetAmount).clamp(0.0, 1.0)
                        : 0.0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₦${savedAmount.toStringAsFixed(2)} of ₦${targetAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  _accentGreen),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
