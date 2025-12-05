import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';

class AddSavings extends StatefulWidget {
  const AddSavings({super.key});

  @override
  State<AddSavings> createState() => _AddSavingsState();
}

class _AddSavingsState extends State<AddSavings> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

  @override
  void initState() {
    super.initState();
    targetController.addListener(_formatInput);
  }

  @override
  void dispose() {
    targetController.removeListener(_formatInput);
    targetController.dispose();
    percentageController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _formatInput() {
    String text = targetController.text.replaceAll('.', '');
    if (text.isNotEmpty) {
      try {
        double value = double.parse(text);
        targetController.value = TextEditingValue(
          text: currencyFormatter.format(value),
          selection: TextSelection.collapsed(offset: targetController.text.length),
        );
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  // Fungsi untuk mengecek total persentase savings
  Future<bool> _checkTotalPercentage(double newPercentage) async {
    try {
      // Get total current percentage
      double currentTotalPercentage = WalletService.getTotalSavingsPercentage();
      
      // Add new percentage
      double totalPercentage = currentTotalPercentage + newPercentage;
      
      // Convert to percentage (from decimal: 0.1 -> 10%)
      double totalPercentagePercent = totalPercentage * 100;
      
      // Check if total exceeds 75%
      return totalPercentagePercent <= 75.0;
    } catch (e) {
      // If there's an error, continue anyway (fallback)
      debugPrint("Error checking total percentage: $e");
      return true;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String description = descriptionController.text;
      String percentageText = percentageController.text.trim();
      String targetText = targetController.text.replaceAll('.', '');
      
      double? percentage = double.tryParse(percentageText);
      double? target = double.tryParse(targetText);

      if (percentage == null) {
        _showErrorSnackbar("Invalid percentage value");
        return;
      }

      if (target == null) {
        _showErrorSnackbar("Invalid target amount");
        return;
      }

      percentage /= 100; // Convert to decimal
      
      if (target <= 0) {
        _showErrorSnackbar("Target must be greater than 0");
        return;
      }
      
      // Cek total persentase tidak melebihi 75%
      bool isPercentageValid = await _checkTotalPercentage(percentage);
      if (!isPercentageValid) {
        // Tampilkan error popup jika total persentase > 75%
        _showPercentageErrorPopup(context);
        return;
      }
      
      try {
        await WalletService.addSaving(description, percentage, 0, target);
        Navigator.of(context).pop();
      } catch (e) {
        _showErrorSnackbar("Failed to create savings: $e");
      }
    }
  }

  // Fungsi untuk menampilkan error popup ketika total persentase > 75%
  void _showPercentageErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ErrorPopup(
        errorMessage: "Total percentage of all savings cannot exceed 75%. "
                     "Please adjust your savings percentage to stay within the limit.",
      ),
    );
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
    targetController.text = NumberFormat.decimalPattern('id_ID').format(
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                        "Create Savings",
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
                    "Set up your savings goal",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  
                  // Tambah informasi batas persentase
                  const SizedBox(height: 4),
                  
                  Text(
                    "Total percentage of all savings cannot exceed 75%",
                    style: TextStyle(
                      color: const Color(0xff6F41F2).withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
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
                      controller: descriptionController,
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
                        hintText: "e.g., Vacation Fund, Emergency Fund",
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
                  
                  // Percentage Input
                  const Text(
                    "Savings Percentage",
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
                              "%",
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
                            controller: percentageController,
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
                              hintText: "10",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a percentage";
                              }
                              try {
                                double percentage = double.parse(value);
                                if (percentage <= 0) {
                                  return "Percentage must be greater than 0";
                                }
                                if (percentage > 100) {
                                  return "Percentage cannot exceed 100%";
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
                  
                  Text(
                    "This percentage will be automatically saved from your income",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Target Amount Input
                  const Text(
                    "Target Amount",
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
                            controller: targetController,
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
                              hintText: "1.000.000",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a target amount";
                              }
                              try {
                                String rawText = value.replaceAll('.', '');
                                double amount = double.parse(rawText);
                                if (amount <= 0) {
                                  return "Target must be greater than 0";
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
                  
                  // Quick Amount Buttons for Target
                  const Text(
                    "Quick Target Amount",
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
                        child: _buildQuickAmountButton("500.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("1.000.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("5.000.000"),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAmountButton("10.000.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("25.000.000"),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickAmountButton("50.000.000"),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create Button
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
                              Icons.savings_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Create Savings",
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