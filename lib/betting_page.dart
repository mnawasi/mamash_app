import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BettingPage extends StatefulWidget {
  const BettingPage({super.key});

  @override
  State<BettingPage> createState() => _BettingPageState();
}

class _BettingPageState extends State<BettingPage> {
  static const Color _bg = Color(0xFF060B0C);
  static const Color _card = Color(0xFF0E1517);
  static const Color _green = Color(0xFF22F06D);
  static const Color _line = Color(0xFF1E2A2C);

  static const _topProviders = ['SportyBet', 'MSport', 'iLOTBet'];
  static const _moreProviders = ['Bet9ja', 'BetKing', 'NairaBet', '1xBet', 'Betway', 'BangBet'];
  static const _presets = [100, 500, 1000, 2000, 5000, 10000];

  // Sample discounts shown as "Pay" amounts. Replace with your real pricing.
  static const Map<int, int> _discount = {500: 10, 1000: 15, 2000: 15, 5000: 15, 10000: 15};

  String _provider = 'SportyBet';
  final _userId = TextEditingController();
  final _amountCtrl = TextEditingController(text: '100');

  int? get _amount => int.tryParse(_amountCtrl.text.replaceAll(',', '').trim());

  @override
  void dispose() {
    _userId.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  int _payFor(int amount) => amount - (_discount[amount] ?? 0);

  // ---------- Actions ----------
  Future<void> _pickMore() async {
    final p = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _moreProviders
            .map((p) => ListTile(
                  leading: const Icon(Icons.sports_soccer, color: _green),
                  title: Text(p, style: const TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, p),
                ))
            .toList(),
      ),
    );
    if (p != null) setState(() => _provider = p);
  }

  Future<void> _pasteId() async {
    final data = await Clipboard.getData('text/plain');
    final t = data?.text?.trim() ?? '';
    if (t.isEmpty) return _msg('Clipboard is empty');
    setState(() => _userId.text = t);
  }

  Future<void> _pay() async {
    final id = _userId.text.trim();
    final amt = _amount;
    if (id.isEmpty) return _msg('Enter your $_provider user ID');
    if (amt == null || amt < 100 || amt > 1000000) {
      return _msg('Enter an amount between \u20a6100 and \u20a61,000,000');
    }
    final pay = _payFor(amt);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Confirm funding', style: TextStyle(color: Colors.white)),
        content: Text(
          'Fund $_provider\nUser ID: $id\nAmount: \u20a6${_fmt(amt)}\nYou pay: \u20a6${_fmt(pay)}',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
    if (ok == true) _fundWallet(id, amt, pay);
  }

  // TODO: connect your existing betting wallet funding logic here.
  // Available: _provider, userId, amount, pay.
  void _fundWallet(String userId, int amount, int pay) {
    _msg('Betting funding is not connected yet');
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 14),
              _banner(),
              const SizedBox(height: 14),
              _providers(),
              const SizedBox(height: 14),
              _userIdField(),
              const SizedBox(height: 18),
              _amountHeader(),
              const SizedBox(height: 12),
              _amountGrid(),
              const SizedBox(height: 14),
              _customRow(),
              const SizedBox(height: 18),
              _promo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _card,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Betting', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              Text('Play \u2022 Predict \u2022 Win', style: TextStyle(color: Color(0xFF8E9BA0), fontSize: 14)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _msg('History coming soon...'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('History', style: TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF0B2A1A), Color(0xFF0A1710), Color(0xFF123A1E)]),
        border: Border.all(color: _green.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bet on Top Leagues',
                    style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800, height: 1.15)),
                const SizedBox(height: 6),
                const Text('Football \u2022 Basketball \u2022 Tennis \u2022 eSports',
                    style: TextStyle(color: Color(0xFFD0DDD5), fontSize: 11.5, height: 1.3)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => _msg('Events coming soon...'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(22)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Explore Events', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 100,
            height: 130,
            child: Stack(
              children: [
                Positioned(top: 0, left: 20, child: Icon(Icons.emoji_events, size: 62, color: const Color(0xFFFFC83D).withValues(alpha: 0.95))),
                Positioned(bottom: 6, left: 0, child: Icon(Icons.sports_soccer, size: 46, color: Colors.white.withValues(alpha: 0.92))),
                Positioned(bottom: 10, right: 0, child: Icon(Icons.sports_basketball, size: 42, color: const Color(0xFFFF8A3D).withValues(alpha: 0.95))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _providers() {
    final moreSelected = _moreProviders.contains(_provider);
    return Row(
      children: [
        ..._topProviders.map((p) => Expanded(child: _providerTile(p))),
        Expanded(
          child: GestureDetector(
            onTap: _pickMore,
            child: _tileShell(
              selected: moreSelected,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF111A1C),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: const Icon(Icons.apps, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(moreSelected ? _provider : 'More',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tileShell({required bool selected, required Widget child}) {
    return Container(
      height: 112,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? _green : _line, width: selected ? 1.6 : 1),
        boxShadow: selected ? [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)] : null,
      ),
      child: Stack(
        children: [
          Center(child: child),
          if (selected)
            const Positioned(
              right: 4,
              top: 6,
              child: CircleAvatar(radius: 9, backgroundColor: _green, child: Icon(Icons.check, size: 13, color: Colors.black)),
            ),
        ],
      ),
    );
  }

  Widget _providerTile(String name) {
    return GestureDetector(
      onTap: () => setState(() => _provider = name),
      child: _tileShell(
        selected: _provider == name,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _providerLogo(name),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _providerLogo(String name) {
    switch (name) {
      case 'SportyBet':
        return const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text('S',
                style: TextStyle(
                    color: Color(0xFFFF1F3D), fontSize: 42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          ),
        );
      case 'MSport':
        return Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: const Color(0xFFFFC800), borderRadius: BorderRadius.circular(12)),
          child: const Text('M', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900)),
        );
      default:
        return Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
          child: const Text('i', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
        );
    }
  }

  Widget _userIdField() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF131C1E),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User ID', style: TextStyle(color: Color(0xFF8E9BA0), fontSize: 13)),
                TextField(
                  controller: _userId,
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 2),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Enter your user ID',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pasteId,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.content_paste, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountHeader() {
    return Row(
      children: [
        const Icon(Icons.savings, color: Color(0xFFFFC83D), size: 30),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Select Amount', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: () => _msg('More currencies coming soon...'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 20,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Expanded(child: Container(color: const Color(0xFF008751))),
                      Expanded(child: Container(color: Colors.white)),
                      Expanded(child: Container(color: const Color(0xFF008751))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('NGN (\u20a6)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.75,
      children: _presets.map((a) {
        final sel = _amount == a;
        final hasPay = _discount.containsKey(a);
        return GestureDetector(
          onTap: () => setState(() => _amountCtrl.text = '$a'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: sel
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0E4A2A), Color(0xFF082315)],
                    )
                  : null,
              color: sel ? null : _card,
              border: Border.all(color: sel ? _green : _line, width: sel ? 1.6 : 1),
              boxShadow: sel ? [BoxShadow(color: _green.withValues(alpha: 0.35), blurRadius: 12)] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('\u20a6${_fmt(a)}',
                      style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                ),
                if (hasPay) ...[
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Pay \u20a6${_fmt(_payFor(a))}',
                        style: const TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _customRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                const Text('\u20a6', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                Container(width: 1, height: 28, color: Colors.white24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                      hintText: '100 - 1,000,000',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                if (_amountCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _amountCtrl.clear()),
                    child: const Icon(Icons.cancel, color: Colors.white54, size: 22),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _pay,
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.45), blurRadius: 16)],
            ),
            child: const Row(
              children: [
                Icon(Icons.send, color: Colors.black, size: 22),
                SizedBox(width: 10),
                Text('Pay', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _promo() {
    return GestureDetector(
      onTap: () => _msg('Rewards coming soon...'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF2A1458), Color(0xFF3B1A7A), Color(0xFF1D0E40)]),
          border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Color(0xFFFFB02E), size: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF8B5CF6)),
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    ),
                    child: const Text('MORE EVENTS',
                        style: TextStyle(color: Color(0xFFB79CFF), fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Mamash Rewards',
                      style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  const Text('Earn cashback on every wallet top-up',
                      style: TextStyle(color: Color(0xFFC9BDE8), fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.15)),
              child: const Icon(Icons.chevron_right, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
