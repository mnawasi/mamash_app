import 'package:flutter/material.dart';

class TvSubscriptionPage extends StatefulWidget {
  const TvSubscriptionPage({super.key});

  @override
  State<TvSubscriptionPage> createState() => _TvSubscriptionPageState();
}

class _TvSubscriptionPageState extends State<TvSubscriptionPage> {
  final TextEditingController smartCardController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedProvider;
  String? selectedBouquet;
  bool _isLoading = false;
  bool _isVerifyingCard = false;
  String? _resolvedCustomerName;

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source).
  final double _walletBalance = 0.00;

  final List<String> providers = [
    "DStv",
    "GOtv",
    "Startimes",
  ];

  // TODO: Replace with real bouquets/prices per provider from your bill
  // payment provider's API — these change periodically (e.g. DStv price
  // adjustments), so hardcoding them long-term will drift out of date.
  final Map<String, List<String>> bouquetsByProvider = {
    "DStv": [
      "DStv Padi - ₦2,950",
      "DStv Yanga - ₦3,950",
      "DStv Confam - ₦6,200",
      "DStv Compact - ₦15,700",
      "DStv Compact Plus - ₦25,000",
      "DStv Premium - ₦37,000",
    ],
    "GOtv": [
      "GOtv Smallie - ₦1,575",
      "GOtv Jinja - ₦3,300",
      "GOtv Jolli - ₦4,850",
      "GOtv Max - ₦6,150",
      "GOtv Supa - ₦8,500",
    ],
    "Startimes": [
      "Nova - ₦1,900",
      "Basic - ₦4,200",
      "Smart - ₦5,300",
      "Classic - ₦6,000",
      "Super - ₦9,800",
    ],
  };

  List<String> get _availableBouquets => bouquetsByProvider[selectedProvider] ?? [];

  @override
  void dispose() {
    smartCardController.dispose();
    super.dispose();
  }

  Future<void> _verifySmartCard() async {
    final cardNumber = smartCardController.text.trim();

    if (selectedProvider == null || cardNumber.length < 8) {
      setState(() {
        _resolvedCustomerName = null;
      });
      return;
    }

    setState(() {
      _isVerifyingCard = true;
      _resolvedCustomerName = null;
    });

    // TODO: Replace with a real smart card/IUC verification API call
    // (typically part of the same bill payment provider you use for
    // electricity, e.g. via a "verify" endpoint before "vend"). This
    // confirms the card number is valid and shows the customer's name
    // before charging, so a mistyped card number doesn't waste the
    // payment.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _isVerifyingCard = false;
      _resolvedCustomerName = "Card verification not yet connected";
    });
  }

  String? _validateSmartCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your Smart Card / IUC number";
    }

    if (value.trim().length < 8) {
      return "Enter a valid Smart Card / IUC number";
    }

    return null;
  }

  Future<void> _handlePaySubscription() async {
    if (selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a TV provider")),
      );
      return;
    }

    if (selectedBouquet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a bouquet")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual TV subscription payment API call, then
    // handle success/failure states (e.g. deduct wallet balance, show a
    // receipt, or surface an error from the provider).
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("TV subscription coming soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("TV Subscription"),
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
                initialValue: selectedProvider,
                decoration: const InputDecoration(
                  labelText: "TV Provider",
                  border: OutlineInputBorder(),
                ),
                items: providers.map((provider) {
                  return DropdownMenuItem(
                    value: provider,
                    child: Text(provider),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProvider = value;
                    selectedBouquet = null;
                  });
                  _verifySmartCard();
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: smartCardController,
                keyboardType: TextInputType.number,
                validator: _validateSmartCard,
                onChanged: (_) => _verifySmartCard(),
                decoration: const InputDecoration(
                  labelText: "Smart Card / IUC Number",
                  border: OutlineInputBorder(),
                ),
              ),

              if (_resolvedCustomerName != null || _isVerifyingCard) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      if (_isVerifyingCard)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (_isVerifyingCard) const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _resolvedCustomerName ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedBouquet,
                decoration: const InputDecoration(
                  labelText: "Select Bouquet",
                  border: OutlineInputBorder(),
                ),
                items: _availableBouquets.map((bouquet) {
                  return DropdownMenuItem(
                    value: bouquet,
                    child: Text(bouquet),
                  );
                }).toList(),
                onChanged: selectedProvider == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedBouquet = value;
                        });
                      },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePaySubscription,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text(
                          "PAY TV SUBSCRIPTION",
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