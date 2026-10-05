import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rewards/rewards_page.dart';
import 'send_money_page.dart';
import 'receive_money_page.dart';
import 'add_money_page.dart';
import 'airtime_page.dart';
import 'buy_data_page.dart';
import 'bill_payment_page.dart';
import 'betting_page.dart';
import 'survey_page.dart';
import 'international_transfer_page.dart';
import 'ai/ai_assistant_page.dart';
import 'transaction_history_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'wallet_page.dart';
import 'cards/cards_page.dart';
import 'finance/finance_page.dart';
import 'flight_pay_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const double _nairaBalance = 0.00;
  static const double _dollarBalance = 0.00;
  static const int _unreadNotifications = 3;

  bool _balanceHidden = false;
  int _selectedNavIndex = 0;
  String _accountNumber = '';
  String _dollarAccountNumber = '';

  static const Color _green = Color(0xFF16C784);
  static const Color _panel = Color(0xFF0A1A1F);

  static const _sendPts = [Offset(.5, 0), Offset(1, .68), Offset(.86, 1), Offset(.14, 1), Offset(0, .68)];
  static const _recvPts = [Offset(.5, 0), Offset(1, .14), Offset(1, 1), Offset(.12, 1), Offset(0, .86)];
  static const _wdPts = [Offset(.5, 0), Offset(0, .14), Offset(0, 1), Offset(.88, 1), Offset(1, .86)];

  @override
  void initState() {
    super.initState();
    _loadAccountNumbers();
  }

  Future<void> _loadAccountNumbers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _accountNumber = doc.data()?['accountNumber'] ?? '';
        _dollarAccountNumber = doc.data()?['dollarAccountNumber'] ?? '';
      });
    }
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what coming soon...')));
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account number copied')));
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  bool get _isDay => DateTime.now().hour < 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF05241C), Color(0xFF050A0D), Color(0xFF061427)],
            stops: [0, .45, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 16),
                _balanceCard(),
                const SizedBox(height: 6),
                _hero(),
                const SizedBox(height: 10),
                _actionRow(),
                const SizedBox(height: 12),
                _servicesPanel(),
                const SizedBox(height: 12),
                _flightBanner(),
                const SizedBox(height: 10),
                _earnBanner(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ---------- Header ----------
  Widget _header() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _green, width: 2)),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF1C1D20),
            child: Icon(Icons.person, color: Colors.white70),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Hi, Mamash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: _green, size: 18),
                  ],
                ),
                Row(
                  children: [
                    Text(_greeting, style: const TextStyle(color: Color(0xFF7FE3C0), fontSize: 14)),
                    const SizedBox(width: 4),
                    Icon(_isDay ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.amber, size: 14),
                  ],
                ),
                const Text('Build  \u2022  Send  \u2022  Grow  \u2022  Worldwide',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withValues(alpha: 0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.public, color: _green, size: 16),
              SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Worldwide', style: TextStyle(color: Colors.white, fontSize: 8)),
                  Row(children: [
                    CircleAvatar(radius: 3, backgroundColor: _green),
                    SizedBox(width: 3),
                    Text('Online', style: TextStyle(color: _green, fontSize: 8)),
                  ]),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        _iconBtn(Icons.search, () => _soon('Search')),
        const SizedBox(width: 6),
        _iconBtn(Icons.notifications_none, () => _goTo(const NotificationPage()), badge: _unreadNotifications),
        const SizedBox(width: 6),
        _iconBtn(Icons.settings_outlined, () => _goTo(const ProfilePage())),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _panel,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          if (badge > 0)
            Positioned(
              right: -3,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- Balance card ----------
  Widget _balanceCard() {
    final naira = _balanceHidden ? '\u20a6 ****' : '\u20a6${_nairaBalance.toStringAsFixed(2)}';
    final dollar = _balanceHidden ? '\$ ****' : '\$${_dollarBalance.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0E3A2C), Color(0xFF0A1B24), Color(0xFF0C2347)]),
        border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.25), blurRadius: 18)],
      ),
      child: Row(
        children: [
          Expanded(child: _balanceSide('\u{1F1F3}\u{1F1EC}', 'Naira Balance', naira, _accountNumber)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green, width: 2),
                  ),
                  child: const Text('M', style: TextStyle(color: _green, fontSize: 22, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 4),
                const Text('Mamash', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const Text('Pay \u2022 Save \u2022 Grow', style: TextStyle(color: Colors.white54, fontSize: 6)),
              ],
            ),
          ),
          Expanded(child: _balanceSide('\u{1F1FA}\u{1F1F8}', 'Dollar Balance', dollar, _dollarAccountNumber)),
        ],
      ),
    );
  }

  Widget _balanceSide(String flag, String label, String amount, String account) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _balanceHidden = !_balanceHidden),
                child: Icon(_balanceHidden ? Icons.visibility_off : Icons.visibility, color: Colors.white70, size: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Account No:  ${account.isEmpty ? '\u2014' : account}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copy(account),
                child: const Icon(Icons.copy, color: Colors.white70, size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Hero (Send / Receive / Withdraw) ----------
  Widget _hero() {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final sendW = w * 0.42;
      final sendH = sendW * 0.95;
      final sideW = w * 0.37;
      final sideH = sideW * 0.88;
      final sideTop = sendH * 0.55;
      final totalH = sideTop + sideH + 16;
      return SizedBox(
        height: totalH,
        child: Stack(
          children: [
            Positioned(
              left: w * 0.08,
              right: w * 0.08,
              bottom: 0,
              height: 38,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: StadiumBorder(side: BorderSide(color: _green.withValues(alpha: 0.7), width: 1.5)),
                  gradient: const LinearGradient(colors: [Color(0xFF0B2A25), Color(0xFF0A1A2A)]),
                  shadows: [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 16)],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 22,
              width: w * 0.25,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Money.', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('Without Borders.', style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Fast \u2022 Secure \u2022 Reliable', style: TextStyle(color: Colors.white70, fontSize: 8)),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 24,
              child: GestureDetector(
                onTap: () => _goTo(const InternationalTransferPage()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.public, color: _green, size: 16),
                      SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Global Transfers', style: TextStyle(color: Colors.white, fontSize: 8)),
                          Text('200+ Countries', style: TextStyle(color: Colors.white54, fontSize: 8)),
                        ],
                      ),
                      Icon(Icons.chevron_right, color: _green, size: 14),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: w / 2 - sideW + 4,
              top: sideTop,
              child: _heroTile(sideW, sideH, _recvPts, const [Color(0xFF3C7BFF), Color(0xFF1530A8)], const Color(0xFF4C8DFF),
                  Icons.download, 'Receive', 'Get money globally', () => _goTo(const ReceiveMoneyPage())),
            ),
            Positioned(
              left: w / 2 - 4,
              top: sideTop,
              child: _heroTile(sideW, sideH, _wdPts, const [Color(0xFF8A4DFF), Color(0xFF4A1BA8)], const Color(0xFF9B6BFF),
                  Icons.account_balance_wallet, 'Withdraw', 'To your bank or wallet', () => _soon('Withdraw')),
            ),
            Positioned(
              left: (w - sendW) / 2,
              top: 0,
              child: _heroTile(sendW, sendH, _sendPts, const [Color(0xFF2BE38A), Color(0xFF0B7A4B)], const Color(0xFF2BE38A),
                  Icons.send, 'Send', 'To anyone, anywhere', () => _goTo(const SendMoneyPage())),
            ),
          ],
        ),
      );
    });
  }

  Widget _heroTile(double w, double h, List<Offset> pts, List<Color> colors, Color glow, IconData icon, String title,
      String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: w,
        height: h,
        child: CustomPaint(
          painter: _PolyPainter(pts, colors, glow),
          child: Padding(
            padding: EdgeInsets.only(top: h * 0.28, left: 6, right: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Action row ----------
  Widget _actionRow() {
    final acts = [
      _Act(Icons.add, 'Add Money', 'Top up your wallet', () => _goTo(const AddMoneyPage())),
      _Act(Icons.swap_horiz, 'Convert', 'NGN \u2194 USD & more', () => _soon('Convert')),
      _Act(Icons.flight, 'Flight Pay', 'Book flights worldwide', () => _goTo(const FlightPayPage()), badge: 'New'),
      _Act(Icons.credit_card, 'Card', 'Virtual & Physical', () => _goTo(const CardsPage())),
    ];
    return _panelBox(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        children: acts
            .map((a) => Expanded(
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0E2A33),
                                border: Border.all(color: _green.withValues(alpha: 0.5)),
                              ),
                              child: Icon(a.icon, color: const Color(0xFF5AD1FF), size: 22),
                            ),
                            if (a.badge != null)
                              Positioned(
                                right: -10,
                                top: -6,
                                child: _newTag(a.badge!),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(a.title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        Text(a.sub,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _newTag(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(8)),
      child: Text(t, style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
    );
  }

  // ---------- Services ----------
  Widget _servicesPanel() {
    const blue = [Color(0xFF3B82F6), Color(0xFF1E3A8A)];
    const amber = [Color(0xFFF59E0B), Color(0xFF92400E)];
    const purple = [Color(0xFF8B5CF6), Color(0xFF4C1D95)];
    const green = [Color(0xFF22C55E), Color(0xFF14532D)];
    final items = [
      _Svc(Icons.smartphone, 'Airtime', 'Buy airtime instantly', blue, () => _goTo(const AirtimePage())),
      _Svc(Icons.language, 'Data', 'Buy data for all networks', blue, () => _goTo(const BuyDataPage())),
      _Svc(Icons.sports_esports, 'Betting', 'Play & win', amber, () => _goTo(const BettingPage())),
      _Svc(Icons.receipt_long, 'Bills', 'Pay electricity, DSTV, Water & more', purple, () => _goTo(const BillPaymentPage())),
      _Svc(Icons.assignment_turned_in, 'Survey', 'Earn rewards', green, () => _goTo(const SurveyPage()), badge: 'New'),
      _Svc(Icons.public, 'International Transfer', 'Send to 200+ countries', blue,
          () => _goTo(const InternationalTransferPage())),
      _Svc(Icons.smart_toy, 'Mamash AI', 'Your personal assistant', purple, () => _goTo(const AIAssistantPage())),
      _Svc(Icons.account_balance_wallet, 'Wallet', 'Manage your funds', green, () => _goTo(const WalletPage())),
    ];
    return _panelBox(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Column(
        children: [
          _svcRow(items.sublist(0, 4)),
          const SizedBox(height: 12),
          _svcRow(items.sublist(4)),
        ],
      ),
    );
  }

  Widget _svcRow(List<_Svc> row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: row
          .map((s) => Expanded(
                child: GestureDetector(
                  onTap: s.onTap,
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: s.colors,
                              ),
                              boxShadow: [BoxShadow(color: s.colors.first.withValues(alpha: 0.4), blurRadius: 10)],
                            ),
                            child: Icon(s.icon, color: Colors.white, size: 28),
                          ),
                          if (s.badge != null) Positioned(right: -10, top: -6, child: _newTag(s.badge!)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(s.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(s.sub,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white54, fontSize: 8.5)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ---------- Banners ----------
  Widget _flightBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A6B), Color(0xFF0A1A2A)]),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flight, color: Colors.white, size: 44),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Fly Beyond ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    Text('Borders', style: TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
                const Text('Book flights worldwide with ease.', style: TextStyle(color: Colors.white70, fontSize: 10)),
                const SizedBox(height: 6),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(Icons.public, color: _green, size: 11),
                      SizedBox(width: 3),
                      Text('200+ Countries', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      SizedBox(width: 8),
                      Icon(Icons.verified_user, color: _green, size: 11),
                      SizedBox(width: 3),
                      Text('Best Rates', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      SizedBox(width: 8),
                      Icon(Icons.bolt, color: _green, size: 11),
                      SizedBox(width: 3),
                      Text('Instant Booking', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _greenButton('Book Now \u2192', () => _goTo(const FlightPayPage())),
        ],
      ),
    );
  }

  Widget _earnBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFF0B2E22), Color(0xFF0A1A1F)]),
        border: Border.all(color: _green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Earn More with Mamash',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Complete surveys, refer friends, get rewards & more!',
                    maxLines: 2, style: TextStyle(color: Colors.white60, fontSize: 9.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _greenButton('Explore \u2192', () => _goTo(const RewardsPage())),
        ],
      ),
    );
  }

  Widget _greenButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 10)],
        ),
        child: Text(label, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _panelBox({required Widget child, required EdgeInsets padding}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _green.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }

  // ---------- Bottom nav ----------
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() => _selectedNavIndex = index);
        if (index == 1) {
          _goTo(const RewardsPage());
        } else if (index == 2) {
          _goTo(const FinancePage());
        } else if (index == 3) {
          _goTo(const CardsPage());
        } else if (index == 4) {
          _goTo(const ProfilePage());
        }
      },
      backgroundColor: const Color(0xFF07100F),
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
              Positioned(
                right: -2,
                top: -2,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
          label: 'Rewards',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Finance'),
        const BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), label: 'Cards'),
        const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
      ],
    );
  }
}

class _Act {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final String? badge;
  _Act(this.icon, this.title, this.sub, this.onTap, {this.badge});
}

class _Svc {
  final IconData icon;
  final String title;
  final String sub;
  final List<Color> colors;
  final VoidCallback onTap;
  final String? badge;
  _Svc(this.icon, this.title, this.sub, this.colors, this.onTap, {this.badge});
}

class _PolyPainter extends CustomPainter {
  final List<Offset> pts;
  final List<Color> colors;
  final Color glow;
  _PolyPainter(this.pts, this.colors, this.glow);

  Path _path(Size s) {
    final p = pts.map((o) => Offset(o.dx * s.width, o.dy * s.height)).toList();
    final path = Path();
    const r = 0.16;
    for (int i = 0; i < p.length; i++) {
      final prev = p[(i - 1 + p.length) % p.length];
      final cur = p[i];
      final next = p[(i + 1) % p.length];
      final a = Offset.lerp(cur, prev, r)!;
      final b = Offset.lerp(cur, next, r)!;
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..color = glow.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
