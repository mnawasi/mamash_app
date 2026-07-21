import 'package:flutter/material.dart';

class SendMoneyPage extends StatefulWidget {
  final String? prefilledAccountNumber;

  const SendMoneyPage({super.key, this.prefilledAccountNumber});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  late final TextEditingController accountController;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isVerifyingAccount = false;
  String? _resolvedAccountName;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  @override
  void initState() {
    super.initState();
    accountController = TextEditingController(text: widget.prefilledAccountNumber ?? "");

    if (widget.prefilledAccountNumber != null && widget.prefilledAccountNumber!.isNotEmpty) {
      // Auto-verify if we arrived here with a scanned account number.
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifyAccount());
    }
  }

  @override
  void dispose() {
    accountController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String? _validateAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a recipient account number";
    }

    if (value.trim().length < 8) {
      return "Enter a valid account number";
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

  Future<void> _verifyAccount() async {
    final accountNumber = accountController.text.trim();

    if (accountNumber.length < 8) {
      setState(() {
        _resolvedAccountName = null;
      });
      return;
    }

    setState(() {
      _isVerifyingAccount = true;
      _resolvedAccountName = null;
    });

    // TODO: Replace with a real account lookup API call that resolves an
    // account number to the account holder's name, so the sender can
    // confirm they're sending to the right person before submitting.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isVerifyingAccount = false;
      _resolvedAccountName = "Account holder name unavailable (not yet connected)";
    });
  }

  Future<void> _handleSendMoney() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual send-money API call, then handle
    // success/failure states (e.g. deduct wallet balance, show a receipt,
    // or surface an error from the backend).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Send money feature coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Send Money"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Wallet Balance",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "₦${_walletBalance.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: accountController,
                keyboardType: TextInputType.text,
                validator: _validateAccount,
                onChanged: (_) => _verifyAccount(),
                decoration: InputDecoration(
                  labelText: "Recipient Account Number",
                  border: const OutlineInputBorder(),
                  suffixIcon: _isVerifyingAccount
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
              ),

              if (_resolvedAccountName != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _resolvedAccountName!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₦",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: noteController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Note (optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _isLoading ? null : _handleSendMoney,
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
                          "SEND MONEY",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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