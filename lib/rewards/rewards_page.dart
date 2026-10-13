import 'package:flutter/material.dart';
import '../buy_data_page.dart';
import '../betting_page.dart';
import '../airtime_page.dart';
import '../bill_payment_page.dart';
import '../wallet_page.dart';
import '../profile_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _Voucher {
  final String value;
  final String title;
  final String available;
  const _Voucher(this.value, this.title, this.available);
}

class _RewardsPageState extends State<RewardsPage> {
  // Placeholder values. Connect these to your real rewards data.
  static const double _cashback = 0.00;
  static const int _voucherCount = 0;

  // Sample vouchers for the UI. Replace with your real vouchers.
  static const _dataVouchers = [
    _Voucher('\u20a640', 'Data Voucher', '\u20a63,000 available'),
    _Voucher('\u20a610', 'Data Voucher', '\u20a61,000 available'),
  ];
  static const _bettingVouchers = [
    _Voucher('\u20a650', 'Betting Voucher', '\u20a65,000 available'),
    _Voucher('\u20a620', 'Betting Voucher', '\u20a62,000 available'),
  ];

  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  bool _hidden = false;
  int _tab = 0; // 0 data, 1 betting
  final _dailyKey = GlobalKey();

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _scrollToDaily() {
    final ctx = _dailyKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF063A31), Color(0xFF03110F)],
            stops: [0, .4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 10),
                _title(),
                const SizedBox(height: 12),
                _summary(),
                const SizedBox(height: 12),
                _tiles(),
                const SizedBox(height: 18),
                _sectionHeader(Icons.local_fire_department, 'Hot Vouchers', 'Top deals, more value', 'View All',
                    () => _msg('All vouchers coming soon...')),
                const SizedBox(height: 10),
                _voucherTabs(),
                const SizedBox(height: 10),
                ..._voucherList(),
                const SizedBox(height: 14),
                Container(key: _dailyKey),
                _sectionHeader(Icons.card_giftcard, 'Daily Bonus', 'Complete tasks, earn rewards', 'See All',
                    () => _msg('All tasks coming soon...')),
                const SizedBox(height: 10),
                _dailyList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Top ----------
  Widget _topBar() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)]),
          ),
          child: const Text('M',
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        ),
        const SizedBox(width: 10),
        const Text('Mamash', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () => _msg('Region options coming soon...'),
          child: const Row(
            children: [
              Icon(Icons.public, color: _green, size: 20),
              SizedBox(width: 5),
              Text('Global', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w600)),
              Icon(Icons.keyboard_arrow_down, color: _green, size: 20),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _msg('Menu coming soon...'),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _panel,
              border: Border.all(color: _green.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _title() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: _green.withValues(alpha: 0.15),
            border: Border.all(color: _green.withValues(alpha: 0.6)),
          ),
          child: const Icon(Icons.card_giftcard, color: _green, size: 30),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rewards', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
            Text('Earn more with Mamash', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // ---------- Summary ----------
  Widget _summary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0B4A3E), Color(0xFF08261F), Color(0xFF0A3A32)]),
        border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                _coin(54),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Cashback', style: TextStyle(color: Colors.white, fontSize: 15)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _hidden = !_hidden),
                            child: Icon(_hidden ? Icons.visibility_off : Icons.visibility, color: _green, size: 18),
                          ),
                        ],
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(_hidden ? '\u20a6****' : '\u20a6${_cashback.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                      ),
                      const Text('Available balance', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 70, margin: const EdgeInsets.symmetric(horizontal: 8), color: Colors.white12),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [Color(0xFFB36BFF), Color(0xFF6D28D9)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.local_activity, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vouchers', style: TextStyle(color: Colors.white, fontSize: 15)),
                      Text('$_voucherCount',
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                      const Text('Available', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.card_giftcard, color: Color(0xFF1FB88A), size: 62),
            ),
          ),
        ],
      ),
    );
  }

  Widget _coin(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFFFFD84D), Color(0xFFE59A0B)]),
        border: Border.all(color: const Color(0xFFFFE58A), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFFFFB02E).withValues(alpha: 0.5), blurRadius: 10)],
      ),
      child: Text('M',
          style: TextStyle(
              color: const Color(0xFFB36B00), fontSize: size * 0.5, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
    );
  }

  // ---------- Tiles ----------
  Widget _tiles() {
    return Row(
      children: [
        _tile(Icons.event_available, 'Daily Bonus', 'Get rewarded', const Color(0xFF22C55E),
            const [Color(0xFF3DE08A), Color(0xFF16A34A)], _scrollToDaily),
        const SizedBox(width: 8),
        _tile(Icons.person_add, 'Refer Friends', 'Earn together', const Color(0xFF3B82F6),
            const [Color(0xFF3B9BFF), Color(0xFF1D5FE8)], () => _msg('Referrals coming soon...')),
        const SizedBox(width: 8),
        _tile(Icons.volunteer_activism, 'Play4aChild', 'Support children', const Color(0xFFD99A1B),
            const [Color(0xFFFFC53D), Color(0xFFB8740A)], () => _msg('Play4aChild coming soon...')),
        const SizedBox(width: 8),
        _tile(Icons.local_activity, 'Voucher Pack', 'More rewards', const Color(0xFF8B5CF6),
            const [Color(0xFFB36BFF), Color(0xFF6D28D9)], () => _msg('Voucher packs coming soon...')),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String sub, Color border, List<Color> colors, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 12, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [border.withValues(alpha: 0.22), const Color(0xFF08181A)],
            ),
            border: Border.all(color: border.withValues(alpha: 0.8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                  boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.45), blurRadius: 10)],
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(title,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(sub, style: const TextStyle(color: Color(0xFFB0C4C0), fontSize: 10.5)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Sections ----------
  Widget _sectionHeader(IconData icon, String title, String sub, String action, VoidCallback onAction) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: _green.withValues(alpha: 0.15),
            border: Border.all(color: _green.withValues(alpha: 0.6)),
          ),
          child: Icon(icon, color: _green, size: 26),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
              Text(sub, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(action, style: const TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right, color: _green, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _voucherTabs() {
    Widget tab(String label, IconData icon, int i) {
      final sel = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: sel ? const LinearGradient(colors: [Color(0xFF0E6B4E), Color(0xFF0A4A3A)]) : null,
              border: sel ? Border.all(color: _green.withValues(alpha: 0.7)) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: sel ? _green : Colors.white70, size: 22),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.white70, fontSize: 16, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _line),
      ),
      child: Row(children: [tab('Data', Icons.wifi, 0), tab('Betting', Icons.emoji_events_outlined, 1)]),
    );
  }

  List<Widget> _voucherList() {
    final list = _tab == 0 ? _dataVouchers : _bettingVouchers;
    return list.map((v) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF0B3A33), Color(0xFF08221F)]),
          border: Border.all(color: _green.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _tab == 0 ? _green.withValues(alpha: 0.18) : const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                border: Border.all(color: _tab == 0 ? _green : const Color(0xFF8B5CF6), width: 1.4),
              ),
              child: Icon(_tab == 0 ? Icons.public : Icons.sports_soccer,
                  color: _tab == 0 ? _green : const Color(0xFFB79CFF), size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(v.value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Text(v.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(v.available, style: const TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(width: 1, height: 48, margin: const EdgeInsets.symmetric(horizontal: 10), color: Colors.white12),
            _goButton('Use', () => _goTo(_tab == 0 ? const BuyDataPage() : const BettingPage())),
          ],
        ),
      );
    }).toList();
  }

  Widget _goButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF04201A), fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF04201A), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _dailyList() {
    Widget row(IconData icon, List<Color> colors, String title, String badge, Color badgeColor, String desc,
        VoidCallback onTap, {bool last = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: Color(0xFF15463E))),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 8),
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Color(0xFFFFB02E),
                        child: Text('\$', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(badge,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: badgeColor, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(desc, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 11.5, height: 1.25)),
                ],
              ),
            ),
            Container(width: 1, height: 48, margin: const EdgeInsets.symmetric(horizontal: 8), color: Colors.white12),
            _goButton('Go', onTap),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A33), Color(0xFF08221F)]),
        border: Border.all(color: _green.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          row(Icons.groups, const [Color(0xFF2BD9A0), Color(0xFF0E8F70)], 'Share App', '+\u20a6200', const Color(0xFF3DE08A),
              'Help a loved one get an account\nand get \u20a6200 Cashback', () => _msg('Sharing coming soon...')),
          row(Icons.smartphone, const [Color(0xFFB36BFF), Color(0xFF6D28D9)], 'Glo Airtime', 'Up to 6%', const Color(0xFF3DE08A),
              'Buy Airtime and get up to 6%\nCashback', () => _goTo(const AirtimePage())),
          row(Icons.description, const [Color(0xFFFFC53D), Color(0xFFB8740A)], 'Pay Bills', 'Earn cashback', const Color(0xFF3DE08A),
              'Pay your bills and get rewarded', () => _goTo(const BillPaymentPage()), last: true),
        ],
      ),
    );
  }

  // ---------- Bottom bar ----------
  Widget _bottomBar() {
    Widget item(IconData icon, String label, bool sel, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: sel ? _green : Colors.white70, size: 28),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: sel ? _green : Colors.white70, fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                width: 44,
                height: 3,
                decoration: BoxDecoration(
                  color: sel ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            item(Icons.home_outlined, 'Home', false, () => Navigator.pop(context)),
            item(Icons.card_giftcard, 'Rewards', true, () {}),
            item(Icons.account_balance_wallet_outlined, 'Wallet', false, () => _goTo(const WalletPage())),
            item(Icons.person_outline, 'Profile', false, () => _goTo(const ProfilePage())),
          ],
        ),
      ),
    );
  }
}
