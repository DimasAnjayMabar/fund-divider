// import 'package:flutter/material.dart';
// import 'package:fund_divider/model/hive.dart';
// import 'package:fund_divider/popups/add_fund_dialog.dart';
// import 'package:fund_divider/storage/money_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class WalletPage extends StatefulWidget {
//   const WalletPage({Key? key}) : super(key: key);

//   @override
//   State<WalletPage> createState() => _WalletPageState();
// }

// class _WalletPageState extends State<WalletPage> {
//   double balance = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     WalletService.setInitialBalance(0.0);
//     balance = WalletService.getBalance();
//   }

//   String formatRupiah(double value) {
//     return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
//   }

//   double _getTotalExpenseForPeriod(Duration period) {
//     DateTime now = DateTime.now();
//     DateTime startDate = now.subtract(period);

//     // Retrieve history linked to existing expenses
//     List<History> historyList = WalletService.getHistoryFromExpenses();

//     // Sum only the expenses within the period
//     double totalExpense = historyList
//         .where((history) => history.dateAdded.isAfter(startDate))
//         .fold(0.0, (sum, history) => sum + (history.expense?.amount ?? 0.0));

//     return totalExpense;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 40),
//             const Text(
//               "Morning, Greg!",
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 20),

//             // Wallet Container
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.yellow),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Active Balance",
//                     style: TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                   const SizedBox(height: 8),
//                   ValueListenableBuilder(
//                     valueListenable: WalletService.listenToBalance(),
//                     builder: (context, Box<Wallet> box, _) {
//                       double balance = box.get('main')?.balance ?? 0.0;
//                       return Text(
//                         formatRupiah(balance),
//                         style: const TextStyle(
//                           color: Colors.yellow,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.yellow,
//                       foregroundColor: Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AddFundDialog();
//                         },
//                       );
//                     },
//                     child: const Text("Add More Fund"),
//                   ),
//                 ],
//               ),
//             ),

//             // History Section
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[850],
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "History",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "Expenses",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   ValueListenableBuilder(
//                     valueListenable: Hive.box<Expenses>('expensesBox').listenable(),
//                     builder: (context, Box<Expenses> expenseBox, _) {
//                       // Convert expenses to history representation
//                       List<History> historyList = expenseBox.values.map((expense) {
//                         return History(
//                           id: expense.id,
//                           expense: expense,
//                           dateAdded: DateTime.now(), // Adjust to actual stored date
//                         );
//                       }).toList();

//                       if (historyList.isEmpty) {
//                         return const Text(
//                           "No expense history yet.",
//                           style: TextStyle(color: Colors.white),
//                         );
//                       }

//                       return SizedBox(
//                         height: 250,
//                         child: Scrollbar(
//                           thickness: 3,
//                           radius: const Radius.circular(8),
//                           child: ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             padding: EdgeInsets.zero,
//                             itemCount: historyList.length,
//                             itemBuilder: (context, index) {
//                               final history = historyList[index];
//                               String title = history.expense!.description;
//                               double amount = history.expense!.amount;

//                               return _buildTransactionItem(
//                                 history.id.toString(), title, "Expense", formatRupiah(amount),
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "Savings",
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   ValueListenableBuilder(
//                     valueListenable: Hive.box<Expenses>('expensesBox').listenable(),
//                     builder: (context, Box<Expenses> expenseBox, _) {
//                       // Convert expenses to history representation
//                       List<History> historyList = expenseBox.values.map((expense) {
//                         return History(
//                           id: expense.id,
//                           expense: expense,
//                           dateAdded: DateTime.now(), // Adjust to actual stored date
//                         );
//                       }).toList();

//                       if (historyList.isEmpty) {
//                         return const Text(
//                           "No saving history yet.",
//                           style: TextStyle(color: Colors.white),
//                         );
//                       }

//                       return SizedBox(
//                         height: 250,
//                         child: Scrollbar(
//                           thickness: 3,
//                           radius: const Radius.circular(8),
//                           child: ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             padding: EdgeInsets.zero,
//                             itemCount: historyList.length,
//                             itemBuilder: (context, index) {
//                               final history = historyList[index];
//                               String title = history.expense!.description;
//                               double amount = history.expense!.amount;

//                               return _buildTransactionItem(
//                                 history.id.toString(), title, "Expense", formatRupiah(amount),
//                               );
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Summary Cards
//             ValueListenableBuilder(
//               valueListenable: WalletService.listenToHistory(),
//               builder: (context, Box<History> box, _) {

//                 double totalMonthly = _getTotalExpenseForPeriod(const Duration(days: 30));
//                 double totalWeekly = _getTotalExpenseForPeriod(const Duration(days: 7));
//                 double totalDaily = _getTotalExpenseForPeriod(const Duration(days: 1));

//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildSummaryCard("Monthly", formatRupiah(totalMonthly), "Spent this month"),
//                     _buildSummaryCard("Weekly", formatRupiah(totalWeekly), "Spent this week", isHighlighted: true),
//                     _buildSummaryCard("Daily", formatRupiah(totalDaily), "Spent this day"),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransactionItem(String id, String title, String type, String amount) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
//               Text(type, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
//             ],
//           ),
//           Text(amount,
//               style: TextStyle(
//                 color: type == "Saving" ? Colors.green : Colors.red,
//                 fontWeight: FontWeight.bold,
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, String amount, String subtitle, {bool isHighlighted = false}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         decoration: BoxDecoration(
//           color: isHighlighted ? Colors.yellow : Colors.grey[850],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Text(amount,
//                 style: TextStyle(
//                     color: isHighlighted ? Colors.black : Colors.yellow,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(subtitle,
//                 style: TextStyle(
//                     color: isHighlighted ? Colors.black : Colors.grey,
//                     fontSize: 10)),
//           ],
//         ),
//       ),
//     );
//   }
// }
