import 'package:flutter/material.dart';

class TransferBankPage extends StatefulWidget {
  const TransferBankPage({super.key});

  @override
  State<TransferBankPage> createState() => _TransferBankPageState();
}

class _TransferBankPageState extends State<TransferBankPage> {
  String? _selectedBank;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _resolvedAccountName;
  bool _isResolving = false;

  static const Color _bgDark = Color(0xFF121212);
  static const Color _cardDark = Color(0xFF1E1E1E);
  static const Color _accentGreen = Color(0xFF1DBF8A);

  final List<Map<String, String>> _banks = [
    {'name': 'Access Bank', 'code': '044'},
    {'name': 'GTBank', 'code': '058'},
    {'name': 'Zenith Bank', 'code': '057'},
    {'name': 'First Bank', 'code': '011'},
    {'name': 'UBA', 'code': '033'},
    {'name': 'Kuda Bank', 'code': '090267'},
    {'name': 'Opay', 'code': '999992'},
    {'name': 'Moniepoint', 'code': '999993'},
  ];

  void _tryResolveAccount() {
    if (_selectedBank != null && _accountController.text.length == 10) {
      setState(() => _isResolving = true);
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _isResolving = false;
            _resolvedAccountName = 'Chinedu Adamu Okoro';
          });
        }
      });
    } else {
      setState(() => _resolvedAccountName = null);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBankAndAccountCard(),
                    const SizedBox(height: 16),
                    if (_resolvedAccountName != null) _buildAmountCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Transfer to Bank',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAndAccountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select bank', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _showBankPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedBank ?? 'Choose a bank',
                      style: TextStyle(
                        color: _selectedBank != null ? Colors.white : Colors.white38,
                        fontSize: 14,
                        fontWeight: _selectedBank != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Colors.white54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Account number', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              onChanged: (_) => _tryResolveAccount(),
              decoration: const InputDecoration(
                hintText: '0123456789',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          if (_isResolving) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _accentGreen),
                ),
                SizedBox(width: 10),
                Text('Resolving account...', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
          if (_resolvedAccountName != null && !_isResolving) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accentGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accentGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: _accentGreen, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _resolvedAccountName!,
                    style: const TextStyle(color: _accentGreen, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBankPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _banks.map((b) {
              return ListTile(
                title: Text(b['name']!, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _selectedBank = b['name'];
                    _resolvedAccountName = null;
                  });
                  Navigator.pop(context);
                  _tryResolveAccount();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              prefixText: '₦ ',
              prefixStyle: const TextStyle(color: Colors.white, fontSize: 20),
              filled: true,
              fillColor: const Color(0xFF262626),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _noteController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'What\'s it for? (optional)',
                labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
