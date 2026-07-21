import 'package:flutter/material.dart';

class TransferBankPage extends StatefulWidget {
  const TransferBankPage({super.key});

  @override
  State<TransferBankPage> createState() => _TransferBankPageState();
}

class _TransferBankPageState extends State<TransferBankPage> {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController narrationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedBank;
  bool _isLoading = false;
  bool _isResolvingAccount = false;
  String? _resolvedAccountName;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  final List<String> banks = [
    "Access Bank",
    "First Bank",
    "GTBank",
    "UBA",
    "Zenith Bank",
    "Opay",
    "PalmPay",
    "Moniepoint",
    "Kuda",
    "Fidelity Bank",
  ];

  @override
  void dispose() {
    accountNumberController.dispose();
    amountController.dispose();
    narrationController.dispose();
    super.dispose();
  }

  Future<void> _resolveAccountName() async {
    final accountNumber = accountNumberController.text.trim();

    if (selectedBank == null || accountNumber.length != 10) {
      setState(() {
        _resolvedAccountName = null;
      });
      return;
    }

    setState(() {
      _isResolvingAccount = true;
      _resolvedAccountName = null;
    });

    // TODO: Replace with a real bank account name resolution API call
    // (e.g. Paystack's "resolve account number" endpoint, or Flutterwave's
    // equivalent). This is what actually confirms the account number
    // belongs to a real person before the user sends money — critical for
    // preventing costly mistakes from typos in the account number.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isResolvingAccount = false;
      _resolvedAccountName = "Account name resolution not yet connected";
    });
  }

  String? _validateBank() {
    if (selectedBank == null) return "Please select a bank";
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an account number";
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return "Account number must be 10 digits";
    }

    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an amount";
    }

    final amount = double.tryParse(value.trim());

    if (amount == null) {
      return "Enter a valid number";
    }

    if (amount <= 0) {
      return "Amount must be greater than zero";
    }

    if (amount > _walletBalance) {
      return "Insufficient wallet balance";
    }

    return null;
  }

  Future<void> _handleContinue() async {
    if (_validateBank() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_validateBank()!)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual bank transfer API call, then handle
    // success/failure states (e.g. deduct wallet balance, show a receipt,
    // or surface an error from the provider).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bank transfer feature coming soon.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer to Bank"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Send Money",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              DropdownButtonFormField<String>(
                initialValue: selectedBank,
                decoration: const InputDecoration(
                  labelText: "Select Bank",
                  border: OutlineInputBorder(),
                ),
                items: banks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBank = value;
                  });
                  _resolveAccountName();
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                validator: _validateAccountNumber,
                onChanged: (_) => _resolveAccountName(),
                decoration: const InputDecoration(
                  labelText: "Account Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (_isResolvingAccount)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_isResolvingAccount) const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _resolvedAccountName ?? "Account Name will appear here",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₦ ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: narrationController,
                decoration: const InputDecoration(
                  labelText: "Narration (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _isLoading ? null : _handleContinue,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}