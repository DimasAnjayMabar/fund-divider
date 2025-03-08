import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            Container(
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
                  const Text(
                    "\$56,890.00",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                    onPressed: () {},
                    child: const Text("Add More Fund"),
                  ),
                ],
              ),
            ),
           AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter, // 👈 Expands from top to bottom
          child: Container(
            width: double.infinity,
            padding: isExpanded ? const EdgeInsets.all(16) : EdgeInsets.zero,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildExpenseItem("General Expense", "50% of total fund", Colors.green),
                      const SizedBox(height: 10),
                      _buildExpenseItem("Shopping", "25% of total fund", Colors.red),
                      const SizedBox(height: 10,),
                      _buildExpenseItem("Some Expense", "25% of total fund", Colors.red)
                    ],
                  )
                : null, // Hide content when collapsed
          ),
        ),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? "Collapse Fund Divider" : "Expand Fund Divider",
                    style: const TextStyle(color: Colors.yellow),
                  ),
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
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
                  _buildTransactionItem("Salary", "Income", "\$4,000.00"),
                  _buildTransactionItem("Stock Dividends", "Income", "\$1,000.00"),
                  _buildTransactionItem("App Subscriptions", "Outcome", "\$300.00"),
                  _buildTransactionItem("Food & Dining", "Outcome", "\$1,500.00"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryCard("Monthly", "Rp. 1", "Spent this month"),
                _buildSummaryCard("Weekly", "Rp. 1", "Spent this week", isHighlighted: true),
                _buildSummaryCard("Daily", "Rp. 1", "Spent this day"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(String title, String percentage, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),
        Text(percentage, style: TextStyle(color: textColor, fontSize: 14)),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String type, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Text(amount, style: TextStyle(color: isHighlighted ? Colors.black : Colors.yellow, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: isHighlighted ? Colors.black : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
