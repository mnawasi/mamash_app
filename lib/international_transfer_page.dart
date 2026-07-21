import 'package:flutter/material.dart';

class InternationalTransferPage extends StatefulWidget {
  const InternationalTransferPage({super.key});

  @override
  State<InternationalTransferPage> createState() => _InternationalTransferPageState();
}

class _InternationalTransferPageState extends State<InternationalTransferPage> {
  final TextEditingController recipientNameController = TextEditingController();
  final TextEditingController recipientAccountController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCountry;
  String? selectedCurrency;
  bool _isLoading = false;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  // TODO: Replace with your real supported corridors. Each country should
  // map to the currency you actually settle in for that corridor.
  final Map<String, String> countryToCurrency = {
    "United States": "USD",
    "United Kingdom": "GBP",
    "Canada": "CAD",
    "Ghana": "GHS",
    "South Africa": "ZAR",
  };

  @override
  void dispose() {
    recipientNameController.dispose();
    recipientAccountController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String? _validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter the recipient's full name";
    }

    if (value.trim().split(" ").length < 2) {
      return "Enter the recipient's full legal name";
    }

    return null;
  }

  String? _validateRecipientAccount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter the recipient's account/IBAN number";
    }

    if (value.trim().length < 6) {
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

    if (amount < 1000) {
      return "Minimum transfer amount is ₦1,000";
    }

    if (amount > 2000000) {
      return "Maximum transfer amount is ₦2,000,000";
    }

    if (amount > _walletBalance) {
      return "Insufficient wallet balance";
    }

    return null;
  }

  Future<void> _handleContinue() async {
    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a destination country")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with a real cross-border payment provider integration
    // (e.g. Flutterwave, Wise Platform, Thunes) via your backend. This
    // flow will also require KYC checks, sanctions/AML screening, and
    // FX rate confirmation before any funds move.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("International transfers coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("International Transfer"),
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

              DropdownButtonFormField<String>(
                initialValue: selectedCountry,
                decoration: const InputDecoration(
                  labelText: "Destination Country",
                  border: OutlineInputBorder(),
                ),
                items: countryToCurrency.keys.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCountry = value;
                    selectedCurrency = value != null ? countryToCurrency[value] : null;
                  });
                },
              ),

              if (selectedCurrency != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recipient will receive funds in $selectedCurrency",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              TextFormField(
                controller: recipientNameController,
                keyboardType: TextInputType.name,
                validator: _validateRecipientName,
                decoration: const InputDecoration(
                  labelText: "Recipient Full Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: recipientAccountController,
                keyboardType: TextInputType.text,
                validator: _validateRecipientAccount,
                decoration: const InputDecoration(
                  labelText: "Recipient Account/IBAN Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _validateAmount,
                decoration: const InputDecoration(
                  labelText: "Amount to Send",
                  prefixText: "₦",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
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
                          "CONTINUE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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