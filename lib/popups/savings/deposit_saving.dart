import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DepositSaving extends StatefulWidget {
  final int savingId;

  const DepositSaving({Key? key, required this.savingId}) : super(key: key);

  @override
  State<DepositSaving> createState() => _DepositSavingState();
}

class _DepositSavingState extends State<DepositSaving> {
  final TextEditingController depositController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

  @override
  void initState(){
    super.initState();
    depositController.addListener(_formatInput);
  }

  @override
  void dispose(){
    super.dispose();
    depositController.removeListener(_formatInput);
    depositController.dispose();
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

  
  void _formatInput() {
    String text = depositController.text.replaceAll('.', ''); // Remove existing dots
    if (text.isNotEmpty) {
      double value = double.parse(text);
      depositController.value = TextEditingValue(
        text: currencyFormatter.format(value), // Format with thousand separator
        selection: TextSelection.collapsed(offset: depositController.text.length),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      double depositAmount = double.tryParse(depositController.text) ?? 0;
      if (depositAmount > 0) {
        var savingsBox = Hive.box<Savings>('savingsBox');
        Savings? saving = savingsBox.get(widget.savingId);
        if(saving != null){
          saving.amount += depositAmount;
          await savingsBox.put(widget.savingId, saving);
          // Update wallet balance
          WalletService.updateBalance(-depositAmount);
          Navigator.pop(context);
        }
        
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(
        //       "Deposited Rp${NumberFormat.decimalPattern("id_ID").format(depositAmount)} successfully",
        //     ),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      title: const Text("Deposit to Savings", style: TextStyle(color: Colors.yellow)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter deposit amount",
                style: TextStyle(color: Colors.yellow),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: depositController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(),
              validator: (value) =>
                  value == null || value.isEmpty ? "An amount is required" : null,
            ),
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
            _actionButton("Save", Colors.yellow, _submit),
          ],
        )
      ],
    );
  }
}
