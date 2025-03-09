import 'package:flutter/material.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart'; // Import for formatting

class AddMainExpenseDialog extends StatefulWidget {
  @override
  State<AddMainExpenseDialog> createState() => _AddMainExpenseDialogState();
}

class _AddMainExpenseDialogState extends State<AddMainExpenseDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_formatInput);
    _controller.dispose();
    titleController.dispose();
    super.dispose();
  }

  void _formatInput() {
    String text = _controller.text.replaceAll('.', ''); // Remove existing dots
    if (text.isNotEmpty) {
      double value = double.parse(text);
      _controller.value = TextEditingValue(
        text: currencyFormatter.format(value), // Format with thousand separator
        selection: TextSelection.collapsed(offset: _controller.text.length),
      );
    }
  }

  void _submit() async{
    String rawText = _controller.text.replaceAll('.', ''); // Remove formatting
    if (rawText.isNotEmpty) {
      String description = titleController.text;
      double amount = double.parse(rawText);
      await WalletService.addExpense(description, amount);
      Navigator.of(context).pop(); // Close dialog
    }
  }

  /// 🔹 Show Error Alert
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1)
      ),
      title: const Text(
        "Add Expense",
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Description",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
              validator: (value) =>
                  value == null || value.isEmpty ? "Description is required" : null,
            ),
            const SizedBox(height: 10),

            // Amount Field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amount",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Title is required" : null,
            ),
            // Current Balance Display
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Balance:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "Rp ${currencyFormatter.format(WalletService.getBalance())}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cancel Button
            _actionButton("Cancel", Colors.yellow, () {
              Navigator.of(context).pop();
            }),

            const SizedBox(width: 10),

            // Save Button
            _actionButton("Save", Colors.yellow, _submit),
          ],
        ),
      ],
    );
  }

  /// 🔹 Input Decoration for Text Fields
  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[900],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.yellow),
      ),
    );
  }

  /// 🔹 Custom Action Button
  Widget _actionButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}
