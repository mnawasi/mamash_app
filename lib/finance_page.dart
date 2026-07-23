import 'package:flutter/material.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111214),
        title: const Text('Finance', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1D20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bar_chart_rounded, color: Color(0xFF16C784), size: 48),
              SizedBox(height: 16),
              Text('Finance coming soon',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Spending insights, budgeting and statements will live here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
