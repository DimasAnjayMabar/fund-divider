import 'package:flutter/material.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/popups/confirmation/confirmation_popup.dart';
import 'package:fund_divider/popups/wallet/add_fund_dialog.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double balance = 0.0;
  String greeting = "";

  bool isHidden = false;

  @override
  void initState() {
    super.initState();
    WalletService.setInitialBalance(0.0);
    balance = WalletService.getBalance();
    greeting = getGreeting();
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening";
    } else {
      return "Good Night";
    }
  }

  String formatRupiah(double value) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // Background utama
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),

              const SizedBox(height: 20),
              _buildWalletCard(),

              const SizedBox(height: 25),
              _buildTopUpButton(),

              const SizedBox(height: 30),
              _buildHistorySection(),

              const SizedBox(height: 20),
              _buildSummary(),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= HEADER =========================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ValueListenableBuilder(
          valueListenable: WalletService.listenToUsername(),
          builder: (context, Box<Username> box, _) {
            String name = box.isNotEmpty ? box.getAt(0)?.name ?? '' : '';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 14)), // Ubah ke hitam
                Text(
                  "Hello $name",
                  style: const TextStyle(
                      color: Colors.black, // Ubah ke hitam
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: Color(0xff6F41F2), size: 26),
        ),
      ],
    );
  }

  // ====================== WALLET CARD =======================

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff6F41F2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Wallet Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder(
                valueListenable: WalletService.listenToBalance(),
                builder: (context, Box<Wallet> box, _) {
                  double bal = box.get('main')?.balance ?? 0.0;
                  return Text(
                    isHidden ? "••••••••" : formatRupiah(bal),
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  );
                },
              ),

              InkWell(
                onTap: () => setState(() => isHidden = !isHidden),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isHidden ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: const [
          //     Icon(Icons.credit_card, color: Colors.orange, size: 32),
          //     SizedBox(width: 8),
          //     Text(
          //       "mastercard",
          //       style: TextStyle(color: Colors.white, fontSize: 12),
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }

  // ========================= TOP UP BUTTON =========================

  Widget _buildTopUpButton() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      shadowColor: const Color(0xff6F41F2).withOpacity(0.4),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AddFundDialog(),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xff6F41F2).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff6F41F2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle_outlined,
                  color: Color(0xff6F41F2),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Top Up Wallet",
                style: TextStyle(
                    color: Color(0xff6F41F2),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================== HISTORY ==========================

  Widget _buildHistorySection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transaction History",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff6F41F2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Recent",
                  style: TextStyle(
                    color: Color(0xff6F41F2),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // EXPENSE LIST
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text("Expenses",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          _buildExpenseList(),

          const SizedBox(height: 20),

          // SAVING LIST
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text("Savings",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          _buildSavingList(),
        ],
      ),
    );
  }

  Widget _buildExpenseList() {
    // Ambil data langsung tanpa ValueListenable
    List<Expenses> recentExpenses = WalletService.getRecentExpenses(limit: 3);
    int totalExpenses = WalletService.getExpensesCount();

    if (totalExpenses == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text("No expense history yet.",
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    return Column(
      children: [
        ...recentExpenses.map((e) => _buildTransactionItem(
              e.id.toString(),
              e.description,
              "Expense",
              formatRupiah(e.amount),
              isExpense: true,
            )),
      ],
    );
  }

  Widget _buildSavingList() {
    // Ambil data langsung tanpa ValueListenable
    List<Savings> recentExpenses = WalletService.getRecentSavings(limit: 3);
    int totalExpenses = WalletService.getSavingsCount();

    if (totalExpenses == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text("No savings history yet.",
              style: TextStyle(color: Colors.black54)),
        ),
      );
    }

    return Column(
      children: [
        ...recentExpenses.map((e) => _buildTransactionItem(
              e.id.toString(),
              e.description,
              "Saving",
              formatRupiah(e.amount),
              isExpense: false,
            )),
      ],
    );
  }

  // ======================== SUMMARY ==========================

  Widget _buildSummary() {
    // Ambil data summary sekali saja
    final summary = WalletService.getExpenseSummary();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
          "Monthly", 
          formatRupiah(summary['monthly'] ?? 0),
          "Spent this month", 
          Icons.calendar_month
        ),
        _buildSummaryCard(
          "Weekly", 
          formatRupiah(summary['weekly'] ?? 0),
          "Spent this week", 
          Icons.weekend,
          isHighlighted: true,
        ),
        _buildSummaryCard(
          "Daily", 
          formatRupiah(summary['daily'] ?? 0),
          "Spent today", 
          Icons.today
        ),
      ],
    );
  }

  // ===================== REUSABLE ITEM ========================

  Widget _buildTransactionItem(
      String id, String title, String type, String amount,
      {required bool isExpense}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isExpense
                      ? Colors.redAccent.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isExpense ? Colors.redAccent : Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(type,
                      style: TextStyle(
                          color: Colors.black54, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(amount,
              style: TextStyle(
                  color: isExpense ? Colors.redAccent : Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ===================== SUMMARY CARD =========================

  Widget _buildSummaryCard(String title, String amount, String subtitle,
      IconData icon, {bool isHighlighted = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xff6F41F2) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isHighlighted ? 0.4 : 0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isHighlighted ? Colors.white : const Color(0xff6F41F2),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(title,
                    style: TextStyle(
                        color: isHighlighted ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            Text(amount,
                style: TextStyle(
                    color: isHighlighted ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: isHighlighted ? Colors.white70 : Colors.black54,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}