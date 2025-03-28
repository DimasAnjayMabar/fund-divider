import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/savings/add_savings.dart';
import 'package:fund_divider/popups/savings/deposit_saving.dart';
import 'package:fund_divider/popups/savings/edit_savings.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
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
                valueListenable: Hive.box<Savings>('savingsBox').listenable(),
                builder: (context, Box<Savings> box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text(
                        "No savings available",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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
                            remainingTarget: saving.target == 0 ? "This is the main saving" : "${formatRupiah(remainingTarget)} left to reach target",
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
      floatingActionButton: FloatingActionButton(
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
