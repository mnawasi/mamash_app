import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Timing now matches the animation duration instead of an unrelated
    // fixed 3 seconds, so there's no dead pause after the animation ends.
    Timer(const Duration(milliseconds: 1800), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;

    // TODO: If you add a "remember me" preference or want to force
    // re-authentication after a period of inactivity, add that check
    // here alongside currentUser.
    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null ? const DashboardPage() : const LoginPage(),
      ),
    );

    // TODO: Once face verification is fully wired to a real biometric
    // provider (see FaceVerificationPage), consider routing signed-in
    // users through FaceVerificationPage instead of straight to
    // DashboardPage, so returning users are re-verified each session
    // rather than only at login.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/mamash_logo.jpg",
                      width: 220,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Color(0xFFD4AF37),
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 45),

                  const CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                    strokeWidth: 3,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Loading your experience...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}