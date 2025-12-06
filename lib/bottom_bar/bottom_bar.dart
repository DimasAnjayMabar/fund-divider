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
  
  // Hanya menyimpan instance halaman yang pernah dibuka
  final List<Widget> _pages = [
    const WalletPage(),
    const ExpensesPage(),
    const SavingsPage(),
    const SettingsPage(),
  ];

  // Untuk melacak halaman mana yang sudah pernah di-load
  final List<bool> _loadedPages = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Animasi fade (dissolve) antara halaman
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _getPage(_selectedIndex),
      ),
      backgroundColor: const Color(0xFFD9D9D9),
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
            // Tandai halaman sebagai loaded
            if (!_loadedPages[index]) {
              setState(() {
                _loadedPages[index] = true;
              });
            }
            
            // Ganti halaman dengan animasi fade
            setState(() {
              _selectedIndex = index;
            });
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

  // Method untuk mendapatkan halaman yang sesuai
  Widget _getPage(int index) {
    // Menggunakan Key yang unik untuk setiap halaman agar AnimatedSwitcher bekerja dengan benar
    switch (index) {
      case 0:
        return _pages[0];
      case 1:
        return _loadedPages[1] ? _pages[1] : const ExpensesPage();
      case 2:
        return _loadedPages[2] ? _pages[2] : const SavingsPage();
      case 3:
        return _loadedPages[3] ? _pages[3] : const SettingsPage();
      default:
        return _pages[0];
    }
  }
}