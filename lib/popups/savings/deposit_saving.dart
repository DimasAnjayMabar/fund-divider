import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DepositSaving extends StatefulWidget {
  final int savingId;

  const DepositSaving({super.key, required this.savingId});

  @override
  State<DepositSaving> createState() => _DepositSavingState();
}

class _DepositSavingState extends State<DepositSaving> {
  final TextEditingController depositController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

  @override
  void initState() {
    super.initState();
    depositController.addListener(_formatInput);
  }

  @override
  void dispose() {
    super.dispose();
    depositController.removeListener(_formatInput);
    depositController.dispose();
  }

  void _formatInput() {
    String text = depositController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      try {
        double value = double.parse(text);
        depositController.value = TextEditingValue(
          text: currencyFormatter.format(value),
          selection: TextSelection.collapsed(offset: depositController.text.length),
        );
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  void _setQuickAmount(String amount) {
    String rawAmount = amount.replaceAll('.', '');
    depositController.text = NumberFormat.decimalPattern('id_ID').format(
      double.parse(rawAmount),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String rawInput = depositController.text.replaceAll('.', '').replaceAll(',', '');
      double depositAmount = double.tryParse(rawInput) ?? 0;

      if (depositAmount > 0) {
        double currentBalance = WalletService.getBalance();

        // Check if the balance is sufficient
        if (currentBalance >= depositAmount) {
          var savingsBox = Hive.box<Savings>('savingsBox');
          Savings? saving = savingsBox.get(widget.savingId);
          if (saving != null) {
            saving.amount += depositAmount;
            await savingsBox.put(widget.savingId, saving);
            // Update wallet balance
            WalletService.updateBalance(-depositAmount);
            Navigator.pop(context);
          }
        } else {
          // Show error popup if balance is insufficient
          showDialog(
            context: context,
            builder: (context) => ErrorPopup(
              errorMessage: "Insufficient balance. Your current balance is Rp ${currencyFormatter.format(currentBalance)}.",
            ),
          );
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                        "Deposit to Savings",
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
                    "Add money to your savings goal",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Deposit Amount Input
                  const Text(
                    "Deposit Amount",
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
                            controller: depositController,
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
                              hintText: "100.000",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a deposit amount";
                              }
                              try {
                                String rawText = value.replaceAll('.', '');
                                double amount = double.parse(rawText);
                                if (amount <= 0) {
                                  return "Amount must be greater than 0";
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
                  
                  const SizedBox(height: 12),
                  
                  // Current Balance Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff6F41F2).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xff6F41F2).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available Balance:",
                          style: TextStyle(
                            color: Color(0xff6F41F2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Rp ${currencyFormatter.format(WalletService.getBalance())}",
                          style: const TextStyle(
                            color: Color(0xff6F41F2),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Quick Amount Buttons
                  const Text(
                    "Quick Deposit Amount",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAmountButton("50.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("100.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("250.000"),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAmountButton("500.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("750.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("1.000.000"),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Deposit Button
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
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Deposit",
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
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String amount) {
    return OutlinedButton(
      onPressed: () => _setQuickAmount(amount),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(
          color: const Color(0xff6F41F2).withOpacity(0.3),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.white,
      ),
      child: Text(
        "Rp$amount",
        style: const TextStyle(
          color: Color(0xff6F41F2),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}