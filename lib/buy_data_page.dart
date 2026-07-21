import 'package:flutter/material.dart';

class BuyDataPage extends StatefulWidget {
  const BuyDataPage({super.key});

  @override
  State<BuyDataPage> createState() => _BuyDataPageState();
}

class _BuyDataPageState extends State<BuyDataPage> {
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedNetwork;
  String? selectedPlan;
  bool _isLoading = false;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  final List<String> networks = [
    "MTN",
    "Airtel",
    "Glo",
    "9mobile",
  ];

  // TODO: Replace with real plans/prices per network from your data
  // provider's API — these vary by network in practice and change often,
  // so hardcoding them long-term will drift out of date.
  final Map<String, List<String>> plansByNetwork = {
    "MTN": ["500MB - ₦150", "1GB - ₦300", "2GB - ₦600", "5GB - ₦1500", "10GB - ₦3000"],
    "Airtel": ["500MB - ₦150", "1GB - ₦300", "2GB - ₦550", "5GB - ₦1400", "10GB - ₦2800"],
    "Glo": ["500MB - ₦140", "1GB - ₦280", "2GB - ₦550", "5GB - ₦1350", "10GB - ₦2700"],
    "9mobile": ["500MB - ₦150", "1GB - ₦300", "2GB - ₦600", "5GB - ₦1500", "10GB - ₦3000"],
  };

  List<String> get _availablePlans => plansByNetwork[selectedNetwork] ?? [];

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a phone number";
    }

    final phone = value.trim();
    final phoneRegex = RegExp(r'^(0[7-9][0-1][0-9]{8}|\+234[7-9][0-1][0-9]{8})$');

    if (!phoneRegex.hasMatch(phone)) {
      return "Enter a valid Nigerian phone number";
    }

    return null;
  }

  Future<void> _handleBuyData() async {
    if (selectedNetwork == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a network")),
      );
      return;
    }

    if (selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a data plan")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual data purchase API call, then handle
    // success/failure states (e.g. deduct wallet balance, show a receipt,
    // or surface an error from the provider).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data purchase coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Buy Data"),
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
                initialValue: selectedNetwork,
                decoration: const InputDecoration(
                  labelText: "Select Network",
                  border: OutlineInputBorder(),
                ),
                items: networks.map((network) {
                  return DropdownMenuItem(
                    value: network,
                    child: Text(network),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedNetwork = value;
                    selectedPlan = null;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "08012345678",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedPlan,
                decoration: const InputDecoration(
                  labelText: "Select Data Plan",
                  border: OutlineInputBorder(),
                ),
                items: _availablePlans.map((plan) {
                  return DropdownMenuItem(
                    value: plan,
                    child: Text(plan),
                  );
                }).toList(),
                onChanged: selectedNetwork == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedPlan = value;
                        });
                      },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleBuyData,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          "BUY DATA",
                          style: TextStyle(fontSize: 18),
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