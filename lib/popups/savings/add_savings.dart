import 'package:flutter/material.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart'; // Import for formatting

class AddSavings extends StatefulWidget {
  const AddSavings({super.key});

  @override
  State<AddSavings> createState() => _AddSavingsState();
}

class _AddSavingsState extends State<AddSavings> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");
  final TextEditingController percentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    targetController.addListener(_formatInput);
  }

  @override
  void dispose() {
    targetController.removeListener(_formatInput);
    targetController.dispose();
    // percentageController.removeListener(_formatPercentage);
    percentageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _formatInput() {
    String text =
        targetController.text.replaceAll('.', ''); // Remove existing dots
    if (text.isNotEmpty) {
      double value = double.parse(text);
      targetController.value = TextEditingValue(
        text: currencyFormatter.format(value), // Format with thousand separator
        selection:
            TextSelection.collapsed(offset: targetController.text.length),
      );
    }
  }

  // // Format percentage input (e.g., "25%" but store as 0.25)
  // void _formatPercentage() {
  //   String text = percentageController.text.replaceAll('%', '').trim();
  //   if (text.isNotEmpty) {
  //     double value = double.tryParse(text) ?? 0;
  //     percentageController.text = "$value%";
  //     percentageController.selection = TextSelection.collapsed(offset: percentageController.text.length);
  //   }
  // }

  // void _onPercentageChanged(String value){
  //   String clean = value.replaceAll('%', '').trim();
  //   if(clean.isNotEmpty && !value.endsWith('%')){
  //     double num = double.tryParse(clean) ?? 0;
  //     String newText = "$num%";
  //     percentageController.value = TextEditingValue(
  //       text: newText,
  //       selection: TextSelection.collapsed(offset: newText.length - 1)
  //     );
  //   }
  // }

  // to modify here : submit uses addSaving function from wallet service
  void _submit() async {
    if (!_formKey.currentState!.validate()) return; // Ensure form is valid

    String target = targetController.text.replaceAll('.', ''); // Remove formatting
    String percentageText = percentageController.text.trim();
    double? percentage = double.tryParse(percentageText);

    if (percentage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid percentage value")),
      );
      return;
    }

    percentage /= 100; // Convert to decimal
    String description = descriptionController.text;

    if (target.isNotEmpty && percentage > 0.0 && description.isNotEmpty) {
      await WalletService.addSaving(description, percentage, 0, double.tryParse(target)!);
      Navigator.of(context).pop(); // Close dialog
    }else{
      await WalletService.addSaving(description, percentage, 0, 0);
      Navigator.of(context).pop(); // Close dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1)),
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
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
              validator: (value) => value == null || value.isEmpty
                  ? "Description is required"
                  : null,
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
              controller: percentageController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                suffixText: '%', 
                suffixStyle: const TextStyle(color: Colors.white),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Percentage is required";
                double? parsedValue = double.tryParse(value);
                if (parsedValue == null || parsedValue <= 0 || parsedValue > 100) {
                  return "Enter a valid percentage (1-100)";
                }
                return null;
              },
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Target",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: targetController,
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
