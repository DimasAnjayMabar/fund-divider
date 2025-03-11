import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class EditExpenses extends StatefulWidget {
  final int expenseId; // Accept expense ID

  const EditExpenses({Key? key, required this.expenseId}) : super(key: key);

  @override
  State<EditExpenses> createState() => _EditExpensesState();
}

class _EditExpensesState extends State<EditExpenses> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

  @override
  void initState() {
    super.initState();
    _loadExpense();
    _controller.addListener(_formatInput);
  }

  void _loadExpense() {
    var expenseBox = Hive.box<Expenses>('expensesBox');
    var expense = expenseBox.get(widget.expenseId);

    if (expense != null) {
      titleController.text = expense.description;
      _controller.text = currencyFormatter.format(expense.amount);
    }
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String rawText = _controller.text.replaceAll('.', '');
      double newAmount = double.parse(rawText);
      String newDescription = titleController.text;

      var expenseBox = Hive.box<Expenses>('expensesBox');
      var expense = expenseBox.get(widget.expenseId);

      if (expense != null) {
        double oldAmount = expense.amount;
        double difference = newAmount - oldAmount;

        // Update expense fields
        expense.description = newDescription;
        expense.amount = newAmount;
        await expenseBox.put(widget.expenseId, expense);

        // Adjust the balance
        WalletService.updateBalance(-difference);
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
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(),
              validator: (value) => value == null || value.isEmpty ? "Description is required" : null,
            ),
            const SizedBox(height: 10,),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amount", 
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            TextFormField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(),
              validator: (value) => value == null || value.isEmpty ? "Description is required" : null,
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
