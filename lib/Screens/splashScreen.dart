import 'package:expense_tracker_app/Constants/appColors.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animate floating icons
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryBlueLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative icons
            Positioned(
              top: 50,
              left: 30,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.attach_money,
                  color: AppColors.white.withOpacity(0.3),
                  size: 50,
                ),
              ),
            ),
            Positioned(
              top: 120,
              right: 40,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, -_animation.value),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.pie_chart_outline,
                  color: AppColors.white.withOpacity(0.3),
                  size: 40,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 50,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value / 2),
                    child: child,
                  );
                },
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.white.withOpacity(0.3),
                  size: 45,
                ),
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Expense Tracker",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Track your expenses easily",
                    style: TextStyle(color: AppColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
