import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReceiveMoneyPage extends StatelessWidget {
  const ReceiveMoneyPage({super.key});

  // TODO: Replace with the actual account/wallet details from your
  // backend or state management (e.g. tied to the logged-in Firebase
  // user's account record), instead of these placeholder values.
  static const String _accountName = "Mamash Technologies Ltd";
  static const String _accountNumber = "1234567890";
  static const String _bankName = "Mamash Microfinance Bank";

  void _copyAccountNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account number copied")),
    );
  }

  void _shareDetails() {
    SharePlus.instance.share(
      ShareParams(
        text: "Send money to my Mamash wallet:\n"
            "Bank: $_bankName\n"
            "Account Name: $_accountName\n"
            "Account Number: $_accountNumber",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Receive Money"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Your Account Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            const Text(
              "Share these details or your QR code so others can send you money.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    QrImageView(
                      data: _accountNumber,
                      version: QrVersions.auto,
                      size: 180,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Scan to send to $_accountName",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow("Bank Name", _bankName),
                    const Divider(height: 24),
                    _detailRow("Account Name", _accountName),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _detailRow("Account Number", _accountNumber),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copyAccountNumber(context),
                          tooltip: "Copy account number",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _shareDetails,
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "Share Account Details",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}