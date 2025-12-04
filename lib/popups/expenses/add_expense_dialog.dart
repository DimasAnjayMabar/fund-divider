import 'package:flutter/material.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';

class AddMainExpenseDialog extends StatefulWidget {
  const AddMainExpenseDialog({super.key});

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
    String text = _controller.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      try {
        double value = double.parse(text);
        _controller.value = TextEditingValue(
          text: currencyFormatter.format(value),
          selection: TextSelection.collapsed(offset: _controller.text.length),
        );
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      String rawText = _controller.text.replaceAll('.', '');
      if (rawText.isNotEmpty) {
        try {
          double amount = double.parse(rawText);
          String description = titleController.text;
          
          if (amount <= 0) {
            _showErrorSnackbar('Please enter a valid amount');
            return;
          }
          
          if (amount > WalletService.getBalance()) {
            _showErrorSnackbar('Amount exceeds current balance');
            return;
          }
          
          WalletService.addExpense(description, amount);
          Navigator.of(context).pop();
          
        } catch (e) {
          _showErrorSnackbar('Please enter a valid number');
        }
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setQuickAmount(String amount) {
    String rawAmount = amount.replaceAll('.', '');
    _controller.text = NumberFormat.decimalPattern('id_ID').format(
      double.parse(rawAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Expense",
                    style: TextStyle(
                      color: Color(0xff6F41F2),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                "Enter expense details",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description Input
              const Text(
                "Description",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff6F41F2).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: TextFormField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                    hintText: "Enter description",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Amount Input
              const Text(
                "Amount",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff6F41F2).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xff6F41F2).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Rp",
                          style: TextStyle(
                            color: Color(0xff6F41F2),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an amount";
                          }
                          try {
                            String rawText = value.replaceAll('.', '');
                            double amount = double.parse(rawText);
                            if (amount <= 0) {
                              return "Amount must be greater than 0";
                            }
                            if (amount > WalletService.getBalance()) {
                              return "Amount exceeds current balance";
                            }
                          } catch (e) {
                            return "Please enter a valid number";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Current Balance Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Current Balance:",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Rp ${currencyFormatter.format(WalletService.getBalance())}",
                    style: const TextStyle(
                      color: Color(0xff6F41F2),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Quick Amount Buttons
              const Text(
                "Quick Amount",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAmountButton("10.000"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAmountButton("50.000"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAmountButton("100.000"),
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAmountButton("200.000"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAmountButton("500.000"),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickAmountButton("1.000.000"),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff6F41F2),
                        Color(0xff5A32D6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff6F41F2).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Add Expense",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(
          color: const Color(0xff6F41F2).withOpacity(0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
      ),
      child: Text(
        "Rp$amount",
        style: const TextStyle(
          color: Color(0xff6F41F2),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}