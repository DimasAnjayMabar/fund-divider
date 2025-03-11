import 'package:flutter/material.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart'; // Import for formatting

class AddSavings extends StatefulWidget {
  @override
  State<AddSavings> createState() => _AddSavingsState();
}

class _AddSavingsState extends State<AddSavings> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");
  final TextEditingController _percentageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(_formatInput);
    _percentageController.addListener(_formatPercentage);
  }

  @override
  void dispose() {
    _controller.removeListener(_formatInput);
    _controller.dispose();
    _percentageController.removeListener(_formatPercentage);
    _percentageController.dispose();
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

  // Format percentage input (e.g., "25%" but store as 0.25)
  void _formatPercentage() {
    String text = _percentageController.text.replaceAll('%', '').trim();
    if (text.isNotEmpty) {
      double value = double.tryParse(text) ?? 0;
      _percentageController.value = TextEditingValue(
        text: "$value%", // Display as "xx%"
        selection: TextSelection.collapsed(offset: _percentageController.text.length),
      );
    }
  }

  // to modify here : submit uses addSaving function from wallet service
  void _submit() async{
    String target = _controller.text.replaceAll('.', ''); // Remove formatting
    String percentageText = _percentageController.text.replaceAll('%', '').trim();
    double percentage = double.parse(percentageText) / 100; // Convert to decimal
    String description = titleController.text;
    if (target.isNotEmpty && percentage != 0.0 && description.isNotEmpty) {
      await WalletService.addSaving(description, percentage, 0, double.parse(target));
      Navigator.of(context).pop(); // Close dialog
    }
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
        "Add Savings",
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

            // to modify here : make a percentage converter from double to percent but still saved as double inside hive
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Percentage",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: _percentageController,
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
                  value == null || value.isEmpty ? "Percentage is required" : null,
            ),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Target",
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
                  value == null || value.isEmpty ? "Target is required" : null,
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
