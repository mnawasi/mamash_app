import 'package:flutter/material.dart';

class TransferMamashPage extends StatefulWidget {
  const TransferMamashPage({super.key});

  @override
  State<TransferMamashPage> createState() => _TransferMamashPageState();
}

class _TransferMamashPageState extends State<TransferMamashPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isResolvingRecipient = false;
  String? _resolvedRecipientName;
  String? _recipientLookupError;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _resolveRecipient() async {
    final phone = phoneController.text.trim();
    final phoneRegex = RegExp(r'^(0[7-9][0-1][0-9]{8}|\+234[7-9][0-1][0-9]{8})$');

    if (!phoneRegex.hasMatch(phone)) {
      setState(() {
        _resolvedRecipientName = null;
        _recipientLookupError = null;
      });
      return;
    }

    setState(() {
      _isResolvingRecipient = true;
      _resolvedRecipientName = null;
      _recipientLookupError = null;
    });

    // TODO: Replace with a real lookup against your backend/user database
    // to find the Mamash account registered to this phone number. This
    // is the actual identity check for internal transfers — never let
    // the sender manually type the recipient's name, since a typed name
    // doesn't confirm the phone number belongs to that person and money
    // could go to the wrong account with the sender none the wiser.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // TODO: Replace this placeholder logic with the real lookup result:
    // - if found, set _resolvedRecipientName to the real account holder's name
    // - if not found, set _recipientLookupError to something like
    //   "No Mamash account found for this number"
    setState(() {
      _isResolvingRecipient = false;
      _resolvedRecipientName = "Recipient lookup not yet connected";
    });
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter the recipient's phone number";
    }

    final phoneRegex = RegExp(r'^(0[7-9][0-1][0-9]{8}|\+234[7-9][0-1][0-9]{8})$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter a valid Nigerian phone number";
    }

    if (_recipientLookupError != null) {
      return _recipientLookupError;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_resolvedRecipientName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for recipient verification to complete")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual internal transfer API call, then handle
    // success/failure states (e.g. deduct wallet balance, credit
    // recipient's wallet, show a receipt, or surface an error).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transfer feature coming soon")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer to Mamash"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                onChanged: (_) => _resolveRecipient(),
                decoration: const InputDecoration(
                  labelText: "Recipient Phone Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _recipientLookupError != null
                      ? Colors.red.shade50
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (_isResolvingRecipient)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (_isResolvingRecipient) const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _recipientLookupError ??
                            _resolvedRecipientName ??
                            "Recipient name will appear here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _recipientLookupError != null ? Colors.red.shade700 : null,
                        ),
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
                  labelText: "Amount (₦)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Description (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

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