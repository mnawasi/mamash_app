import 'package:flutter/material.dart';

/// Placeholder Rewards page.
///
/// TODO: Replace this with the real Rewards feature (points balance,
/// redeemable offers, referral bonuses, etc.) once that's built.
class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  static const Color _bgColor = Color(0xFF111214);
  static const Color _cardColor = Color(0xFF1C1D20);
  static const Color _accent = Color(0xFF16C784);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        title: const Text("Rewards", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: _cardColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_outlined,
                  size: 48,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Rewards coming soon",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Points, offers, and referral bonuses will be available here soon.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
