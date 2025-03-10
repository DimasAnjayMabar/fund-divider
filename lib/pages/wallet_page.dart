import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
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

  @override
  void initState() {
    super.initState();
    WalletService.setInitialBalance(0.0);
    balance = WalletService.getBalance();
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  double _getTotalExpenseForPeriod(Duration period) {
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(period);
    return WalletService.getHistory()
        .where((history) => history.expense != null && history.dateAdded.isAfter(startDate))
        .map((history) => history.expense!.amount)
        .fold(0.0, (sum, amount) => sum + amount);
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
            const Text(
              "Morning, Greg!",
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
                  ValueListenableBuilder(
                    valueListenable: WalletService.listenToHistory(),
                    builder: (context, Box<History> box, _) {
                      List<History> historyList = box.values.toList().reversed.toList();

                      if (historyList.isEmpty) {
                        return const Text(
                          "No transaction history yet.",
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
                            itemCount: historyList.length,
                            itemBuilder: (context, index) {
                              final history = historyList[index];
                              bool isSaving = history.saving != null;
                              String title = isSaving ? history.saving!.description : history.expense!.description;
                              String type = isSaving ? "Saving" : "Expense";
                              double amount = isSaving ? history.saving!.amount : history.expense!.amount;

                              return Dismissible(
                                key: Key(history.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.red,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  WalletService.deleteExpenseFromHistory(history);
                                },
                                child: _buildTransactionItem(history.id.toString(), title, type, formatRupiah(amount)),
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
              valueListenable: WalletService.listenToHistory(),
              builder: (context, Box<History> box, _) {
                List<History> historyList = box.values.toList();

                double totalMonthly = _getTotalExpenseForPeriod(const Duration(days: 30));
                double totalWeekly = _getTotalExpenseForPeriod(const Duration(days: 7));
                double totalDaily = _getTotalExpenseForPeriod(const Duration(days: 1));

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
