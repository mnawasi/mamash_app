import 'package:flutter/material.dart';

import 'add_money_page.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  // TODO: Replace with the actual wallet balance from your state
  // management / backend (e.g. a Provider, Bloc, or Riverpod source), so
  // this stays in sync with DashboardPage and the service pages instead
  // of each showing its own independent ₦0.00.
  static const double _walletBalance = 0.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallet"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Balance",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₦${_walletBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddMoneyPage(),
                    ),
                  );
                },
                child: const Text("Add Money"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Point this to a real WithdrawPage once built,
                  // consistent with DashboardPage's Withdraw quick action.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Withdraw coming soon...")),
                  );
                },
                child: const Text("Withdraw"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}