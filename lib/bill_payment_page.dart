import 'package:flutter/material.dart';

class BillPaymentPage extends StatefulWidget {
  const BillPaymentPage({super.key});

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  final TextEditingController meterOrCardNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCategory;
  String? selectedProvider;
  bool _isLoading = false;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  final Map<String, List<String>> providersByCategory = {
    "Electricity": ["EKEDC", "IKEDC", "AEDC", "PHED", "KEDCO"],
    "Cable TV": ["DSTV", "GOtv", "Startimes"],
    "Internet": ["Spectranet", "Smile", "Swift"],
  };

  List<String> get _availableProviders =>
      providersByCategory[selectedCategory] ?? [];

  @override
  void dispose() {
    meterOrCardNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return selectedCategory == "Electricity"
          ? "Please enter your meter number"
          : "Please enter your smartcard/account number";
    }

    if (value.trim().length < 5) {
      return "Enter a valid number";
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

    if (amount < 100) {
      return "Minimum payment amount is ₦100";
    }

    if (amount > 1000000) {
      return "Maximum payment amount is ₦1,000,000";
    }

    if (amount > _walletBalance) {
      return "Insufficient wallet balance";
    }

    return null;
  }

  Future<void> _handlePayBill() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bill category")),
      );
      return;
    }

    if (selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a provider")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual bill payment API call. Typically this
    // involves a "verify" step first (confirm meter/smartcard number and
    // show the customer's name), then a "pay" step, then handling
    // success/failure and updating wallet balance.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bill payment coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Bill Payment"),
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
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Select Bill Category",
                  border: OutlineInputBorder(),
                ),
                items: providersByCategory.keys.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedProvider = null;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedProvider,
                decoration: const InputDecoration(
                  labelText: "Select Provider",
                  border: OutlineInputBorder(),
                ),
                items: _availableProviders.map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider),
                  );
                }).toList(),
                onChanged: selectedCategory == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedProvider = value;
                        });
                      },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: meterOrCardNumberController,
                keyboardType: TextInputType.number,
                validator: _validateNumber,
                decoration: InputDecoration(
                  labelText: selectedCategory == "Electricity"
                      ? "Meter Number"
                      : "Smartcard/Account Number",
                  border: const OutlineInputBorder(),
                ),
              ),

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

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePayBill,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          "PAY BILL",
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