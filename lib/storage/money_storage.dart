import 'package:flutter/foundation.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WalletService {
  static late Box<Wallet> _walletBox;
  static late Box<Savings> _savingsBox;
  static late Box<Expenses> _expensesBox;
  static late Box<History> _historyBox;

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
    _historyBox = await Hive.openBox<History>('historyBox');

    if (_walletBox.isEmpty) {
      setInitialBalance(0.0);
    }
  }

  /// **Listen to balance updates**
  static ValueListenable<Box<Wallet>> listenToBalance() {
    return _walletBox.listenable();
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

  /// **Add Saving**
  static Future<void> addSaving(
    String description, double percentage, double amount, double target) async {
  int id = _savingsBox.length + 1;

  // Create the Savings object
  Savings newSaving = Savings(
    id: id,
    description: description,
    percentage: percentage,
    amount: amount,
    target: target,
    isDeleted: false,
  );

  // Store the Savings object in the box
  await _savingsBox.put(id, newSaving);

    // Create and store the History record with a reference to the new saving
    History historyEntry = History(
      id: _historyBox.length + 1,  // Unique history ID
      saving: newSaving, // Direct reference to the Savings object
      expense: null,  // No expense since this is a saving
      dateAdded: DateTime.now(),
    );

    await _historyBox.add(historyEntry);
  }


  /// **Add Expense**
  static Future<void> addExpense(String description, double amount) async {
    double currentBalance = getBalance();

    if (amount > currentBalance) {
      ErrorHandler.showError("Not enough balance!");
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
    );

    // Store the Expense object in the box
    await _expensesBox.put(id, newExpense);

    // Create and store the History record with a reference to the new expense
    // Create and store the History record with a reference to the new expense
    History historyEntry = History(
      id: id, // Unique history ID
      saving: null, // No saving since this is an expense
      expense: newExpense, // Store FULL Expense object instead of ID
      dateAdded: DateTime.now(),
    );
    
    await _historyBox.add(historyEntry);
  }

  static Future<void> deleteExpenseFromHistory(History history) async {
    var historyBox = Hive.box<History>('historyBox');
    var expenseBox = Hive.box<Expenses>('expensesBox');

    double amountToRestore = 0.0;

    // Delete related expense if it exists
    if (history.expense != null) {
      int? expenseId = history.expense!.id;
      if (expenseBox.containsKey(expenseId)) {
        amountToRestore = history.expense!.amount; // Store amount before deletion
        await expenseBox.delete(expenseId);
      }
    }

    // Remove the history entry itself
    await historyBox.delete(history.id);

    // Update the balance
    updateBalance(amountToRestore);
  }

  /// **Get Expense History**
  static List<History> getHistory() {
    return _historyBox.values.map((history) {
      return History(
        id: history.id,
        saving: history.saving, 
        expense: history.expense is int ? getExpenseById(history.expense as int) : history.expense,
        dateAdded: history.dateAdded,
      );
    }).toList();
  }

  static Savings? getSavingById(int id) {
    return _savingsBox.get(id);
  }

  static Expenses? getExpenseById(int id) {
    return _expensesBox.get(id);
  }

  static ValueListenable<Box<History>> listenToHistory() {
    return _historyBox.listenable();
  }

  static ValueListenable<Box<Wallet>> listenBalance() {
    return _walletBox.listenable();
  }
}
