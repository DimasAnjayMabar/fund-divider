import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:hive/hive.dart';

class EditSavings extends StatefulWidget {
  final int savingsId;

  const EditSavings({Key? key, required this.savingsId}) : super(key: key);

  @override
  State<EditSavings> createState() => _EditSavingsState();
}

class _EditSavingsState extends State<EditSavings> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSaving();
  }

  @override
  void dispose() {
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
      targetController.text = saving.target.toString();

      // Convert 0.20 back to 20 before displaying
      double humanPercentage = saving.percentage * 100;
      percentageController.text = humanPercentage.toString();
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      double newTarget = double.parse(targetController.text);
      String newDescription = descriptionController.text;
      double newPercentage = double.parse(percentageController.text) / 100; // Convert 20 back to 0.20

      var savingsBox = Hive.box<Savings>('savingsBox');
      var saving = savingsBox.get(widget.savingsId);

      if (saving != null) {
        saving.description = newDescription;
        saving.target = newTarget;
        saving.percentage = newPercentage;
        await savingsBox.put(widget.savingsId, saving);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Edit Savings",
        style: TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField("Description", descriptionController),
            const SizedBox(height: 10),
            _buildPercentageField(),
            const SizedBox(height: 10),
            _buildTextField("Target", targetController, isNumeric: true),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionButton("Cancel", Colors.yellow, () {
              Navigator.of(context).pop();
            }),
            const SizedBox(width: 10),
            _actionButton("Save", Colors.yellow, _submit)
          ],
        )
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.yellow),
        ),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
          validator: (value) =>
              value == null || value.isEmpty ? "$label is required" : null,
        ),
      ],
    );
  }

  Widget _buildPercentageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Percentage",
          style: TextStyle(color: Colors.yellow),
        ),
        TextFormField(
          controller: percentageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration().copyWith(
            suffixIcon: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                "%",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? "Percentage is required" : null,
        ),
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
