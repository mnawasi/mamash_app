import 'package:flutter/material.dart';

class AddMoneyPage extends StatefulWidget {
  const AddMoneyPage({super.key});

  @override
  State<AddMoneyPage> createState() => _AddMoneyPageState();
}

class _AddMoneyPageState extends State<AddMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

    if (amount < 100) {
      return "Minimum amount is ₦100";
    }

    if (amount > 1000000) {
      return "Maximum amount is ₦1,000,000";
    }

    return null;
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual funding API call (e.g. Paystack/Flutterwave
    // initialization, then navigate to a payment confirmation screen once
    // the backend confirms the transaction via webhook).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    _showComingSoon(
      "Funding feature will be connected soon. Amount: ₦${amount.toStringAsFixed(2)}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Add Money"),
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
                "Fund Your Wallet",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter the amount you want to add.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₦ ",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Choose Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                    color: Colors.green,
                  ),
                  title: const Text("Bank Transfer"),
                  subtitle: const Text("Transfer directly to your wallet"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Mamash Bank Transfer"),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Bank Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Mamash Microfinance Bank"),

                            SizedBox(height: 15),

                            Text(
                              "Account Number",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SelectableText("1234567890"),

                            SizedBox(height: 15),

                            Text(
                              "Account Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Mamash Technologies Ltd"),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.credit_card,
                    color: Colors.blue,
                  ),
                  title: const Text("Debit Card"),
                  subtitle: const Text("Pay with your ATM card"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showComingSoon("Paystack integration coming soon."),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.phone_android,
                    color: Colors.orange,
                  ),
                  title: const Text("USSD"),
                  subtitle: const Text("Pay using your bank USSD"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showComingSoon("USSD payment coming soon."),
                ),
              ),

              const SizedBox(height: 40),

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