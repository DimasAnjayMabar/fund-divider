import 'package:flutter/material.dart';
import 'package:fund_divider/bottom_bar/bottom_bar.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/popups/username/username_popup.dart';
import 'package:fund_divider/storage/money_storage.dart';

class SplashScreen extends StatefulWidget {
  final bool showResetMessage; // Tambahkan parameter
  
  const SplashScreen({super.key, this.showResetMessage = false});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  bool _resetMessageShown = false; // Flag untuk mencegah tampil berulang

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Setup animations
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Start animations
    _animationController.forward();
    
    // Load data
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Tunggu animasi selesai + delay minimal
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Tampilkan pesan reset jika diperlukan (sebelum cek username)
      if (widget.showResetMessage && !_resetMessageShown) {
        await _showResetMessage();
        _resetMessageShown = true;
      }
      
      // Check if username exists
      final hasUsername = WalletService.hasUsername();
      
      if (mounted) {
        if (hasUsername) {
          // Jika username sudah ada, langsung ke BottomBar
          _navigateToHome();
        } else {
          // Jika username belum ada, tampilkan popup
          await _showUsernamePopup();
        }
      }
    } catch (e) {
      // Handle error - tetap lanjut ke home dengan fallback
      if (mounted) {
        _navigateToHome();
      }
    }
  }

  Future<void> _showResetMessage() async {
    // Tunggu animasi selesai
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (context) => const ErrorPopup(
          errorMessage: "Database is reaching 90 days limit. All of your expenses have been reset",
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const BottomBar(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _showUsernamePopup() async {
    // Tunggu animasi selesai
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false, // User harus mengisi username
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (context) => const SaveUsername(isEditMode: false),
      );
      
      // Setelah username disimpan, lanjut ke BottomBar
      if (mounted) {
        if (result != null) {
          _navigateToHome();
        } else {
          // Jika user membatalkan, tetap lanjut ke home
          _navigateToHome();
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget build tetap sama seperti sebelumnya...
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      backgroundColor: const Color(0xFF262626),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        const Color(0xff6F41F2).withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo dengan animasi scale
                    Transform.scale(
                      scale: _logoAnimation.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          width: isSmallScreen ? 160 : 200,
                          height: isSmallScreen ? 160 : 200,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff6F41F2).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/PIGGI.png",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff6F41F2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Text dengan animasi fade
                    Opacity(
                      opacity: _textAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Text(
                              "Piggi",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 28 : 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Manage your finances in your pocket",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Progress indicator dengan animasi
                    Opacity(
                      opacity: _progressAnimation.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: isSmallScreen ? 40 : 50,
                            height: isSmallScreen ? 40 : 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                const Color(0xff6F41F2).withOpacity(0.8),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading your data...",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Version info di pojok kanan bawah
              Positioned(
                bottom: 20,
                right: 20,
                child: Opacity(
                  opacity: _textAnimation.value,
                  child: Text(
                    "v1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}