import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Play4aChildPage extends StatefulWidget {
  const Play4aChildPage({super.key});

  @override
  State<Play4aChildPage> createState() => _Play4aChildPageState();
}

class _Play4aChildPageState extends State<Play4aChildPage> {
  static const Color _bg = Color(0xFF110C03);
  static const Color _panel = Color(0xFF1E1608);
  static const Color _gold = Color(0xFFFFC53D);
  static const Color _line = Color(0xFF4A3812);

  bool _interested = false;
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    bool interested = false;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        interested = doc.data()?['play4achildInterest'] == true;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _interested = interested;
      _loading = false;
    });
  }

  Future<void> _notify() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'play4achildInterest': true,
        'play4achildInterestAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _interested = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Check your connection and try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Play4aChild',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(),
            const SizedBox(height: 16),
            _about(),
            const SizedBox(height: 16),
            _steps(),
            const SizedBox(height: 20),
            _action(),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7A4E0B), Color(0xFF4A3008), Color(0xFF2A1C06)],
        ),
        border: Border.all(color: _gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(colors: [Color(0xFFFFC53D), Color(0xFFB8740A)]),
              boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 16)],
            ),
            child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 42),
          ),
          const SizedBox(height: 14),
          const Text('Play4aChild',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Support children', style: TextStyle(color: Color(0xFFFFE3A3), fontSize: 15)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3A2E0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8B83D)),
            ),
            child: const Text('Coming soon',
                style: TextStyle(color: Color(0xFFFFD66B), fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text(
            // Edit this text to describe exactly how Play4aChild works.
            'Play4aChild is a Mamash initiative that lets you support children right from your wallet. '
            'Every contribution helps make a difference.',
            style: TextStyle(color: Color(0xFFE3D8BE), fontSize: 14.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _steps() {
    Widget step(IconData icon, String title, String sub) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _gold.withValues(alpha: 0.12),
                border: Border.all(color: _gold.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: _gold, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(color: Color(0xFFCDBF9C), fontSize: 12.5, height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How it works', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          step(Icons.touch_app, 'Choose how to help', 'Pick an amount or activity you want to support.'),
          step(Icons.account_balance_wallet, 'Confirm from your wallet', 'Your contribution is taken from your Mamash wallet.'),
          step(Icons.favorite, 'See your impact', 'Follow what your support has done for children.'),
        ],
      ),
    );
  }

  Widget _action() {
    if (_interested) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _gold.withValues(alpha: 0.12),
          border: Border.all(color: _gold),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: _gold, size: 22),
            SizedBox(width: 10),
            Text('You\'re on the list', style: TextStyle(color: _gold, fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: (_busy || _loading) ? null : _notify,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 12)],
        ),
        child: Center(
          child: _busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3A2A00)))
              : const Text('Notify me when it opens',
                  style: TextStyle(color: Color(0xFF3A2A00), fontSize: 17, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
