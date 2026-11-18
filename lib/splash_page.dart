import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'country_config.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const Color _blue = Color(0xFF2E9BFF);
  Timer? _go;
  Timer? _dots;
  int _dot = 0;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _dots = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) setState(() => _dot = (_dot + 1) % 3);
    });
    _go = Timer(const Duration(seconds: 3), _next);
  }

  void _next() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  @override
  void dispose() {
    _go?.cancel();
    _dots?.cancel();
    super.dispose();
  }

  Widget _feature(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0x33143C8C),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x662E9BFF)),
            ),
            child: Icon(icon, color: _blue, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(List<(IconData, String)> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final f in items) _feature(f.$1, f.$2)],
    );
  }

  Widget _globe() {
    return Container(
      width: 190,
      height: 190,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFF1B63D6), Color(0xFF0A2A6B), Color(0xFF03123A)],
        ),
        boxShadow: [
          BoxShadow(color: Color(0x662E9BFF), blurRadius: 50, spreadRadius: 6),
        ],
      ),
      child: const Icon(Icons.public, size: 120, color: Color(0xFF8CC8FF)),
    );
  }

  Widget _flags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final c in CountryConfig.all)
          Column(
            children: [
              Text(c.flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 2),
              Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
      ],
    );
  }

  Widget _dotsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == _dot ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == _dot ? _blue : const Color(0x663D7BD8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030B2A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF030B2A), Color(0xFF05185A), Color(0xFF0A3A9C)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Image.asset('assets/images/mamash_logo.png', height: 74),
                          const SizedBox(height: 6),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w800),
                              children: [
                                TextSpan(text: 'Mamash ', style: TextStyle(color: Colors.white)),
                                TextSpan(text: 'Pay', style: TextStyle(color: _blue)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'MORE THAN PAYMENTS',
                            style: TextStyle(color: Color(0xFFB9C7E6), fontSize: 12, letterSpacing: 4),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(text: 'Your World, ', style: TextStyle(color: Colors.white)),
                                TextSpan(text: 'Our Priority', style: TextStyle(color: _blue)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _globe(),
                          const Spacer(),
                          _featureRow(const [
                            (Icons.send, 'Send Money'),
                            (Icons.account_balance_wallet, 'Top Up\nAirtime & Data'),
                            (Icons.bolt, 'Pay Bills'),
                            (Icons.flight, 'Book Flights'),
                          ]),
                          const SizedBox(height: 12),
                          _featureRow(const [
                            (Icons.swap_horiz, 'International\nTransfer'),
                            (Icons.card_giftcard, 'Survey Rewards'),
                            (Icons.smart_toy, 'AI Assistant'),
                            (Icons.credit_card, 'Wallet & Card'),
                          ]),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.public, color: _blue, size: 18),
                              SizedBox(width: 6),
                              Text('Available Worldwide',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _flags(),
                          const SizedBox(height: 6),
                          const Text(
                            'MORE COUNTRIES COMING SOON...',
                            style: TextStyle(color: Color(0xFF8FA3CC), fontSize: 9, letterSpacing: 1.5),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF1E6FE8), Color(0xFF2EA8FF)]),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: TextButton(
                                onPressed: _next,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Get Started',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _dotsRow(),
                          const SizedBox(height: 6),
                          const Text('Loading your world...',
                              style: TextStyle(color: Color(0xFF8FA3CC), fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
