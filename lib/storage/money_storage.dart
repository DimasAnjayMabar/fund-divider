import 'package:flutter/foundation.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WalletService {
  static late Box<Wallet> _walletBox;
  static late Box<Savings> _savingsBox;
  static late Box<Expenses> _expensesBox;

  /// **Initialize Hive**
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(SavingsAdapter());
    Hive.registerAdapter(ExpensesAdapter());
    Hive.registerAdapter(HistoryAdapter());

    _walletBox = await Hive.openBox<Wallet>('walletBox');
    _savingsBox = await Hive.openBox<Savings>('savingsBox');
    _expensesBox = await Hive.openBox<Expenses>('expensesBox');
    
    if (_walletBox.isEmpty) {
      setInitialBalance(0.0);
    }
  }

  static Future<void> resetBalance() async {
    await _walletBox.put('main', Wallet(id: 1, balance: 0.0));
  }

  static Future<void> resetSavings() async {
    await _savingsBox.clear();
  }

  static Future<void> resetExpenses() async {
    await _expensesBox.clear();
  }

  /// **Set initial balance**
  static void setInitialBalance(double amount) {
    if (_walletBox.isEmpty) {
      _walletBox.put('main', Wallet(id: 1, balance: amount));
    }
  }

  /// **Get current balance**
  static double getBalance() {
    return _walletBox.get('main')?.balance ?? 0.0;
  }

  /// **Update balance**
  static Future<void> updateBalance(double amount) async {
    double currentBalance = getBalance();
    _walletBox.put('main', Wallet(id: 1, balance: currentBalance + amount));
  }

  static Future<void> updateBalanceToWallet(double amount) async {
    var savingsBox = Hive.box<Savings>('savingsBox');
    var walletBox = Hive.box<Wallet>('walletBox');

    List<Savings> savingsList = savingsBox.values.toList();
    double savingsFund = 0.0;

    if (savingsList.isNotEmpty) {
      for (var saving in savingsList) {
        double savingAmount = amount * (saving.percentage); // Use the saved percentage
        saving.amount += savingAmount;
        savingsFund += savingAmount;
        await savingsBox.put(saving.id, saving);
      }
    }

    // Remaining amount goes to wallet
    double walletFund = amount - savingsFund;
    Wallet wallet = walletBox.get('main', defaultValue: Wallet(id: 1, balance: 0.0))!;
    wallet.balance += walletFund;
    await walletBox.put('main', wallet);
  }

  /// **Add Saving**
  static Future<void> addSaving(String description, double percentage, double amount, double target) async {
    int id = _savingsBox.length + 1;

    // Create the Savings object
    Savings newSaving = Savings(
      id: id,
      description: description,
      percentage: percentage,
      amount: amount,
      target: target,
      date_added: DateTime.now()
    );

    // Store the Savings object in the box
    await _savingsBox.put(id, newSaving);
  }

  /// **Delete Saving and Restore Balance**
  static Future<void> deleteSaving(Savings saving) async {
    var savingsBox = Hive.box<Savings>('savingsBox');

    double amountToRestore = 0.0;

    if(savingsBox.containsKey(saving.id)){
      amountToRestore = saving.amount;
      await savingsBox.delete(saving.id);
    }

    updateBalance(amountToRestore);
  }

  /// **Add Expense**
  static Future<void> addExpense(String description, double amount) async {
    double currentBalance = getBalance();
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

    if (amount > currentBalance) {
      ErrorHandler.showError("Insufficient balance. Your current balance is Rp ${currencyFormatter.format(currentBalance)}.");
      return;
    }


    int id = _expensesBox.length + 1;

    // Deduct the amount from the wallet balance
    _walletBox.put('main', Wallet(id: 1, balance: currentBalance - amount));

    // Create the Expense object
    Expenses newExpense = Expenses(
      id: id,
      description: description,
      amount: amount,
      date_added: DateTime.now()
    );

    // Store the Expense object in the box
    await _expensesBox.put(id, newExpense);
  }

  static Future<void> deleteExpense(Expenses expense) async {
    var expenseBox = Hive.box<Expenses>('expensesBox');

    double amountToRestore = 0.0;

    // Delete related expense if it exists
    if(expenseBox.containsKey(expense.id)){
      amountToRestore = expense.amount;
      await expenseBox.delete(expense.id);
    }

    // Update the balance
    updateBalance(amountToRestore);
  }

  static List<Expenses> getExpense(){
    return _expensesBox.values.map((expense){
      return Expenses(id: expense.id, description: expense.description, amount: expense.amount, date_added: expense.date_added);
    }).toList();
  }

  static double getTotalExpenseForPeriod(Duration period) {
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(period);

    return WalletService.getExpense()
        .where((expense) => expense.date_added.isAfter(startDate))
        .map((expense) => expense.amount)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  static Savings? getSavingById(int id) {
    return _savingsBox.get(id);
  }

  static Expenses? getExpenseById(int id) {
    return _expensesBox.get(id);
  }

    /// **Listen to balance updates**
  static ValueListenable<Box<Wallet>> listenToBalance() {
    return _walletBox.listenable();
  }

  static ValueListenable<Box<Expenses>> listenToExpenses(){
    return _expensesBox.listenable();
  }

  static ValueListenable<Box<Savings>> listenToSavings(){
    return _savingsBox.listenable();
  }
}
