import 'package:flutter/material.dart';
import 'package:fund_divider/model/navbar.dart';
import 'package:fund_divider/pages/expenses_page.dart';
import 'package:fund_divider/pages/wallet_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  final List<Widget>_pages = [
    const WalletPage(), 
    const ExpensesPage()
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      backgroundColor: Color(0xFF262626),
      bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFffde59),
          unselectedItemColor: const Color(0xFFffde59),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: navBarItems),
    );
  }
}
