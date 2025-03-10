import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
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
  }

  void _loadExpense() {
    var expenseBox = Hive.box<Expenses>('expensesBox');
    var expense = expenseBox.get(widget.expenseId);

    if (expense != null) {
      titleController.text = expense.description;
      _controller.text = currencyFormatter.format(expense.amount);
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String rawText = _controller.text.replaceAll('.', '');
      double amount = double.parse(rawText);
      String description = titleController.text;

      var expenseBox = Hive.box<Expenses>('expensesBox');
      var expense = expenseBox.get(widget.expenseId);

      if (expense != null) {
        expense.description = description;
        expense.amount = amount;
        await expenseBox.put(widget.expenseId, expense);
      }

      Navigator.of(context).pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Expense"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
