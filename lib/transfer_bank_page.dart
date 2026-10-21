import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'country_config.dart';
import 'send_common.dart';

class TransferBankPage extends StatefulWidget {
  const TransferBankPage({super.key});

  @override
  State<TransferBankPage> createState() => _TransferBankPageState();
}

class _BankField {
  final String label;
  final String hint;
  final int min;
  final int max;
  const _BankField(this.label, this.hint, this.min, this.max);
}

class _BankSpec {
  final String subtitle;
  final List<String> banks;
  final List<_BankField> fields;
  const _BankSpec(this.subtitle, this.banks, this.fields);
}

class _TransferBankPageState extends State<TransferBankPage> {
  // Banks and account fields for each country (SAMPLE lists, edit to match your provider).
  static const Map<String, _BankSpec> _specs = {
    'Nigeria': _BankSpec('Send to any Nigerian bank', [
      'Access Bank', 'GTBank', 'First Bank', 'UBA', 'Zenith Bank', 'Fidelity Bank', 'Union Bank',
      'Sterling Bank', 'Stanbic IBTC', 'Wema Bank', 'Polaris Bank', 'FCMB', 'Keystone Bank',
      'Ecobank', 'Heritage Bank', 'Unity Bank', 'Providus Bank', 'Jaiz Bank', 'Kuda', 'OPay',
      'PalmPay', 'Moniepoint',
    ], [_BankField('Account number', '10 digits', 10, 10)]),
    'Ghana': _BankSpec('Send to a bank or mobile money', [
      'GCB Bank', 'Ecobank Ghana', 'Stanbic Bank Ghana', 'Absa Ghana', 'Fidelity Bank Ghana',
      'Zenith Bank Ghana', 'MTN MoMo', 'Telecel Cash', 'AT Money',
    ], [_BankField('Account or mobile money number', 'Account or phone number', 8, 16)]),
    'England': _BankSpec('Send to a UK bank account', [
      'Barclays', 'HSBC', 'Lloyds', 'NatWest', 'Santander UK', 'Monzo', 'Starling', 'Revolut',
    ], [_BankField('Sort code', '6 digits', 6, 6), _BankField('Account number', '8 digits', 8, 8)]),
    'USA': _BankSpec('Send to a US bank account', [
      'Chase', 'Bank of America', 'Wells Fargo', 'Citi', 'Capital One', 'US Bank', 'TD Bank', 'PNC',
    ], [_BankField('Routing number', '9 digits', 9, 9), _BankField('Account number', '4 to 17 digits', 4, 17)]),
    'Canada': _BankSpec('Send to a Canadian bank account', [
      'RBC', 'TD', 'Scotiabank', 'BMO', 'CIBC', 'National Bank',
    ], [
      _BankField('Institution number', '3 digits', 3, 3),
      _BankField('Transit number', '5 digits', 5, 5),
      _BankField('Account number', '7 to 12 digits', 7, 12),
    ]),
  };

  CountryConfig _country = CountryConfig.all.first;
  String? _bank;
  List<TextEditingController> _ctrls = [];
  final _narration = TextEditingController();
  int? _amount;

  _BankSpec get _spec => _specs[_country.name] ?? _specs['Nigeria']!;

  @override
  void initState() {
    super.initState();
    _applyCountry(_country);
    loadUserCountry().then((c) {
      if (mounted) setState(() => _applyCountry(c));
    });
  }

  void _applyCountry(CountryConfig c) {
    for (final t in _ctrls) {
      t.dispose();
    }
    _country = c;
    _bank = null;
    _ctrls = List.generate(_spec.fields.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final t in _ctrls) {
      t.dispose();
    }
    _narration.dispose();
    super.dispose();
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _continue() async {
    if (_bank == null) return _msg('Choose a bank');
    for (int i = 0; i < _spec.fields.length; i++) {
      final f = _spec.fields[i];
      final len = _ctrls[i].text.length;
      if (len < f.min || len > f.max) return _msg('Enter a valid ${f.label.toLowerCase()} (${f.hint})');
    }
    final amt = _amount;
    if (amt == null || amt < minAmount(_country)) {
      return _msg('Minimum amount is ${_country.symbol}${fmtNumber(minAmount(_country))}');
    }

    final details = <String>[];
    for (int i = 0; i < _spec.fields.length; i++) {
      details.add('${_spec.fields[i].label}: ${_ctrls[i].text}');
    }
    final ok = await confirmSend(context, 'Confirm bank transfer', [
      'Bank: $_bank',
      ...details,
      'Amount: ${_country.symbol}${fmtNumber(amt)} ${_country.currencyCode}',
      if (_narration.text.trim().isNotEmpty) 'Narration: ${_narration.text.trim()}',
      '',
      'Check the details carefully. Bank transfers can\'t be undone.',
    ]);
    if (ok) _send();
  }

  // TODO: connect real bank transfers here, through your payout provider and a server
  // (a Cloud Function) that checks the balance, the tier limit and the account name.
  void _send() {
    _msg(_country.name == 'Nigeria'
        ? 'Bank transfer is not connected yet'
        : 'Bank transfers to ${_country.name} are coming soon');
  }

  @override
  Widget build(BuildContext context) {
    return SendShell(
      title: 'To Bank',
      subtitle: _spec.subtitle,
      children: [
        SendBanner(
          icon: Icons.account_balance,
          title: 'Send to a bank account',
          subtitle: 'Choose the bank, enter the account details and an amount.',
        ),
        SendPanel(
          title: 'Bank details',
          icon: Icons.account_balance_outlined,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final b = await pickFromList(context, 'Choose a bank', _spec.banks);
                  if (b != null) setState(() => _bank = b);
                },
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: SendTheme.inner,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SendTheme.innerLine),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Color(0xFF9FB0D0), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_bank ?? 'Choose a bank',
                            style: TextStyle(color: _bank == null ? Colors.white30 : Colors.white, fontSize: 16)),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < _spec.fields.length; i++) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(_spec.fields[i].label, style: const TextStyle(color: Color(0xFFB5C4DA), fontSize: 13)),
                  ),
                ),
                SendField(
                  controller: _ctrls[i],
                  hint: _spec.fields[i].hint,
                  icon: Icons.pin_outlined,
                  keyboard: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: _spec.fields[i].max,
                ),
              ],
            ],
          ),
        ),
        SendPanel(
          title: 'Amount',
          icon: Icons.payments_outlined,
          child: Column(
            children: [
              AmountPicker(country: _country, onChanged: (v) => setState(() => _amount = v)),
              const SizedBox(height: 10),
              SendField(
                controller: _narration,
                hint: 'Narration (optional)',
                icon: Icons.edit_note,
                maxLength: 60,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SendButton(label: 'Continue', icon: Icons.send, onTap: _continue),
      ],
    );
  }
}
