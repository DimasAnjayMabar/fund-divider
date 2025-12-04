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

  final List<Widget> _pages = [
    const WalletPage(),
    const ExpensesPage(),
    const SavingsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      backgroundColor: Color(0xFFD9D9D9), // Sesuai dengan background wallet page
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
        child: Stack(
          children: [
            SalomonBottomBar(
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
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                // Wallet
                SalomonBottomBarItem(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text("Wallet"),
                  selectedColor: const Color(0xff6F41F2),
                ),
                // Expenses
                SalomonBottomBarItem(
                  icon: const Icon(Icons.edit_note_outlined),
                  title: const Text("Expenses"),
                  selectedColor: const Color(0xff6F41F2),
                ),
                // Placeholder untuk posisi tengah (akan ditimpa tombol scan)
                // SalomonBottomBarItem(
                //   icon: const SizedBox.shrink(),
                //   title: const SizedBox.shrink(),
                //   selectedColor: Colors.transparent,
                // ),
                // Savings
                SalomonBottomBarItem(
                  icon: const Icon(Icons.savings_outlined),
                  title: const Text("Savings"),
                  selectedColor: const Color(0xff6F41F2),
                ),
                // Settings
                SalomonBottomBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  title: const Text("Settings"),
                  selectedColor: const Color(0xff6F41F2),
                ),
              ],
            ),
            
            // Floating Scan Button di Tengah
            // Positioned(
            //   left: MediaQuery.of(context).size.width / 2 - 35,
            //   bottom: 30,
            //   child: GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         _selectedIndex = 2;
            //       });
            //     },
            //     child: Container(
            //       width: 70,
            //       height: 70,
            //       decoration: BoxDecoration(
            //         color: const Color(0xff6F41F2),
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: const Color(0xff6F41F2).withOpacity(0.4),
            //             blurRadius: 20,
            //             spreadRadius: 3,
            //             offset: const Offset(0, 8),
            //           ),
            //           BoxShadow(
            //             color: Colors.white.withOpacity(0.1),
            //             blurRadius: 10,
            //             spreadRadius: -3,
            //             offset: const Offset(-3, -3),
            //           ),
            //         ],
            //         gradient: const LinearGradient(
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //           colors: [
            //             Color(0xff6F41F2),
            //             Color(0xff5A32D6),
            //           ],
            //         ),
            //       ),
            //       child: Stack(
            //         children: [
            //           // Outer ring glow effect
            //           Container(
            //             margin: const EdgeInsets.all(2),
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               border: Border.all(
            //                 color: Colors.white.withOpacity(0.2),
            //                 width: 1,
            //               ),
            //             ),
            //           ),
            //           // Inner content
            //           Center(
            //             child: Container(
            //               padding: const EdgeInsets.all(14),
            //               decoration: BoxDecoration(
            //                 shape: BoxShape.circle,
            //                 color: Colors.white.withOpacity(0.1),
            //               ),
            //               child: Icon(
            //                 Icons.qr_code_scanner_rounded,
            //                 color: Colors.white,
            //                 size: 30,
            //               ),
            //             ),
            //           ),
                      
            //           // Indicator untuk halaman aktif
            //           if (_selectedIndex == 2)
            //             Positioned(
            //               top: 10,
            //               right: 10,
            //               child: Container(
            //                 width: 8,
            //                 height: 8,
            //                 decoration: BoxDecoration(
            //                   color: Colors.white,
            //                   shape: BoxShape.circle,
            //                   border: Border.all(
            //                     color: const Color(0xff6F41F2),
            //                     width: 2,
            //                   ),
            //                 ),
            //               ),
            //             ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}