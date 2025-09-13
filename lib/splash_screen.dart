import 'package:flutter/material.dart';
import 'package:fund_divider/bottom_bar/bottom_bar.dart';
import 'package:fund_divider/popups/username/username_popup.dart';
import 'package:fund_divider/storage/money_storage.dart';

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
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if username exists
    final hasUsername = WalletService.hasUsername();
    
    if (mounted) {
      if (hasUsername) {
        // Jika username sudah ada, langsung ke BottomBar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      } else {
        // Jika username belum ada, tampilkan popup
        _showUsernamePopup();
      }
    }
  }

  Future<void> _showUsernamePopup() async {
    // Tunggu sebentar agar splash screen terlihat
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false, // User harus mengisi username
        builder: (context) => const SaveUsername(),
      );
      
      // Setelah username disimpan, lanjut ke BottomBar
      if (mounted && result != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomBar()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(
                "assets/images/PIGGI.png",
                width: 200, 
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Manage your financial in your pocket",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}