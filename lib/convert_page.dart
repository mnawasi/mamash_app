import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _Ccy {
  final String code;
  final String name;
  final String flag;
  final String symbol;
  final double ngnPerUnit; // sample indicative rate (how many naira one unit is worth)
  const _Ccy(this.code, this.name, this.flag, this.symbol, this.ngnPerUnit);
}

class _ConvertPageState extends State<ConvertPage> {
  // Sample rates. Replace with a live rate source before launch.
  static const _currencies = [
    _Ccy('NGN', 'Nigerian Naira', '\u{1F1F3}\u{1F1EC}', '\u20a6', 1),
    _Ccy('USD', 'US Dollar', '\u{1F1FA}\u{1F1F8}', '\$', 1450),
    _Ccy('GBP', 'British Pound', '\u{1F1EC}\u{1F1E7}', '\u00a3', 1850),
    _Ccy('GHS', 'Ghanaian Cedi', '\u{1F1EC}\u{1F1ED}', 'GH\u20b5', 95),
  ];

  // Placeholder wallet balances. Connect these to your real wallet data.
  static const Map<String, double> _balances = {
    'NGN': 0.00,
    'USD': 0.00,
    'GBP': 0.00,
    'GHS': 0.00,
  };

  // Conversion fee in percent. 0 means free.
  static const double _feePercent = 0;

  static const Color _bg = Color(0xFF03110F);
  static const Color _panel = Color(0xFF08201D);
  static const Color _green = Color(0xFF1FE5A0);
  static const Color _line = Color(0xFF15463E);

  _Ccy _from = _currencies[0];
  _Ccy _to = _currencies[1];
  final _amount = TextEditingController();

  double get _fromAmount => double.tryParse(_amount.text.trim()) ?? 0;
  double get _rate => _from.ngnPerUnit / _to.ngnPerUnit; // 1 FROM = _rate TO
  double get _fee => _fromAmount * _feePercent / 100;
  double get _toAmount => (_fromAmount - _fee) * _rate;
  double get _balance => _balances[_from.code] ?? 0;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  String _money(double v, {int decimals = 2}) {
    final parts = v.toStringAsFixed(decimals).split('.');
    final s = parts[0];
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return decimals > 0 ? '$b.${parts[1]}' : b.toString();
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
  }

  Future<void> _pick(bool isFrom) async {
    final c = await showModalBottomSheet<_Ccy>(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _currencies
            .map((c) => ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 26)),
                  title: Text('${c.code}  \u2022  ${c.name}', style: const TextStyle(color: Colors.white)),
                  trailing: Text('${c.symbol}${_money(_balances[c.code] ?? 0)}',
                      style: const TextStyle(color: Colors.white54)),
                  onTap: () => Navigator.pop(context, c),
                ))
            .toList(),
      ),
    );
    if (c == null) return;
    setState(() {
      if (isFrom) {
        if (c == _to) _to = _from;
        _from = c;
      } else {
        if (c == _from) _from = _to;
        _to = c;
      }
    });
  }

  Future<void> _continue() async {
    final amt = _fromAmount;
    if (amt <= 0) return _msg('Enter the amount you want to convert');
    if (amt > _balance) return _msg('Not enough ${_from.code} in your wallet');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _panel,
        title: const Text('Confirm conversion', style: TextStyle(color: Colors.white)),
        content: Text(
          'You convert: ${_from.symbol}${_money(amt)} ${_from.code}\n'
          'Rate: 1 ${_from.code} \u2248 ${_to.symbol}${_money(_rate, decimals: _rate < 1 ? 6 : 2)}\n'
          'Fee: ${_feePercent == 0 ? 'Free' : '${_from.symbol}${_money(_fee)}'}\n'
          'You receive: ${_to.symbol}${_money(_toAmount)} ${_to.code}',
          style: const TextStyle(color: Colors.white70, height: 1.6),
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
    if (ok == true) _convert();
  }

  // TODO: connect real conversion here. It must run on your server (for example a
  // Cloud Function) that checks the balance, applies the rate and fee, and debits one wallet
  // and credits the other in a single step. The app must not change balances itself.
  void _convert() {
    _msg('Conversion is not connected yet');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 18),
                _fromCard(),
                _swapButton(),
                _toCard(),
                const SizedBox(height: 14),
                _details(),
                const SizedBox(height: 20),
                _convertButton(),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Rates are indicative. The final rate is shown before you confirm.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8FB3B0), fontSize: 12.5)),
                ),
              ],
            ),
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
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Convert', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              Text('Swap between your currencies', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _green.withValues(alpha: 0.12),
            border: Border.all(color: _green.withValues(alpha: 0.6)),
          ),
          child: const Icon(Icons.swap_horiz, color: _green, size: 26),
        ),
      ],
    );
  }

  BoxDecoration _card({bool highlight = false}) => BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: highlight
            ? const LinearGradient(colors: [Color(0xFF0E4A3A), Color(0xFF0A2A2A)])
            : const LinearGradient(colors: [Color(0xFF0B2A3A), Color(0xFF08181F)]),
        border: Border.all(color: highlight ? _green.withValues(alpha: 0.7) : _line, width: highlight ? 1.4 : 1),
      );

  Widget _currencyChip(_Ccy c, bool isFrom) {
    return GestureDetector(
      onTap: () => _pick(isFrom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(c.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(c.code, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _fromCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(highlight: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('From', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
              const Spacer(),
              _currencyChip(_from, true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(_from.symbol, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text('Balance: ${_from.symbol}${_money(_balance)}',
                    style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
              ),
              GestureDetector(
                onTap: () => setState(() => _amount.text = _balance == 0 ? '' : _balance.toStringAsFixed(2)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _green),
                  ),
                  child: const Text('Max', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swapButton() {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, 0),
        child: GestureDetector(
          onTap: _swap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF0FA672)]),
              boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 12)],
            ),
            child: const Icon(Icons.swap_vert, color: Color(0xFF04201A), size: 28),
          ),
        ),
      ),
    );
  }

  Widget _toCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('To', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
              const Spacer(),
              _currencyChip(_to, false),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('${_to.symbol}${_money(_toAmount)}',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 6),
          Text('Balance: ${_to.symbol}${_money(_balances[_to.code] ?? 0)}',
              style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _details() {
    Widget row(String label, String value, {bool bold = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(color: Color(0xFFB5D4D0), fontSize: 14))),
            Text(value,
                style: TextStyle(
                    color: Colors.white, fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Exchange rate', style: TextStyle(color: Color(0xFFB5D4D0), fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withValues(alpha: 0.5)),
                ),
                child: const Text('Indicative', style: TextStyle(color: _green, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Text('1 ${_from.code} \u2248 ${_to.symbol}${_money(_rate, decimals: _rate < 1 ? 6 : 2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const Divider(color: Colors.white12, height: 14),
          row('Fee', _feePercent == 0 ? 'Free' : '${_from.symbol}${_money(_fee)}'),
          const Divider(color: Colors.white12, height: 14),
          row('You\'ll receive', '${_to.symbol}${_money(_toAmount)}', bold: true),
        ],
      ),
    );
  }

  Widget _convertButton() {
    return GestureDetector(
      onTap: _continue,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF1FE5A0), Color(0xFF14C9A8)]),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16)],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, color: Color(0xFF04201A), size: 26),
            SizedBox(width: 10),
            Text('Convert', style: TextStyle(color: Color(0xFF04201A), fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
