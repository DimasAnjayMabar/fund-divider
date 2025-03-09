import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/add_fund_dialog.dart';
import 'package:fund_divider/popups/add_main_expense_dialog.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    // No need to open the box here as WalletService already handles it
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Expenses>('expensesBox').listenable(),
                builder: (context, Box<Expenses> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text(
                        "No expenses available",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  final expenses = box.values.toList();
                  
                  return ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return _buildExpenseCard(
                        title: expense.description,
                        amount: formatRupiah(expense.amount),
                        color: Colors.red,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddMainExpenseDialog();
            },
          );
        },
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpenseCard({required String title, required String amount, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(amount, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// // Dialog to add an expense
// class AddExpenseDialog extends StatefulWidget {
//   @override
//   _AddExpenseDialogState createState() => _AddExpenseDialogState();
// }

// class _AddExpenseDialogState extends State<AddExpenseDialog> {
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: Colors.grey[900],
//       title: const Text('Add Expense', style: TextStyle(color: Colors.white)),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: descriptionController,
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               hintText: 'Description',
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey[700]!),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             controller: amountController,
//             style: const TextStyle(color: Colors.white),
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: 'Amount',
//               hintStyle: TextStyle(color: Colors.grey[500]),
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey[700]!),
//               ),
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
//         ),
//         TextButton(
//           onPressed: () {
//             try {
//               final amount = double.parse(amountController.text);
//               WalletService.addExpense(
//                 descriptionController.text, 
//                 amount
//               );
//               Navigator.pop(context);
//             } catch (e) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Please enter a valid amount'))
//               );
//             }
//           },
//           child: const Text('Add', style: TextStyle(color: Colors.blue)),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     descriptionController.dispose();
//     amountController.dispose();
//     super.dispose();
//   }
// }
