import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wallet_page.dart';
import 'transaction_limits_page.dart';
import 'about_mamash_pay_page.dart';
import 'security_page.dart';
import 'help_support_page.dart';
import 'personal_information_page.dart';
import 'verification_kyc_page.dart';
import 'send_money_page.dart';
import 'international_transfer_page.dart';
import 'bill_payment_page.dart';
import 'rewards/rewards_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Placeholder balances. Connect these to your real wallet data.
  static const double _naira = 0.00;
  static const double _dollar = 0.00;

  static const Color _bg = Color(0xFF050A12);
  static const Color _panel = Color(0xFF0A1220);
  static const Color _gold = Color(0xFFFFC83D);
  static const Color _line = Color(0xFF1B2A44);

  bool _hidden = false;
  bool _loading = true;
  String _name = '';
  String _email = '';
  String _phone = '';
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    String name = user.displayName ?? '';
    String email = user.email ?? '';
    String phone = user.phoneNumber ?? '';
    bool verified = false;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = doc.data();
      if (d != null) {
        String pick(List<String> keys) {
          for (final k in keys) {
            final v = d[k];
            if (v is String && v.trim().isNotEmpty) return v.trim();
          }
          return '';
        }

        final n = pick(['fullName', 'name', 'displayName', 'username']);
        if (n.isNotEmpty) name = n;
        final e = pick(['email']);
        if (e.isNotEmpty) email = e;
        final p = pick(['phone', 'phoneNumber']);
        if (p.isNotEmpty) phone = p;
        verified = d['verified'] == true || d['isVerified'] == true || d['kycVerified'] == true;
      }
    } catch (_) {
      // Keep whatever we have from FirebaseAuth.
    }
    if (name.isEmpty && email.isNotEmpty) name = email.split('@').first;
    if (name.isEmpty) name = 'Mamash User';
    if (!mounted) return;
    setState(() {
      _name = name;
      _email = email;
      _phone = phone;
      _verified = verified;
      _loading = false;
    });
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  void _goTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Log out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out', style: TextStyle(color: Color(0xFFFF5A67))),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginPage()), (_) => false);
  }

  void _about() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('About Mamash Pay', style: TextStyle(color: Colors.white)),
        content: const Text('Version 1.0.0\nYour money, worldwide.', style: TextStyle(color: Colors.white70, height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(),
              const SizedBox(height: 14),
              _profileCard(),
              const SizedBox(height: 14),
              _menuCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: () => _msg('Settings coming soon...'),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.settings, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }

  // ---------- Profile card ----------
  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1626), Color(0xFF0A1220), Color(0xFF2A2210)],
        ),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              const SizedBox(width: 14),
              Expanded(child: _identity()),
            ],
          ),
          const SizedBox(height: 14),
          _walletCard(),
          const SizedBox(height: 12),
          _quickTiles(),
        ],
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111B30),
              border: Border.all(color: _gold, width: 3),
              boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35), blurRadius: 14)],
            ),
            child: const Icon(Icons.person, color: Color(0xFF3A4A6A), size: 78),
          ),
          Positioned(
            right: 0,
            bottom: 6,
            child: GestureDetector(
              onTap: () => _msg('Photo upload coming soon...'),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
                child: const Icon(Icons.photo_camera, color: Color(0xFF3A2A00), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _identity() {
    if (_loading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2.5)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(_name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            if (_verified) ...[
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: _gold, size: 22),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => _msg('Edit profile coming soon...'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _gold.withValues(alpha: 0.8)),
                color: _gold.withValues(alpha: 0.08),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, color: _gold, size: 18),
                  SizedBox(width: 6),
                  Text('Edit', style: TextStyle(color: _gold, fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        if (_email.isNotEmpty)
          Text(_email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 14)),
        if (_phone.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_phone,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFD5DEF2), fontSize: 14)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: (_verified ? const Color(0xFF0E5A55) : const Color(0xFF4A3A10)).withValues(alpha: 0.7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_verified ? Icons.verified_user : Icons.shield_outlined,
                  color: _verified ? const Color(0xFF3DE0C8) : _gold, size: 18),
              const SizedBox(width: 6),
              Text(_verified ? 'Verified Account' : 'Not verified',
                  style: TextStyle(
                      color: _verified ? const Color(0xFF3DE0C8) : _gold, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletCard() {
    final naira = _hidden ? '\u20a6 ****' : '\u20a6 ${_naira.toStringAsFixed(2)}';
    final dollar = _hidden ? '\$ ****' : '\$ ${_dollar.toStringAsFixed(2)}';
    return GestureDetector(
      onTap: () => _goTo(const WalletPage()),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0A1220).withValues(alpha: 0.9),
          border: Border.all(color: _gold.withValues(alpha: 0.7), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: _gold, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Wallet Balance', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _hidden = !_hidden),
                  child: Icon(_hidden ? Icons.visibility_off : Icons.visibility, color: Colors.white70, size: 22),
                ),
                const SizedBox(width: 6),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _balItem('\u20a6', const Color(0xFF0E6B52), naira, 'Naira Balance')),
                Container(width: 1, height: 48, color: Colors.white12),
                const SizedBox(width: 12),
                Expanded(child: _balItem('\$', const Color(0xFF1D4ED8), dollar, 'Dollar Balance')),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balItem(String symbol, Color color, String amount, String label) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
          child: Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(label, style: const TextStyle(color: Color(0xFFB5C6E8), fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickTiles() {
    Widget tile(IconData icon, List<Color> colors, String title, String? sub, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.fromLTRB(8, 12, 4, 10),
            height: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF0A1424),
              border: Border.all(color: const Color(0xFF22406A)),
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
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Spacer(),
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
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                          if (sub != null)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(sub, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 12)),
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

    return Row(
      children: [
        tile(Icons.shield, const [Color(0xFF2BD98A), Color(0xFF0E7A4A)], 'Increase Limits', null,
            () => _goTo(const TransactionLimitsPage())),
        tile(Icons.workspace_premium, const [Color(0xFF8B5CF6), Color(0xFF5B21B6)], 'VIP Tier', 'Tier 1',
            () => _msg('VIP tiers coming soon...')),
        tile(Icons.credit_card, const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], 'Virtual Card', 'Coming Soon',
            () => _msg('Virtual cards coming soon...')),
        tile(Icons.card_giftcard, const [Color(0xFFFFB23E), Color(0xFFB8740A)], 'Rewards', 'Get more',
            () => _goTo(const RewardsPage())),
      ],
    );
  }

  // ---------- Menu ----------
  Widget _menuCard() {
    Widget row(IconData icon, List<Color> colors, String title, String sub, VoidCallback onTap, {bool last = false}) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: last ? null : const Border(bottom: BorderSide(color: Color(0xFF1B2A44))),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(sub, style: const TextStyle(color: Color(0xFF8FA3C8), fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 26),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: _panel.withValues(alpha: 0.95),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          row(Icons.person, const [Color(0xFF3B82F6), Color(0xFF1D4ED8)], 'Personal Information',
              'Name, email, phone, gender, address', () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInformationPage())); _loadUser(); }),
          row(Icons.shield, const [Color(0xFF22C55E), Color(0xFF15803D)], 'Verification & KYC',
              'Identity, BVN, selfie, document status', () => _goTo(const VerificationKycPage())),
          row(Icons.description, const [Color(0xFF14B8C8), Color(0xFF0E7490)], 'Transaction Limits',
              'Daily and monthly limits', () => _goTo(const TransactionLimitsPage())),
          row(Icons.lock, const [Color(0xFFFFA23E), Color(0xFFC2570C)], 'Security',
              'PIN, biometric, device management', () => _goTo(const SecurityPage())),
          row(Icons.headset_mic, const [Color(0xFF8B5CF6), Color(0xFF5B21B6)], 'Help & Support',
              'FAQs, contact us, live chat', () => _goTo(const HelpSupportPage())),
          row(Icons.info_outline, const [Color(0xFF4A5A7A), Color(0xFF2A3550)], 'About Mamash Pay',
              'Version 1.0.0', () => _goTo(const AboutMamashPayPage()), last: true),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF3A1018), Color(0xFF1E0C14)]),
                border: Border.all(color: const Color(0xFF8A2A3A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Color(0xFFFF5A67), size: 26),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text('Log Out',
                        style: TextStyle(color: Color(0xFFFF5A67), fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFFFF5A67), size: 26),
                ],
              ),
            ),
          ),
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
              Icon(icon, color: sel ? _gold : const Color(0xFF7D8DB0), size: 28),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      color: sel ? _gold : const Color(0xFF9AA8C8), fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
              const SizedBox(height: 4),
              Container(
                width: 56,
                height: 3,
                decoration: BoxDecoration(color: sel ? _gold : Colors.transparent, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 84,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 68,
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: _panel,
                  border: const Border(top: BorderSide(color: Color(0xFF1B2A44))),
                ),
                child: Row(
                  children: [
                    item(Icons.home_outlined, 'Home', false, () => Navigator.pop(context)),
                    item(Icons.swap_horiz, 'Transfer', false, () => _goTo(const InternationalTransferPage())),
                    const Expanded(child: SizedBox()),
                    item(Icons.grid_view, 'Services', false, () => _goTo(const BillPaymentPage())),
                    item(Icons.person, 'Profile', true, () {}),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _goTo(const SendMoneyPage()),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFFFFD36B), Color(0xFFE5A21C)]),
                          border: Border.all(color: _bg, width: 4),
                          boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.4), blurRadius: 14)],
                        ),
                        child: const Icon(Icons.send, color: Color(0xFF3A2A00), size: 30),
                      ),
                      const SizedBox(height: 2),
                      const Text('Send', style: TextStyle(color: Color(0xFF9AA8C8), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
