// [file name]: scan_transaction.dart (UPDATE)
import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/pages/receipt_scanner.dart';
import 'package:fund_divider/popups/savings/add_savings.dart';
import 'package:fund_divider/popups/savings/deposit_saving.dart';
import 'package:fund_divider/popups/savings/edit_savings.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScanTransaction extends StatefulWidget {
  const ScanTransaction({super.key});

  @override
  State<ScanTransaction> createState() => _ScanTransactionState();
}

class _ScanTransactionState extends State<ScanTransaction> {
  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(value);
  }

  void _navigateToReceiptScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReceiptScanner(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Savings & Receipt Scanner'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => _navigateToReceiptScanner(context),
            tooltip: 'Scan Receipt',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Receipt Scanner Quick Button
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Card(
                color: Colors.blue[800],
                child: ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    'Scan Receipt',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Capture receipt to automatically add expense',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () => _navigateToReceiptScanner(context),
                ),
              ),
            ),
            
            const Text(
              'Your Savings',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                builder: (context, Box<Savings> box, _) {
                  if (box.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_balance_wallet, color: Colors.grey, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          "No savings available",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _navigateToReceiptScanner(context),
                          child: const Text(
                            'Try scanning a receipt instead',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    );
                  }

                  final savings = box.values.toList();

                  return ListView.builder(
                    itemCount: savings.length,
                    itemBuilder: (context, index) {
                      final saving = savings[index];
                      double remainingTarget = saving.target - saving.amount;
                      bool isMainSaving = saving.target == 0;

                      return Dismissible(
                        key: Key(saving.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.green,
                          child: const Icon(Icons.account_balance_wallet,
                              color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DepositSaving(savingId: saving.id);
                                });
                            return false;
                          }
                          return false;
                        },
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditSavings(savingsId: saving.id);
                              },
                            );
                          },
                          child: _buildSavingCard(
                            title: saving.description,
                            amount: formatRupiah(saving.amount),
                            color: Colors.red,
                            remainingTarget: saving.target == 0 
                                ? "This is the main saving" 
                                : "${formatRupiah(remainingTarget)} left to reach target",
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan_receipt',
            onPressed: () => _navigateToReceiptScanner(context),
            backgroundColor: Colors.blue,
            mini: true,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add_saving',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddSavings();
                },
              );
            },
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard({
    required String title,
    required String amount,
    required Color color,
    String? remainingTarget,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                amount,
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (remainingTarget != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                remainingTarget,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}