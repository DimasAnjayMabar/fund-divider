import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class WalletService {
  // Constants for performance
  static const int BIG_DATA_THRESHOLD = 1000;
  static const int PAGINATION_LIMIT = 20;
  static const int RECENT_ITEMS_LIMIT = 3;
  
  // Box instances
  static late Box<Wallet> _walletBox;
  static late Box<Savings> _savingsBox;
  static late Box<Expenses> _expensesBox;
  static late Box<History> _historyBox;
  static late Box<Username> _usernameBox;
  
  // Cache untuk summary
  static Map<String, double>? _cachedSummary;
  static DateTime? _lastSummaryUpdate;
  static Map<String, dynamic>? _cachedDashboardStats; // GANTI TIPE INI

  /// ====================== INITIALIZATION ======================
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(SavingsAdapter());
    Hive.registerAdapter(ExpensesAdapter());
    Hive.registerAdapter(HistoryAdapter());
    Hive.registerAdapter(UsernameAdapter());

    _walletBox = await Hive.openBox<Wallet>('walletBox');
    _savingsBox = await Hive.openBox<Savings>('savingsBox');
    _expensesBox = await Hive.openBox<Expenses>('expensesBox');
    _historyBox = await Hive.openBox<History>('historyBox');
    _usernameBox = await Hive.openBox<Username>('usernameBox');

    if (_walletBox.isEmpty) {
      setInitialBalance(0.0);
    }
  }

  /// ====================== WALLET MODEL (TETAP SAMA) ======================
  /// Set initial balance
  static void setInitialBalance(double amount) {
    if (_walletBox.isEmpty) {
      _walletBox.put('main', Wallet(id: 1, balance: amount));
    }
  }

  /// Get current balance
  static double getBalance() {
    return _walletBox.get('main')?.balance ?? 0.0;
  }

  /// Update balance
  static Future<void> updateBalance(double amount) async {
    double currentBalance = getBalance();
    _walletBox.put('main', Wallet(id: 1, balance: currentBalance + amount));
    _invalidateCache();
  }

  static Future<void> resetBalance() async {
    await _walletBox.put('main', Wallet(id: 1, balance: 0.0));
    _invalidateCache();
  }

  /// Listen to balance updates
  static ValueListenable<Box<Wallet>> listenToBalance() {
    return _walletBox.listenable();
  }

  static Stream<double> watchWalletBalance() {
    return _walletBox.watch().map((event) => getBalance());
  }

  /// ====================== EXPENSES MODEL (OPTIMIZED FOR BIG DATA) ======================
  /// 1. Recent 3 transactions (OPTIMIZED - tidak load semua)
  static List<Expenses> getRecentExpenses({int limit = RECENT_ITEMS_LIMIT}) {
    // Untuk data kecil, pakai cara biasa
    if (_expensesBox.length <= limit * 2) {
      return _expensesBox.values
          .toList()
          .reversed
          .take(limit)
          .toList();
    }
    
    // Untuk big data: ambil dari akhir tanpa load semua
    List<Expenses> recent = [];
    for (int i = _expensesBox.length; i > 0 && recent.length < limit; i--) {
      final expense = _expensesBox.getAt(i - 1);
      if (expense != null) {
        recent.add(expense);
      }
    }
    return recent;
  }

  /// 2. Expenses Count (OPTIMIZED - O(1))
  static int getExpensesCount() {
    return _expensesBox.length; // O(1) operation
  }

  /// 3. Get expenses with pagination
  static List<Expenses> getExpensesPaginated({
    int page = 1,
    int limit = PAGINATION_LIMIT,
    bool sortByNewest = true,
  }) {
    final totalItems = _expensesBox.length;
    final startIdx = (page - 1) * limit;
    
    if (startIdx >= totalItems) return [];
    
    List<Expenses> items = [];
    
    if (sortByNewest) {
      // Ambil dari yang terbaru
      for (int i = totalItems - 1 - startIdx; 
           i >= 0 && items.length < limit; 
           i--) {
        final expense = _expensesBox.getAt(i);
        if (expense != null) items.add(expense);
      }
    } else {
      // Ambil dari yang terlama
      for (int i = startIdx; i < startIdx + limit && i < totalItems; i++) {
        final expense = _expensesBox.getAt(i);
        if (expense != null) items.add(expense);
      }
    }
    
    return items;
  }

  /// 4. Get expense summary (daily, weekly, monthly) - SINGLE PASS
  static Map<String, double> getExpenseSummary() {
    // Cek cache
    final now = DateTime.now();
    if (_cachedSummary != null && 
        _lastSummaryUpdate != null &&
        now.difference(_lastSummaryUpdate!) < Duration(minutes: 5)) {
      return _cachedSummary!;
    }
    
    DateTime dailyStart = now.subtract(Duration(days: 1));
    DateTime weeklyStart = now.subtract(Duration(days: 7));
    DateTime monthlyStart = now.subtract(Duration(days: 30));
    
    double dailyTotal = 0.0;
    double weeklyTotal = 0.0;
    double monthlyTotal = 0.0;
    
    // Single pass optimization
    if (_expensesBox.length > BIG_DATA_THRESHOLD) {
      // Untuk data besar, pakai indexed loop
      for (int i = 0; i < _expensesBox.length; i++) {
        final expense = _expensesBox.getAt(i);
        if (expense != null) {
          // Update summary counters
          final date = expense.date_added;
          final amount = expense.amount;
          
          if (date.isAfter(dailyStart)) {
            dailyTotal += amount;
            weeklyTotal += amount;
            monthlyTotal += amount;
          } else if (date.isAfter(weeklyStart)) {
            weeklyTotal += amount;
            monthlyTotal += amount;
          } else if (date.isAfter(monthlyStart)) {
            monthlyTotal += amount;
          }
        }
      }
    } else {
      // Untuk data kecil
      for (final expense in _expensesBox.values) {
        final date = expense.date_added;
        final amount = expense.amount;
        
        if (date.isAfter(dailyStart)) {
          dailyTotal += amount;
          weeklyTotal += amount;
          monthlyTotal += amount;
        } else if (date.isAfter(weeklyStart)) {
          weeklyTotal += amount;
          monthlyTotal += amount;
        } else if (date.isAfter(monthlyStart)) {
          monthlyTotal += amount;
        }
      }
    }
    
    final summary = {
      'daily': dailyTotal,
      'weekly': weeklyTotal,
      'monthly': monthlyTotal,
    };
    
    // Update cache
    _cachedSummary = summary;
    _lastSummaryUpdate = now;
    
    return summary;
  }

  /// 5. Get all expenses (UNTUK COMPATIBILITY - gunakan paginated jika bisa)
  static List<Expenses> getExpense() {
    // Warning: hanya untuk data kecil
    if (_expensesBox.length > 500) {
      if (kDebugMode) {
        print('WARNING: Using getExpense() with large dataset (${_expensesBox.length} items). Consider using pagination.');
      }
    }
    return _expensesBox.values.toList();
  }

  /// 6. Get total expense for period (OPTIMIZED VERSION)
  static double getTotalExpenseForPeriod(Duration period) {
    DateTime startDate = DateTime.now().subtract(period);
    
    // Untuk data kecil (<1000), pakai cara lama untuk compatibility
    if (_expensesBox.length < 1000) {
      return getExpense()
          .where((expense) => expense.date_added.isAfter(startDate))
          .fold(0.0, (sum, expense) => sum + expense.amount);
    }
    
    // Untuk data besar, optimasi
    double total = 0.0;
    for (int i = 0; i < _expensesBox.length; i++) {
      final expense = _expensesBox.getAt(i);
      if (expense != null && expense.date_added.isAfter(startDate)) {
        total += expense.amount;
      }
    }
    return total;
  }

  /// 7. Add Expense (TETAP SAMA dengan cache invalidation)
  static Future<void> addExpense(String description, double amount) async {
    double currentBalance = getBalance();
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

    if (amount > currentBalance) {
      ErrorHandler.showError(
          "Insufficient balance. Your current balance is Rp ${currencyFormatter.format(currentBalance)}.");
      return;
    }

    int id = _expensesBox.length + 1;

    // Deduct from balance
    _walletBox.put('main', Wallet(id: 1, balance: currentBalance - amount));

    Expenses newExpense = Expenses(
        id: id,
        description: description,
        amount: amount,
        date_added: DateTime.now());

    await _expensesBox.put(id, newExpense);
    _invalidateCache();
  }

  /// 8. Delete Expense (TETAP SAMA dengan cache invalidation)
  static Future<void> deleteExpense(Expenses expense) async {
    if (_expensesBox.containsKey(expense.id)) {
      await _expensesBox.delete(expense.id);
      updateBalance(expense.amount);
      _invalidateCache();
    }
  }

  /// 9. Get Expense by ID
  static Expenses? getExpenseById(int id) {
    return _expensesBox.get(id);
  }

  /// 10. Listen to expenses
  static ValueListenable<Box<Expenses>> listenToExpenses() {
    return _expensesBox.listenable();
  }

  /// Stream untuk expense count (O(1) operation)
  static Stream<int> watchExpenseCount() {
    return _expensesBox.watch().map((event) => _expensesBox.length);
  }
  
  /// Stream untuk recent expenses (tanpa load semua)
  static Stream<List<Expenses>> watchRecentExpenses({int limit = 3}) {
    return _expensesBox.watch().map((event) {
      return getRecentExpenses(limit: limit);
    });
  }
  
  /// Stream untuk expense summary (dengan cache)
  static Stream<Map<String, double>> watchExpenseSummary() {
    return _expensesBox.watch().map((event) {
      return getExpenseSummary(); // Gunakan yang sudah dicache
    });
  }

  /// ====================== SAVINGS MODEL (OPTIMIZED FOR BIG DATA) ======================
  /// 1. Recent 3 savings (OPTIMIZED)
  static List<Savings> getRecentSavings({int limit = RECENT_ITEMS_LIMIT}) {
    if (_savingsBox.length <= limit * 2) {
      return _savingsBox.values
          .toList()
          .reversed
          .take(limit)
          .toList();
    }
    
    List<Savings> recent = [];
    for (int i = _savingsBox.length; i > 0 && recent.length < limit; i--) {
      final saving = _savingsBox.getAt(i - 1);
      if (saving != null) {
        recent.add(saving);
      }
    }
    return recent;
  }

  /// 2. Savings Count (OPTIMIZED - O(1))
  static int getSavingsCount() {
    return _savingsBox.length; // O(1)
  }

  /// 3. Get all savings (UNTUK COMPATIBILITY)
  static List<Savings> getAllSavings() {
    // Warning: hanya untuk data kecil
    if (_savingsBox.length > 500) {
      if (kDebugMode) {
        print('WARNING: Using getAllSavings() with large dataset (${_savingsBox.length} items). Consider using pagination.');
      }
    }
    return _savingsBox.values.toList();
  }

  /// 4. Get savings with pagination
  static List<Savings> getSavingsPaginated({
    int page = 1,
    int limit = PAGINATION_LIMIT,
  }) {
    final totalItems = _savingsBox.length;
    final startIdx = (page - 1) * limit;
    
    if (startIdx >= totalItems) return [];
    
    List<Savings> items = [];
    for (int i = startIdx; i < startIdx + limit && i < totalItems; i++) {
      final saving = _savingsBox.getAt(i);
      if (saving != null) items.add(saving);
    }
    
    return items;
  }

  /// 5. Add Saving (TETAP SAMA)
  static Future<void> addSaving(String description, double percentage,
      double amount, double target) async {
    int id = _savingsBox.length + 1;

    Savings newSaving = Savings(
        id: id,
        description: description,
        percentage: percentage,
        amount: amount,
        target: target,
        date_added: DateTime.now());

    await _savingsBox.put(id, newSaving);
    _invalidateCache();
  }

  /// 6. Delete Saving (TETAP SAMA)
  static Future<void> deleteSaving(Savings saving) async {
    if (_savingsBox.containsKey(saving.id)) {
      await _savingsBox.delete(saving.id);
      updateBalance(saving.amount);
      _invalidateCache();
    }
  }

  /// 7. Get Saving by ID
  static Savings? getSavingById(int id) {
    return _savingsBox.get(id);
  }

  /// 8. Get total savings percentage
  static double getTotalSavingsPercentage() {
    return _savingsBox.values.fold(0.0, (sum, saving) => sum + saving.percentage);
  }

  /// 9. Listen to savings
  static ValueListenable<Box<Savings>> listenToSavings() {
    return _savingsBox.listenable();
  }

  /// 10. Reset savings
  static Future<void> resetSavings() async {
    await _savingsBox.clear();
    _invalidateCache();
  }

  static Stream<int> watchSavingsCount() {
    return _savingsBox.watch().map((event) => _savingsBox.length);
  }

  /// ====================== DASHBOARD STATS (OPTIMIZED) ======================
  static Map<String, dynamic> getDashboardStats() {
    // Cek cache
    final now = DateTime.now();
    if (_cachedDashboardStats != null &&
        _lastSummaryUpdate != null &&
        now.difference(_lastSummaryUpdate!) < Duration(minutes: 1)) {
      return _cachedDashboardStats!;
    }
    
    final stats = {
      'walletBalance': getBalance(),
      'savingsCount': getSavingsCount(), // O(1)
      'expensesCount': getExpensesCount(), // O(1)
      'expenseSummary': getExpenseSummary(),
      'lastUpdated': now,
    };
    
    _cachedDashboardStats = stats;
    _lastSummaryUpdate = now;
    
    return stats;
  }

  /// ====================== CACHE MANAGEMENT ======================
  static void _invalidateCache() {
    _cachedSummary = null;
    _cachedDashboardStats = null;
  }

  /// ====================== CROSS-MODEL OPERATIONS (TETAP SAMA) ======================
  static Future<void> updateBalanceToWallet(double amount) async {
    List<Savings> savingsList = getAllSavings();
    double savingsFund = 0.0;

    if (savingsList.isNotEmpty) {
      for (var saving in savingsList) {
        double savingAmount = amount * saving.percentage;
        saving.amount += savingAmount;
        savingsFund += savingAmount;
        await _savingsBox.put(saving.id, saving);
      }
    }

    // Remaining to wallet
    double walletFund = amount - savingsFund;
    Wallet wallet = _walletBox.get('main') ?? Wallet(id: 1, balance: 0.0);
    wallet.balance += walletFund;
    await _walletBox.put('main', wallet);
    _invalidateCache();
  }

  static Future<void> depositInSaving() async {
    // TODO: Implement
  }

  /// ====================== HISTORY MODEL (TETAP SAMA) ======================
  // Catatan: Fungsi untuk History bisa ditambahkan sesuai kebutuhan

  /// ====================== USERNAME MODEL (TETAP SAMA) ======================
  static bool hasUsername() {
    return _usernameBox.isNotEmpty;
  }

  static Future<void> saveUsername(String name) async {
    await _usernameBox.clear();
    await _usernameBox.add(Username(name: name));
  }

  static String getUsername() {
    if (_usernameBox.isNotEmpty) {
      return _usernameBox.getAt(0)?.name ?? '';
    }
    return '';
  }

  static Future<void> resetUsername() async {
    await _usernameBox.clear();
  }

  static ValueListenable<Box<Username>> listenToUsername() {
    return _usernameBox.listenable();
  }

  /// ====================== RESET FUNCTIONS (TETAP SAMA) ======================
  static Future<void> resetExpenses() async {
    await _expensesBox.clear();
    _invalidateCache();
  }

  /// ====================== OCR MODEL ======================
  static final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// ====================== OCR RECEIPT PROCESSING ======================
  /// Process image file from camera/gallery and create expense automatically
  static Future<Map<String, dynamic>> processReceiptImage(File imageFile) async {
    try {
      // Step 1: OCR Text Recognition
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Step 2: Extract text from OCR result
      String fullText = recognizedText.text;
      
      // Step 3: Parse receipt data
      final parsedData = _parseReceiptText(fullText);
      
      // Step 4: Create expense from parsed data
      if (parsedData['amount'] > 0) {
        await addExpenseFromReceipt(
          description: parsedData['description'],
          amount: parsedData['amount'],
          storeName: parsedData['store_name'],
          items: parsedData['items'],
        );
      }
      
      return {
        'success': true,
        'amount': parsedData['amount'],
        'description': parsedData['description'],
        'store_name': parsedData['store_name'],
        'items_count': parsedData['items'].length,
        'raw_text': fullText,
      };
      
    } catch (e) {
      if (kDebugMode) {
        print('OCR Error: $e');
      }
      return {
        'success': false,
        'error': 'Failed to process receipt: ${e.toString()}',
      };
    }
  }

  /// Parse receipt text to extract relevant information
  static Map<String, dynamic> _parseReceiptText(String text) {
    final lines = text.split('\n');
    double totalAmount = 0.0;
    String storeName = 'Unknown Store';
    List<String> items = [];
    List<String> allLines = [];
    
    // Pattern untuk mendeteksi total/total amount
    final totalPatterns = [
      RegExp(r'total\s*[:]?\s*Rp?\s*(\d+[.,]?\d*)', caseSensitive: false),
      RegExp(r'jumlah\s*[:]?\s*Rp?\s*(\d+[.,]?\d*)', caseSensitive: false),
      RegExp(r'grand\s*total\s*[:]?\s*Rp?\s*(\d+[.,]?\d*)', caseSensitive: false),
      RegExp(r'Rp?\s*(\d+[.,]?\d*)\s*$'),
      RegExp(r'(\d+[.,]\d{3})\s*$'),
    ];
    
    // Pattern untuk mendeteksi nama toko
    final storePatterns = [
      RegExp(r'^(?!(total|jumlah|item|harga|qty)).{3,}$', caseSensitive: false),
    ];
    
    // Pattern untuk mendeteksi item dan harga
    final itemPattern = RegExp(r'(.+?)\s+(\d+[.,]\d{3}|\d+)\s*$');
    final pricePattern = RegExp(r'(\d+[.,]\d{3}|\d+)');
    
    // Analisis setiap baris
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      
      allLines.add(line);
      
      // Cek apakah ini baris total
      bool isTotalLine = false;
      for (var pattern in totalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null && match.group(1) != null) {
          String amountStr = match.group(1)!.replaceAll('.', '').replaceAll(',', '.');
          totalAmount = double.tryParse(amountStr) ?? 0.0;
          isTotalLine = true;
          break;
        }
      }
      
      // Jika bukan total line, cek apakah ini item
      if (!isTotalLine) {
        // Cek apakah line berisi harga
        final priceMatches = pricePattern.allMatches(line);
        if (priceMatches.length == 1) {
          // Kemungkinan ini item dengan harga
          final itemMatch = itemPattern.firstMatch(line);
          if (itemMatch != null) {
            items.add(line);
          }
        }
        
        // Cek apakah ini nama toko (biasanya di awal atau memiliki karakter khusus)
        if (storeName == 'Unknown Store' && 
            line.length > 3 && 
            line.length < 50 &&
            !line.toLowerCase().contains('total') &&
            !line.toLowerCase().contains('jumlah') &&
            !line.contains(RegExp(r'\d'))) {
          storeName = line;
        }
      }
    }
    
    // Jika total tidak ditemukan, coba cari angka terbesar di teks
    if (totalAmount == 0.0) {
      final allNumbers = pricePattern.allMatches(text);
      double maxNumber = 0.0;
      for (var match in allNumbers) {
        String numStr = match.group(0)!.replaceAll('.', '').replaceAll(',', '.');
        double? num = double.tryParse(numStr);
        if (num != null && num > maxNumber && num < 10000000) { // Batasi untuk mencegah kesalahan
          maxNumber = num;
        }
      }
      totalAmount = maxNumber;
    }
    
    // Buat deskripsi dari data yang ditemukan
    String description = _generateDescription(storeName, items, totalAmount);
    
    return {
      'amount': totalAmount,
      'description': description,
      'store_name': storeName,
      'items': items,
      'all_lines': allLines,
    };
  }

  /// Generate description from parsed receipt data
  static String _generateDescription(String storeName, List<String> items, double amount) {
    if (items.isNotEmpty) {
      if (items.length == 1) {
        return '$storeName - ${items.first}';
      } else {
        return '$storeName - ${items.length} items';
      }
    }
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return '$storeName - ${formatter.format(amount)}';
  }

  /// Add expense from receipt processing
  static Future<void> addExpenseFromReceipt({
    required String description,
    required double amount,
    required String storeName,
    required List<String> items,
  }) async {
    // Validasi balance
    double currentBalance = getBalance();
    final NumberFormat currencyFormatter = NumberFormat.decimalPattern("id_ID");

    if (amount > currentBalance) {
      ErrorHandler.showError(
          "Insufficient balance. Your current balance is ${currencyFormatter.format(currentBalance)}.");
      return;
    }

    int id = _expensesBox.length + 1;

    // Kurangi dari balance
    _walletBox.put('main', Wallet(id: 1, balance: currentBalance - amount));

    Expenses newExpense = Expenses(
        id: id,
        description: description,
        amount: amount,
        date_added: DateTime.now());

    await _expensesBox.put(id, newExpense);
    _invalidateCache();
    
    // Log history
    await _logReceiptHistory(newExpense, storeName, items);
  }

  /// Log receipt processing to history
  static Future<void> _logReceiptHistory(Expenses expense, String storeName, List<String> items) async {
    try {
      int id = _historyBox.length + 1;
      History history = History(
        id: id,
        expense: expense,
        dateAdded: DateTime.now(),
      );
      await _historyBox.put(id, history);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log receipt history: $e');
      }
    }
  }

  /// Cleanup OCR resources
  static void disposeOCR() {
    _textRecognizer.close();
  }
}