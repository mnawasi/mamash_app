import 'package:flutter/material.dart';
import 'transfer_to_mamash_page.dart';
import 'international_transfer_page.dart';

class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  static const double _nairaBalance = 0.00;
  static const double _dollarBalance = 0.00;

  static const Color _bg = Color(0xFF050A0D);
  static const Color _panel = Color(0xFF0A1A1F);
  static const Color _green = Color(0xFF16C784);
  static const Color _blue = Color(0xFF3C7BFF);
  static const Color _purple = Color(0xFF9B6BFF);

  bool _hidden = false;

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$what coming soon...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 18),
                _balanceCard(),
                const SizedBox(height: 22),
                _sendToTitle(),
                const SizedBox(height: 10),
                _mamashUserRow(),
                const SizedBox(height: 14),
                _optionCards(),
                const SizedBox(height: 16),
                _worldBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Money', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              Text('Fast  \u2022  Secure  \u2022  Global', style: TextStyle(color: Color(0xFF9FB3D1), fontSize: 13)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _goTo(const InternationalTransferPage()),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _panel,
              border: Border.all(color: _green, width: 1.5),
            ),
            child: const Icon(Icons.public, color: _green, size: 22),
          ),
        ),
      ],
    );
  }

  // ---------- Balance ----------
  Widget _balanceCard() {
    final naira = _hidden ? '\u20a6 ****' : '\u20a6 ${_nairaBalance.toStringAsFixed(2)}';
    final dollar = _hidden ? '\$ ****' : '\$ ${_dollarBalance.toStringAsFixed(2)}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0C2F2A), Color(0xFF0A1B24), Color(0xFF0B2240)]),
        border: Border.all(color: _green.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 16)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: _green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text('Total Balance',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _hidden = !_hidden),
                      child: Icon(_hidden ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _walletItem('\u20a6', const Color(0xFF0E8F63), naira, 'Naira Wallet')),
                      Container(width: 1, height: 36, color: Colors.white24),
                      const SizedBox(width: 10),
                      Expanded(child: _walletItem('\$', const Color(0xFF1D4ED8), dollar, 'Dollar Wallet')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 62,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2BE38A), Color(0xFF0B5A5A)],
              ),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.5), blurRadius: 18)],
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }

  Widget _walletItem(String symbol, Color color, String amount, String label) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          child: Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Send to ----------
  Widget _sendToTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Send to', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        GestureDetector(
          onTap: () => _goTo(const InternationalTransferPage()),
          child: const Row(
            children: [
              Icon(Icons.public, color: _green, size: 20),
              SizedBox(width: 6),
              Text('Worldwide', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right, color: _green, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mamashUserRow() {
    return GestureDetector(
      onTap: () => _goTo(const TransferToMamashPage()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            _mLogo(46, 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To Mamash user',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Send instantly to another Mamash wallet',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _mLogo(double size, double fontSize) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        color: _green.withValues(alpha: 0.2),
        border: Border.all(color: _green.withValues(alpha: 0.6)),
      ),
      child: Text('M', style: TextStyle(color: _green, fontSize: fontSize, fontWeight: FontWeight.w900)),
    );
  }

  // ---------- Option cards ----------
  Widget _optionCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _optionCard(
              color: _green,
              icon: _mLogo(64, 32),
              title: 'Transfer to Mamash',
              sub: 'Send to another Mamash wallet',
              onTap: () => _goTo(const TransferToMamashPage()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _optionCard(
              color: _blue,
              icon: _iconBox(Icons.account_balance, _blue),
              title: 'To Bank',
              sub: 'Transfer to any Nigerian bank',
              onTap: () => _soon('Bank transfer'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _optionCard(
              color: _purple,
              icon: _iconBox(Icons.qr_code_scanner, _purple),
              title: 'QR Payment',
              sub: 'Scan to pay a merchant or contact',
              onTap: () => _soon('QR payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.5)],
        ),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14)],
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
  }

  Widget _optionCard({
    required Color color,
    required Widget icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 18, 8, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.06)],
          ),
          border: Border.all(color: color, width: 1.4),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 14)],
        ),
        child: Column(
          children: [
            icon,
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const Spacer(),
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.35),
                border: Border.all(color: color),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Bottom banner ----------
  Widget _worldBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Color(0xFF0B3A33), Color(0xFF0A1A24)]),
        border: Border.all(color: _green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.send, color: Color(0xFF5AD1FF), size: 18),
                    SizedBox(width: 8),
                    Text('Send Money', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Text('Across the World',
                    style: TextStyle(color: _green, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text('Fast, secure and affordable\ninternational transfers.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _goTo(const InternationalTransferPage()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 10)],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Learn More', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, color: Colors.black, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFF3FA66B), Color(0xFF0E4B8F)]),
              boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), blurRadius: 20)],
            ),
            child: const Icon(Icons.public, color: Colors.white, size: 60),
          ),
        ],
      ),
    );
  }
}
