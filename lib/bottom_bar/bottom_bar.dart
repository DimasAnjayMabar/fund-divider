import 'package:flutter/material.dart';
import 'package:fund_divider/model/navbar.dart';
import 'package:fund_divider/pages/expenses_page.dart';
import 'package:fund_divider/pages/savings_page.dart';
import 'package:fund_divider/pages/scan_transaction.dart';
import 'package:fund_divider/pages/settings_page.dart';
import 'package:fund_divider/pages/wallet_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const WalletPage(),
    const ExpensesPage(),
    const SavingsPage(),
    const SettingsPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Nonaktifkan swipe manual
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      backgroundColor: Color(0xFFD9D9D9),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SalomonBottomBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xff6F41F2),
          unselectedItemColor: Colors.grey[600],
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          itemPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          curve: Curves.easeInOut,
          onTap: (index) {
            // Animasi geser ke halaman yang dituju
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text("Wallet"),
              selectedColor: const Color(0xff6F41F2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.edit_note_outlined),
              title: const Text("Expenses"),
              selectedColor: const Color(0xff6F41F2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.savings_outlined),
              title: const Text("Savings"),
              selectedColor: const Color(0xff6F41F2),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              selectedColor: const Color(0xff6F41F2),
            ),
          ],
        ),
      ),
    );
  }
}