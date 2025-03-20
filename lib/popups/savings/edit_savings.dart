import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class EditSavings extends StatefulWidget {
  final int savingsId; // Accept expense ID

  const EditSavings({Key? key, required this.savingsId}) : super(key: key);

  @override
  State<EditSavings> createState() => _EditSavingsState();
}

class _EditSavingsState extends State<EditSavings> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

  @override
  void initState() {
    super.initState();
    _loadSaving();
    targetController.addListener(_formatInput);
  }

  @override
  void dispose(){
    targetController.removeListener(_formatInput);
    targetController.dispose();
    percentageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _loadSaving() {
    var savingsBox = Hive.box<Savings>('savingsBox');
    var saving = savingsBox.get(widget.savingsId);

    if (saving != null) {
      descriptionController.text = saving.description;
      targetController.text = currencyFormatter.format(saving.target);
      
      // Correctly convert the percentage back to its original form
      double percentage = saving.percentage * 100;
      percentageController.text = "$percentage%";
    }
  }

  void _formatInput() {
    String text = targetController.text.replaceAll('.', ''); // Remove existing dots
    if (text.isNotEmpty) {
      double value = double.parse(text);
      targetController.value = TextEditingValue(
        text: currencyFormatter.format(value), // Format with thousand separator
        selection: TextSelection.collapsed(offset: targetController.text.length),
      );
    }
  }

  void _onPercentageChanged(String value){
    String clean = value.replaceAll('%', '').trim();
    if(clean.isEmpty){
      percentageController.text = '';
      return;
    }
    double num = double.tryParse(clean) ?? 0;
    String newText = "$num%";
    if(percentageController.text != newText){
      percentageController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - 1)
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String rawTarget = targetController.text.replaceAll('.', '');
      String rawPercentage = percentageController.text.replaceAll('%', '');
      double newTarget = double.parse(rawTarget);
      String newDescription = descriptionController.text;
      double newPercentage = double.parse(rawPercentage);

      var savingsBox = Hive.box<Savings>('savingsBox');
      var saving = savingsBox.get(widget.savingsId);

      if (saving != null) {
        // Update expense fields
        saving.description = newDescription;
        saving.target = newTarget;
        saving.percentage = newPercentage / 100;
        await savingsBox.put(widget.savingsId, saving);
      }

      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Edit Expense", 
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1)
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              validator: (value) => value == null || value.isEmpty ? "Description is required" : null,
            ),
            const SizedBox(height: 10,),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Percentage", 
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: percentageController,
              onChanged: _onPercentageChanged,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(),
              validator: (value) => value == null || value.isEmpty ? "Percentage is required" : null,
            ),
            const SizedBox(height: 10,),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Target", 
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: targetController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(),
              validator: (value) => value == null || value.isEmpty ? "Target is required" : null,
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionButton("Cancel", Colors.yellow, () {Navigator.of(context).pop();}),
            const SizedBox(width: 10,),
            _actionButton("Save", Colors.yellow, _submit)
          ],
        )
      ],
    );
  }

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
