import 'package:flutter/material.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/username/username_popup.dart';
import 'package:fund_divider/storage/money_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            /// **Reset Wallet, Savings, and Expenses Buttons**
            _buildActionCard(
              title: "Reset Wallet",
              description: "Resets the wallet balance to 0.",
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
              onTap: () => showDialog(
                  context: context, 
                  builder: (context) => ConfirmationPopup(
                  title: "Reset Wallet",
                  errorMessage: "Are you sure you want to reset the wallet balance?",
                  onConfirm: () async {
                    await WalletService.resetBalance();
                  },
                ),
              )
            ),
            _buildActionCard(
              title: "Reset Savings",
              description: "Deletes all savings data.",
              icon: Icons.savings,
              color: Colors.green,
              onTap: () => showDialog(
                context: context,
                builder: (context) => ConfirmationPopup(
                  title: "Reset Savings", 
                  errorMessage: "Are you sure you want to reset all savings?", 
                  onConfirm: () async {
                    await WalletService.resetSavings();
                  }
                ),
              ),
            ),
            _buildActionCard(
              title: "Reset Expenses",
              description: "Deletes all expense records.",
              icon: Icons.receipt_long,
              color: Colors.red,
              onTap: () => showDialog(
                  context: context, 
                  builder: (context) => ConfirmationPopup(
                  title: "Reset Expenses",
                  errorMessage: "Are you sure you want to reset all expenses?",
                  onConfirm: () async {
                    await WalletService.resetExpenses();
                  },
                ),
              )
            ),
            _buildActionCard(
              title: "Change Username",
              description: "Change username at wallet page",
              icon: Icons.person,
              color: Colors.blue,
              onTap: () async {
                final shouldProceed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmationPopup(
                    title: "Change Username",
                    errorMessage: "Are you sure you want to change your username?",
                    onConfirm: () {}, // Kosongkan karena kita handle di return value
                  ),
                );
                
                if (shouldProceed == true && mounted) {
                  // Show username dialog
                  final result = await showDialog<String>(
                    context: context,
                    builder: (context) => const SaveUsername(isEditMode: true),
                  );
                }
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
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