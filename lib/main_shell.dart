import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'rewards/rewards_page.dart';
import 'finance/finance_page.dart';
import 'cards/cards_page.dart';
import 'profile_page.dart';

/// Lets any page switch tabs: ShellNav.index.value = 0 (Home), 1 Rewards, 2 Finance, 3 Cards, 4 Me.
class ShellNav {
  static final ValueNotifier<int> index = ValueNotifier<int>(0);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const Color _bg = Color(0xFF07100F);
  static const Color _green = Color(0xFF16C784);

  static const List<Widget> _pages = [
    DashboardPage(),
    RewardsPage(),
    FinancePage(),
    CardsPage(),
    ProfilePage(),
  ];

  final List<bool> _visited = [true, false, false, false, false];
  bool _rewardsSeen = false;

  @override
  void initState() {
    super.initState();
    ShellNav.index.value = 0;
    ShellNav.index.addListener(_onChange);
  }

  @override
  void dispose() {
    ShellNav.index.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    setState(() {
      final i = ShellNav.index.value;
      _visited[i] = true;
      if (i == 1) _rewardsSeen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final index = ShellNav.index.value;
    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) ShellNav.index.value = 0;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050A0D),
        body: IndexedStack(
          index: index,
          children: List.generate(_pages.length, (i) => _visited[i] ? _pages[i] : const SizedBox.shrink()),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => ShellNav.index.value = i,
          backgroundColor: _bg,
          selectedItemColor: _green,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.card_giftcard_outlined),
                  if (!_rewardsSeen)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
              label: 'Rewards',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Finance'),
            const BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: 'Cards'),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
          ],
        ),
      ),
    );
  }
}
