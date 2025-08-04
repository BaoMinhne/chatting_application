import 'package:chatting_application/pages/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:chatting_application/pages/home.dart';

import 'package:chatting_application/services/shared_pref.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 4)); // delay splash

    String? userId = await SharedPreferenceHelper().getUserId();

    if (context.mounted) {
      if (userId != null && userId.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Onboarding()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 193, 226),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/Email.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              "Online Chatting",
              style: TextStyle(
                fontSize: 30,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1A58),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Hello, Welcome to my Chat Application",
              style: TextStyle(
                color: Color(0xFF616161),
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "-- Be Helpful to connect to everyone around the World --",
              style: TextStyle(
                color: Color(0xFF616161),
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
