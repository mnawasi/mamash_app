import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'finance_common.dart';

class _Info {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String intro;
  final List<(IconData, String, String)> benefits;
  final List<String> steps;
  final String field;
  const _Info(this.title, this.subtitle, this.icon, this.color, this.intro, this.benefits, this.steps, this.field);
}

class _FeaturePage extends StatefulWidget {
  final _Info info;
  const _FeaturePage(this.info);

  @override
  State<_FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<_FeaturePage> {
  bool _on = false;
  bool _busy = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    bool on = false;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        on = doc.data()?[widget.info.field] == true;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _on = on;
      _loading = false;
    });
  }

  Future<void> _join() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        widget.info.field: true,
        '${widget.info.field}At': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) setState(() => _on = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.info;
    return FinScaffold(
      title: i.title,
      subtitle: i.subtitle,
      accent: i.color,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [i.color.withValues(alpha: 0.45), i.color.withValues(alpha: 0.12)],
            ),
            border: Border.all(color: i.color.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: i.color.withValues(alpha: 0.9)),
                child: Icon(i.icon, color: Colors.white, size: 38),
              ),
              const SizedBox(height: 12),
              Text(i.intro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45)),
              const SizedBox(height: 12),
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
        ),
        FinPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What you\'ll get', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ...i.benefits.map((b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: i.color.withValues(alpha: 0.15),
                            border: Border.all(color: i.color.withValues(alpha: 0.5)),
                          ),
                          child: Icon(b.$1, color: i.color, size: 23),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(b.$2, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              Text(b.$3, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 12.5, height: 1.35)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        FinPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How it works', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              for (int n = 0; n < i.steps.length; n++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: i.color,
                        child: Text('${n + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(i.steps[n], style: const TextStyle(color: Color(0xFFD5E8E4), fontSize: 14, height: 1.4)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (_on)
          Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(27),
              color: FT.green.withValues(alpha: 0.12),
              border: Border.all(color: FT.green),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: FT.green, size: 22),
                SizedBox(width: 8),
                Text('You\'re on the list', style: TextStyle(color: FT.green, fontSize: 16.5, fontWeight: FontWeight.w800)),
              ],
            ),
          )
        else
          FinButton(
            label: 'Notify me when it opens',
            icon: Icons.notifications_active,
            busy: _busy || _loading,
            onTap: _join,
          ),
      ],
    );
  }
}

class SafeBoxPage extends StatelessWidget {
  const SafeBoxPage({super.key});

  @override
  Widget build(BuildContext context) => const _FeaturePage(_Info(
        'SafeBox',
        'Lock money away until you need it',
        Icons.lock_outline,
        Color(0xFF3B82F6),
        'Put money in a SafeBox and keep it out of reach until the date you choose.',
        [
          (Icons.lock_clock, 'Locked until your date', 'You pick when your money unlocks, so it stays safe from impulse spending.'),
          (Icons.shield_outlined, 'Extra protection', 'Money in a SafeBox is kept apart from your everyday wallet.'),
          (Icons.visibility_outlined, 'Clear terms up front', 'You see the full terms before you lock anything.'),
        ],
        [
          'Choose how much to lock and for how long.',
          'Confirm and move the money from your wallet.',
          'Get it back, with any reward, when the date arrives.',
        ],
        'safeboxInterest',
      ));
}

class FixedSavingsPage extends StatelessWidget {
  const FixedSavingsPage({super.key});

  @override
  Widget build(BuildContext context) => const _FeaturePage(_Info(
        'Fixed Savings',
        'Save for a set period',
        Icons.bar_chart,
        Color(0xFFFFB02E),
        'Commit an amount for a fixed period and know what you will earn before you start.',
        [
          (Icons.event_available, 'You choose the period', 'Pick a savings period that suits you.'),
          (Icons.percent, 'Return shown before you start', 'The terms and any return are shown clearly before you confirm.'),
          (Icons.account_balance_wallet_outlined, 'Paid back to your wallet', 'Your money goes back to your wallet when the plan ends.'),
        ],
        [
          'Choose an amount and a savings period.',
          'Review the terms and confirm.',
          'Your plan matures and the money returns to your wallet.',
        ],
        'fixedSavingsInterest',
      ));
}

class SpendSavePage extends StatelessWidget {
  const SpendSavePage({super.key});

  @override
  Widget build(BuildContext context) => const _FeaturePage(_Info(
        'Spend & Save',
        'Save automatically as you spend',
        Icons.spa_outlined,
        Color(0xFF22C55E),
        'Set a small share of what you spend and let it move into your savings by itself.',
        [
          (Icons.tune, 'You set the amount', 'Choose how much to set aside each time you pay.'),
          (Icons.autorenew, 'Fully automatic', 'No reminders and no extra steps. Saving happens as you spend.'),
          (Icons.pause_circle_outline, 'Pause any time', 'Switch it off whenever you like.'),
        ],
        [
          'Turn on Spend & Save and choose your share.',
          'Pay for things as usual.',
          'The share you chose moves into your savings automatically.',
        ],
        'spendSaveInterest',
      ));
}
