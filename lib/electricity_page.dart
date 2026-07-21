import 'package:flutter/material.dart';

class ElectricityPage extends StatefulWidget {
  const ElectricityPage({super.key});

  @override
  State<ElectricityPage> createState() => _ElectricityPageState();
}

class _ElectricityPageState extends State<ElectricityPage> {
  final TextEditingController meterController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedDisco;
  String? selectedMeterType;
  bool _isLoading = false;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  final List<String> discos = [
    "IKEDC",
    "EKEDC",
    "AEDC",
    "IBEDC",
    "KEDCO",
    "PHED",
    "EEDC",
    "BEDC",
    "KAEDCO",
    "JED",
  ];

  @override
  void dispose() {
    meterController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String? _validateMeterNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your meter number";
    }

    final meter = value.trim();

    if (!RegExp(r'^[0-9]{10,13}$').hasMatch(meter)) {
      return "Enter a valid meter number";
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

    if (amount < 500) {
      return "Minimum payment amount is ₦500";
    }

    if (amount > 500000) {
      return "Maximum payment amount is ₦500,000";
    }

    if (amount > _walletBalance) {
      return "Insufficient wallet balance";
    }

    return null;
  }

  Future<void> _handlePayBill() async {
    if (selectedDisco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a distribution company")),
      );
      return;
    }

    if (selectedMeterType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a meter type")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual electricity payment API call. Typically
    // this involves a "verify" step first (confirm the meter number and
    // show the customer's name before charging), then a "vend" step that
    // returns a prepaid token, then handling success/failure states.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Electricity payment coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Electricity"),
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

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedDisco,
                decoration: const InputDecoration(
                  labelText: "Distribution Company",
                  border: OutlineInputBorder(),
                ),
                items: discos.map((disco) {
                  return DropdownMenuItem(
                    value: disco,
                    child: Text(disco),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDisco = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedMeterType,
                decoration: const InputDecoration(
                  labelText: "Meter Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Prepaid",
                    child: Text("Prepaid"),
                  ),
                  DropdownMenuItem(
                    value: "Postpaid",
                    child: Text("Postpaid"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedMeterType = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: meterController,
                keyboardType: TextInputType.number,
                validator: _validateMeterNumber,
                decoration: const InputDecoration(
                  labelText: "Meter Number",
                  border: OutlineInputBorder(),
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
                          "PAY ELECTRICITY BILL",
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