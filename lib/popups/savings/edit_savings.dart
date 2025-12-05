import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class EditSavings extends StatefulWidget {
  final int savingsId;

  const EditSavings({super.key, required this.savingsId});

  @override
  State<EditSavings> createState() => _EditSavingsState();
}

class _EditSavingsState extends State<EditSavings> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageController = TextEditingController();
  final TextEditingController targetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");
  double currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSaving();
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

  void _loadSaving() {
    try {
      var savingsBox = Hive.box<Savings>('savingsBox');
      var saving = savingsBox.get(widget.savingsId);

      if (saving != null) {
        descriptionController.text = saving.description;
        targetController.text = currencyFormatter.format(saving.target);
        currentBalance = saving.amount;
        
        // Convert 0.20 back to 20 before displaying
        double humanPercentage = saving.percentage * 100;
        percentageController.text = humanPercentage.toString();
      }
    } catch (e) {
      print("Error loading saving: $e");
    }
  }

  Future<void> _showErrorPopup(String message) async {
    await showDialog(
      context: context,
      builder: (context) => ErrorPopup(errorMessage: message),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      String newDescription = descriptionController.text;
      String percentageText = percentageController.text.trim();
      String targetText = targetController.text.replaceAll('.', '');
      
      double? newPercentage = double.tryParse(percentageText);
      double? newTarget = double.tryParse(targetText);

      if (newPercentage == null) {
        await _showErrorPopup("Invalid percentage value");
        return;
      }

      if (newTarget == null) {
        await _showErrorPopup("Invalid target amount");
        return;
      }

      newPercentage /= 100; // Convert to decimal
      
      if (newTarget <= 0) {
        await _showErrorPopup("Target must be greater than 0");
        return;
      }

      try {
        var savingsBox = Hive.box<Savings>('savingsBox');
        var saving = savingsBox.get(widget.savingsId);

        if (saving != null) {
          saving.description = newDescription;
          saving.target = newTarget;
          saving.percentage = newPercentage;
          await savingsBox.put(widget.savingsId, saving);
        }

        Navigator.of(context).pop();
      } catch (e) {
        await _showErrorPopup("Failed to update savings: $e");
      }
    }
  }

  void _deleteSavings() async {
    // Show confirmation popup
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationPopup(
        title: "Delete Savings",
        errorMessage: currentBalance > 0 
          ? "Are you sure you want to delete this savings? All funds (Rp${currencyFormatter.format(currentBalance)}) will be returned to your wallet."
          : "Are you sure you want to delete this savings?",
        onConfirm: () async {
          await _processDeletion();
        },
      ),
    );

    if (confirmDelete == true) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _processDeletion() async {
    try {
      var savingsBox = Hive.box<Savings>('savingsBox');
      var saving = savingsBox.get(widget.savingsId);

      if (saving != null) {
        // Get current amount before deletion
        double amountToReturn = saving.amount;
        
        // Gunakan fungsi deleteSaving dari WalletService 
        // yang sudah menangani pengembalian dana ke wallet
        await WalletService.deleteSaving(saving);
        
        // Show success message
        _showSuccessSnackbar(
          amountToReturn > 0
            ? "Savings deleted successfully. Rp${currencyFormatter.format(amountToReturn)} has been returned to your wallet."
            : "Savings deleted successfully."
        );
      }
    } catch (e) {
      print("Error deleting savings: $e");
      await _showErrorPopup("Failed to delete savings: $e");
    }
  }

  Future<void> _returnFundsToWallet(double amount) async {
    try {
      // HANYA akses box yang sudah terbuka, jangan buka lagi
      var walletBox = Hive.box<Wallet>('walletBox');
      var wallet = walletBox.get('main');
      
      if (wallet != null) {
        // Update balance
        double newBalance = wallet.balance + amount;
        wallet.balance = newBalance;
        await walletBox.put('main', wallet);
      } else {
        // Jika wallet tidak ada, buat yang baru
        var newWallet = Wallet(id: 1, balance: amount);
        await walletBox.put('main', newWallet);
      }
    } catch (e) {
      print("Error returning funds to wallet: $e");
      // Jika masih error, gunakan WalletService
      try {
        // Panggil fungsi yang sudah ada di WalletService
        WalletService.updateBalance(amount);
      } catch (e2) {
        print("WalletService.updateBalance also failed: $e2");
        throw Exception("Failed to return funds to wallet");
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
                        "Edit Savings",
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
                    "Update your savings goal",
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
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showErrorPopup("Please enter a description");
                          });
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
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showErrorPopup("Please enter a percentage");
                                });
                                return null;
                              }
                              try {
                                double percentage = double.parse(value);
                                if (percentage <= 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _showErrorPopup("Percentage must be greater than 0");
                                  });
                                }
                                if (percentage > 100) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _showErrorPopup("Percentage cannot exceed 100%");
                                  });
                                }
                              } catch (e) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showErrorPopup("Please enter a valid number");
                                });
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
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showErrorPopup("Please enter a target amount");
                                });
                                return null;
                              }
                              try {
                                String rawText = value.replaceAll('.', '');
                                double amount = double.parse(rawText);
                                if (amount <= 0) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _showErrorPopup("Target must be greater than 0");
                                  });
                                }
                              } catch (e) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _showErrorPopup("Please enter a valid number");
                                });
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
                  
                  // Button Row (Update and Delete)
                  Column(
                    children: [
                      // Update Button
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
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Update Savings",
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
                      
                      const SizedBox(height: 12),
                      
                      // Delete Button
                      OutlinedButton(
                        onPressed: _deleteSavings,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.red.withOpacity(0.7),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Delete Savings",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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