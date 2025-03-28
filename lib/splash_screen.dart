import 'package:flutter/material.dart';
import 'package:fund_divider/bottom_bar/bottom_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading time
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomBar()), // Navigate to main screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF262626), // Set background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100), // Make it rounded
              child: Image.asset(
                "assets/images/download.png",
                width: 200, 
                height: 200,
                fit: BoxFit.cover, // Ensures image fills the shape
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Fund Divider",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(), // Show loading indicator
          ],
        ),
      ),
    );
  }
}
