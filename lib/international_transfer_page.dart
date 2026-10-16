import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InternationalTransferPage extends StatefulWidget {
  const InternationalTransferPage({super.key});

  @override
  State<InternationalTransferPage> createState() => _InternationalTransferPageState();
}

const double _kNgnPerUsd = 1450; // SAMPLE rate. Replace with a live rate.

class _Dest {
  final String name;
  final String flag;
  final String currency;
  final String symbol;
  final double perUsd; // SAMPLE: units of this currency per 1 US dollar
  const _Dest(this.name, this.flag, this.currency, this.symbol, this.perUsd);

  double get ngnPerUnit => _kNgnPerUsd / perUsd;
}

class _InternationalTransferPageState extends State<InternationalTransferPage> {
  static const Color _bg = Color(0xFF050B0E);
  static const Color _panel = Color(0xFF0A1417);
  static const Color _field = Color(0xFF0F1B1F);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF1C2E33);

  static const _nigeriaFlag = '\u{1F1F3}\u{1F1EC}';

  // Sample indicative rates. Replace with a live rate source before launch.
  static const _dests = [
    _Dest('Ghana', '\u{1F1EC}\u{1F1ED}', 'GHS', 'GH\u20b5', 12),
    _Dest('Kenya', '\u{1F1F0}\u{1F1EA}', 'KES', 'KSh', 129),
    _Dest('South Africa', '\u{1F1FF}\u{1F1E6}', 'ZAR', 'R', 18),
    _Dest('Uganda', '\u{1F1FA}\u{1F1EC}', 'UGX', 'USh', 3700),
    _Dest('Tanzania', '\u{1F1F9}\u{1F1FF}', 'TZS', 'TSh', 2600),
    _Dest('Rwanda', '\u{1F1F7}\u{1F1FC}', 'RWF', 'RF', 1400),
    _Dest('Zambia', '\u{1F1FF}\u{1F1F2}', 'ZMW', 'ZK', 27),
    _Dest('Cameroon', '\u{1F1E8}\u{1F1F2}', 'XAF', 'FCFA', 600),
    _Dest('Ivory Coast', '\u{1F1E8}\u{1F1EE}', 'XOF', 'CFA', 600),
    _Dest('Senegal', '\u{1F1F8}\u{1F1F3}', 'XOF', 'CFA', 600),
    _Dest('Egypt', '\u{1F1EA}\u{1F1EC}', 'EGP', 'E\u00a3', 48),
    _Dest('Ethiopia', '\u{1F1EA}\u{1F1F9}', 'ETB', 'Br', 130),
    _Dest('Malawi', '\u{1F1F2}\u{1F1FC}', 'MWK', 'MK', 1730),
    _Dest('Mozambique', '\u{1F1F2}\u{1F1FF}', 'MZN', 'MT', 64),
    _Dest('Botswana', '\u{1F1E7}\u{1F1FC}', 'BWP', 'P', 13.5),
    _Dest('DR Congo', '\u{1F1E8}\u{1F1E9}', 'CDF', 'FC', 2800),
    _Dest('Gambia', '\u{1F1EC}\u{1F1F2}', 'GMD', 'D', 70),
    _Dest('Guinea', '\u{1F1EC}\u{1F1F3}', 'GNF', 'FG', 8600),
    _Dest('Liberia', '\u{1F1F1}\u{1F1F7}', 'LRD', 'L\$', 190),
    _Dest('Mali', '\u{1F1F2}\u{1F1F1}', 'XOF', 'CFA', 600),
    _Dest('Sierra Leone', '\u{1F1F8}\u{1F1F1}', 'SLE', 'Le', 23),
    _Dest('Burkina Faso', '\u{1F1E7}\u{1F1EB}', 'XOF', 'CFA', 600),
    _Dest('Benin', '\u{1F1E7}\u{1F1EF}', 'XOF', 'CFA', 600),
    _Dest('Niger', '\u{1F1F3}\u{1F1EA}', 'XOF', 'CFA', 600),
    _Dest('Togo', '\u{1F1F9}\u{1F1EC}', 'XOF', 'CFA', 600),
    _Dest('United States', '\u{1F1FA}\u{1F1F8}', 'USD', '\$', 1),
    _Dest('United Kingdom', '\u{1F1EC}\u{1F1E7}', 'GBP', '\u00a3', 0.78),
    _Dest('Canada', '\u{1F1E8}\u{1F1E6}', 'CAD', 'C\$', 1.38),
    _Dest('Europe', '\u{1F1EA}\u{1F1FA}', 'EUR', '\u20ac', 0.92),
    _Dest('Australia', '\u{1F1E6}\u{1F1FA}', 'AUD', 'A\$', 1.5),
  ];

  _Dest _dest = _dests.first;
  final _name = TextEditingController();
  final _account = TextEditingController();
  final _bank = TextEditingController();
  final _amount = TextEditingController();

  double get _sendAmount => double.tryParse(_amount.text.trim()) ?? 0;
  double get _receiveAmount => _sendAmount / _dest.ngnPerUnit;

  @override
  void dispose() {
    _name.dispose();
    _account.dispose();
    _bank.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _money(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final s = parts[0];
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '$b.${parts[1]}';
  }

  // ---------- Actions ----------
  Future<void> _pickDest() async {
    final d = await showModalBottomSheet<_Dest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _DestPicker(dests: _dests),
    );
    if (d != null) setState(() => _dest = d);
  }

  void _rateInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Indicative rate', style: TextStyle(color: Colors.white)),
        content: Text(
          '1 ${_dest.currency} \u2248 \u20a6${_money(_dest.ngnPerUnit)}\n\nThis is an estimate. The final rate is shown before you confirm.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: _green)))],
      ),
    );
  }

  Future<void> _continue() async {
    if (_name.text.trim().isEmpty) return _msg('Enter the recipient\'s full name');
    if (_account.text.trim().length < 5) return _msg('Enter a valid account number or IBAN');
    if (_bank.text.trim().isEmpty) return _msg('Enter the recipient bank');
    if (_sendAmount <= 0) return _msg('Enter the amount you want to send');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Confirm transfer', style: TextStyle(color: Colors.white)),
        content: Text(
          'To: ${_name.text.trim()}\n${_bank.text.trim()} \u2022 ${_account.text.trim()}\nCountry: ${_dest.name}\n\nYou send: \u20a6${_money(_sendAmount)}\nThey get: ${_dest.symbol}${_money(_receiveAmount)} (estimated)\nFee: Free',
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
    if (ok == true) _submit();
  }

  // TODO: connect your existing international transfer logic here.
  // Available: _dest, _name.text, _account.text, _bank.text, _sendAmount, _receiveAmount.
  void _submit() {
    _msg('International transfer is not connected yet');
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF062A25), Color(0xFF050B0E)],
            stops: [0, .35],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _brand(),
                const SizedBox(height: 14),
                _header(),
                const SizedBox(height: 14),
                _hero(),
                const SizedBox(height: 14),
                _sendToCard(),
                const SizedBox(height: 14),
                _recipientCard(),
                const SizedBox(height: 14),
                _amountCard(),
                const SizedBox(height: 14),
                _continueButton(),
                const SizedBox(height: 12),
                const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: _green, size: 18),
                      SizedBox(width: 8),
                      Text('Encrypted transfer  \u2022  Review fees before sending',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
        color: _panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      );

  BoxDecoration _inputBox() => BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF243A40)),
      );

  Widget _brand() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(colors: [Color(0xFF3CF0B0), Color(0xFF0FA672)]),
          ),
          child: const Text('M',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        ),
        const SizedBox(width: 10),
        const Text('Mamash', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text('International Transfer',
              style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)),
        ),
        GestureDetector(
          onTap: () => _msg('History coming soon...'),
          child: const Row(
            children: [
              Icon(Icons.history, color: _green, size: 24),
              SizedBox(width: 6),
              Text('History', style: TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF0A2E2B), Color(0xFF08191F), Color(0xFF0A3A38)]),
        border: Border.all(color: _green.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.18), blurRadius: 16)],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -14,
            child: Icon(Icons.public, size: 150, color: _green.withValues(alpha: 0.35)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _green.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.swap_calls, color: _green, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Send money',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.1)),
                      Text('worldwide',
                          style: TextStyle(color: _green, fontSize: 30, fontWeight: FontWeight.w800, height: 1.1)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Fast, secure cross-border transfers',
                  style: TextStyle(color: Color(0xFFC6D6D4), fontSize: 14)),
              const SizedBox(height: 16),
              Text('Supported countries  \u2022  ${_dests.length + 1}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _countryChip(_nigeriaFlag, 'Nigeria', null),
                    ..._dests.take(5).map((d) => _countryChip(d.flag, _short(d.name), d)),
                    _moreChip(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _short(String n) => n == 'United States' ? 'USA' : (n == 'United Kingdom' ? 'UK' : n);

  Widget _moreChip() {
    final more = _dests.length - 5;
    return GestureDetector(
      onTap: _pickDest,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1A1D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _green),
        ),
        child: Text('+$more more', style: const TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _countryChip(String flag, String label, _Dest? d) {
    return GestureDetector(
      onTap: () {
        if (d != null) {
          setState(() => _dest = d);
        } else {
          _msg('Nigeria is where you send from');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1A1D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: d != null && d == _dest ? _green : const Color(0xFF2A4448)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _sendToCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send to', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDest,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: _inputBox(),
              child: Row(
                children: [
                  Text(_dest.flag, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(_dest.name,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [_green.withValues(alpha: 0.16), _green.withValues(alpha: 0.05)]),
              border: Border.all(color: _green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz, color: _green, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Text('Estimated exchange rate',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _green.withValues(alpha: 0.5)),
                            ),
                            child: const Text('Indicative rate', style: TextStyle(color: _green, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('Rate updates before confirmation',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _rateInfo,
                  child: const Icon(Icons.info_outline, color: Colors.white54, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipientCard() {
    Widget input(IconData icon, String hint, TextEditingController c,
        {TextInputType? type, IconData? trailing}) {
      return Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _inputBox(),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9FB0B5), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: TextField(
                controller: c,
                keyboardType: type,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(color: Color(0xFF7D8D92), fontSize: 16),
                ),
              ),
            ),
            if (trailing != null) Icon(trailing, color: const Color(0xFF9FB0B5), size: 24),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recipient details',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          input(Icons.person_outline, 'Recipient full name', _name),
          input(Icons.credit_card, 'Bank / account number or IBAN', _account),
          input(Icons.account_balance, 'Recipient bank', _bank, trailing: Icons.search),
        ],
      ),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _sendBox()),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.swap_horiz, color: _green, size: 26),
              ),
              Expanded(child: _receiveBox()),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: _inputBox(),
            child: Row(
              children: [
                Expanded(child: _infoItem(Icons.toll, 'Transfer fee', 'Free')),
                Container(width: 1, height: 38, color: Colors.white12),
                const SizedBox(width: 12),
                Expanded(child: _infoItem(Icons.schedule, 'Estimated arrival', '1 \u2013 3 business days')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [_green.withValues(alpha: 0.18), _green.withValues(alpha: 0.05)]),
        border: Border.all(color: _green, width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_nigeriaFlag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              const Flexible(
                child: Text('You send', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Text('NGN', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
            ],
          ),
          Row(
            children: [
              const Text('\u20a6', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(width: 2),
              Expanded(
                child: TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiveBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _field,
        border: Border.all(color: const Color(0xFF2A4448)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_dest.flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              const Flexible(
                child: Text('Recipient gets',
                    overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(_dest.currency, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('${_dest.symbol}${_money(_receiveAmount)}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _green.withValues(alpha: 0.12)),
          child: Icon(icon, color: _green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _continueButton() {
    return GestureDetector(
      onTap: _continue,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF3CF0A0), Color(0xFF18D5C0)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continue', style: TextStyle(color: Color(0xFF04201A), fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: Color(0xFF04201A), size: 24),
          ],
        ),
      ),
    );
  }
}


class _DestPicker extends StatefulWidget {
  final List<_Dest> dests;
  const _DestPicker({required this.dests});

  @override
  State<_DestPicker> createState() => _DestPickerState();
}

class _DestPickerState extends State<_DestPicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = widget.dests
        .where((d) => q.isEmpty || d.name.toLowerCase().contains(q) || d.currency.toLowerCase().contains(q))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B1F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF243A40)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF9FB0B5)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _q = v),
                        cursorColor: const Color(0xFF1FE5A0),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Search country or currency',
                          hintStyle: TextStyle(color: Color(0xFF7D8D92), fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('No country found', style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final d = list[i];
                        return ListTile(
                          leading: Text(d.flag, style: const TextStyle(fontSize: 30)),
                          title: Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                          trailing: Text(d.currency, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          onTap: () => Navigator.pop(context, d),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
