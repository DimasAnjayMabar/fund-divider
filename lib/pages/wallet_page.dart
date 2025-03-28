import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/wallet/add_fund_dialog.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double balance = 0.0;
  String greeting = "";

  @override
  void initState() {
    super.initState();
    WalletService.setInitialBalance(0.0);
    balance = WalletService.getBalance();
    greeting = getGreeting();
  }

  String getGreeting(){
    int hour = DateTime.now().hour;
    if(hour >= 5 && hour < 12){
      return "Morning";
    } else if (hour >= 12 && hour < 17){
      return "Afternoon";
    } else if (hour >= 17 && hour < 21){
      return "Evening";
    } else {
      return "Night";
    }
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  String formatPercentage(double value) {
    return "${(value * 100).toStringAsFixed(0)}%";
  }

  Color getPercentageColor(double value) {
    if (value < 0.5) {
      return Colors.green;
    } else if (value == 0.5) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              "$greeting, Greg!",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Wallet Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.yellow),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Active Balance",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder(
                    valueListenable: WalletService.listenToBalance(),
                    builder: (context, Box<Wallet> box, _) {
                      double balance = box.get('main')?.balance ?? 0.0;
                      return Text(
                        formatRupiah(balance),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddFundDialog();
                        },
                      );
                    },
                    child: const Text("Add More Fund"),
                  ),
                ],
              ),
            ),

            // History Section
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "History",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Expense",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  ValueListenableBuilder(
                    valueListenable: WalletService.listenToExpenses(),
                    builder: (context, Box<Expenses> box, _) {
                      List<Expenses> expensesList = box.values.toList().reversed.toList();

                      if (expensesList.isEmpty) {
                        return const Text(
                          "No expense history yet.",
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      return SizedBox(
                        height: 250,
                        child: Scrollbar(
                          thickness: 3,
                          radius: const Radius.circular(8),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: expensesList.length,
                            itemBuilder: (context, index) {
                              final expense = expensesList[index]; // Change variable name to `expense`

                              // Extract data from the Expenses object
                              String title = expense.description;
                              double amount = expense.amount;

                              return Dismissible(
                                key: Key(expense.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if(direction == DismissDirection.endToStart){
                                    showDialog(
                                      context: context,
                                      builder: (context) => ConfirmationPopup(
                                        title: "Delete Expense",
                                        errorMessage: "Are you sure you want to delete this expense? (this amount of expense will going back to the wallet)",
                                        onConfirm: () {
                                          WalletService.deleteExpense(expense);
                                        },
                                      ),
                                    );
                                    return false;
                                  }else{
                                    return false;
                                  }
                                },
                                child: _buildTransactionItem(
                                  expense.id.toString(),
                                  title,
                                  "Expense", // Since it's always an expense
                                  formatRupiah(amount),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Savings",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  ValueListenableBuilder(
                    valueListenable: WalletService.listenToSavings(),
                    builder: (context, Box<Savings> box, _) {
                      List<Savings> savingsList = box.values.toList().reversed.toList();

                      if (savingsList.isEmpty) {
                        return const Text(
                          "No savings history yet.",
                          style: TextStyle(color: Colors.white),
                        );
                      }

                      return SizedBox(
                        height: 250,
                        child: Scrollbar(
                          thickness: 3,
                          radius: const Radius.circular(8),
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: savingsList.length,
                            itemBuilder: (context, index) {
                              final saving = savingsList[index];
                              String title = saving.description;
                              String type = "Saving";
                              double percentage = saving.percentage;

                              return Dismissible(
                                key: Key(saving.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  if(direction == DismissDirection.endToStart){
                                    showDialog(
                                      context: context,
                                      builder: (context) => ConfirmationPopup(
                                        title: "Delete Saving",
                                        errorMessage: "Are you sure you want to delete this saving? (all the money deposited is going back to the wallet)",
                                        onConfirm: () {
                                          WalletService.deleteSaving(saving); // Function to be executed
                                        },
                                      ),
                                    );
                                    return false;
                                  }else{
                                    return false;
                                  }
                                },
                                child: _buildTransactionItem(saving.id.toString(), title, type, formatPercentage(percentage)),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Cards
            ValueListenableBuilder(
              valueListenable: WalletService.listenToExpenses(),
              builder: (context, Box<Expenses> box, _) {

                double totalMonthly = WalletService.getTotalExpenseForPeriod(const Duration(days: 30));
                double totalWeekly = WalletService.getTotalExpenseForPeriod(const Duration(days: 7));
                double totalDaily = WalletService.getTotalExpenseForPeriod(const Duration(days: 1));

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard("Monthly", formatRupiah(totalMonthly), "Spent this month"),
                    _buildSummaryCard("Weekly", formatRupiah(totalWeekly), "Spent this week", isHighlighted: true),
                    _buildSummaryCard("Daily", formatRupiah(totalDaily), "Spent this day"),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String id, String title, String type, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(type, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          Text(amount,
              style: TextStyle(
                color: type == "Saving" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, String subtitle, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.yellow : Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(amount,
                style: TextStyle(
                    color: isHighlighted ? Colors.black : Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: isHighlighted ? Colors.black : Colors.grey,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
