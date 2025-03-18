import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

final navBarItems = [
  SalomonBottomBarItem(
    icon: const Icon(Icons.account_balance_wallet),
    title: const Text("Wallet"),
    selectedColor: Color(0xFFffde59),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.edit_note),
    title: const Text("Expenses"),
    selectedColor: Color(0xFFffde59),
  ),
  SalomonBottomBarItem(
    icon: const Icon(Icons.savings),
    title: const Text("Savings"),
    selectedColor: Color(0xFFffde59),
  ),
  // SalomonBottomBarItem(
  //   icon: const Icon(Icons.settings),
  //   title: const Text("Settings"),
  //   selectedColor: Color(0xFFffde59),
  // ),
];