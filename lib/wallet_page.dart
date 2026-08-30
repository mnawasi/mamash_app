import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// WalletPage
/// Shows the signed-in user's real wallet balance and their own recent
/// transactions — both pulled live from Firestore. New users start at
/// ₦0.00 with no transaction history; nothing here is shared between
/// accounts or hardcoded.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _balanceVisible = true;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? get _balanceStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('finance')
        .doc('summary')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _transactionsStream {
    final uid = _uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildTransactionsSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Wallet',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _balanceStream,
      builder: (context, snapshot) {
        final balance =
            (snapshot.data?.data()?['wallet'] as num?)?.toDouble() ?? 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _accentGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Wallet balance', style: TextStyle(color: Colors.black87, fontSize: 13)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _balanceVisible = !_balanceVisible),
                    child: Icon(
                      _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.black54,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _balanceVisible ? '₦${balance.toStringAsFixed(2)}' : '₦ ••••••',
                style: const TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionItem(Icons.add, 'Add Money'),
          _actionItem(Icons.arrow_upward_rounded, 'Send'),
          _actionItem(Icons.account_balance_wallet_outlined, 'Withdraw'),
          _actionItem(Icons.receipt_long_outlined, 'History'),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF163A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accentGreen, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent transactions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Text('See all', style: TextStyle(color: _accentGreen, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _transactionsStream,
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No transactions yet.',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) => _transactionTile(doc.data())).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> tx) {
    final bool isCredit = tx['type'] == 'credit';
    final String title = tx['title'] as String? ?? 'Transaction';
    final String subtitle = tx['subtitle'] as String? ?? '';
    final double amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final String sign = isCredit ? '+' : '-';
    final Timestamp? ts = tx['timestamp'] as Timestamp?;
    final String timeLabel = ts != null ? _formatTime(ts.toDate()) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCredit ? _accentGreen.withValues(alpha: 0.15) : const Color(0xFF3A1212),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isCredit ? _accentGreen : Colors.redAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign₦${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: isCredit ? _accentGreen : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(timeLabel, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $ampm';

    if (isToday) return 'Today, $timeStr';
    if (isYesterday) return 'Yesterday, $timeStr';

    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, $timeStr';
  }
}