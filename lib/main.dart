import 'package:flutter/material.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'splash_screen.dart';

// Global variable untuk menyimpan status reset
bool wasReset = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await WalletService.init();
  
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.showError(details.exceptionAsString());
    FlutterError.dumpErrorToConsole(details);
  };
  
  // Buka semua box
  final walletBox = await Hive.openBox<Wallet>('walletBox');
  final expensesBox = await Hive.openBox<Expenses>('expensesBox');
  final historyBox = await Hive.openBox<History>('historyBox');
  
  // Box terpisah untuk metadata/app settings
  final settingsBox = await Hive.openBox('appSettings');
  
  // Cek dan reset jika sudah 95 hari
  wasReset = await _checkAndResetIfNeeded(expensesBox, settingsBox);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(showResetMessage: wasReset),
    );
  }
}

Future<bool> _checkAndResetIfNeeded(Box<Expenses> expensesBox, Box settingsBox) async {
  const String lastResetDateKey = 'last_reset_date';
  const int resetThresholdDays = 95;
  
  // Ambil tanggal terakhir reset dari settingsBox
  final dynamic storedValue = settingsBox.get(lastResetDateKey);
  DateTime lastResetDate;
  
  if (storedValue == null) {
    // Jika belum ada data reset, set ke tanggal sekarang
    lastResetDate = DateTime.now();
    await settingsBox.put(lastResetDateKey, lastResetDate.toIso8601String()); 
    return false;
  } else if (storedValue is String) {
    // Jika disimpan sebagai String (ISO format)
    lastResetDate = DateTime.parse(storedValue);
  } else if (storedValue is DateTime) {   
    // Jika langsung disimpan sebagai DateTime
    lastResetDate = storedValue;
  } else {
    // Fallback
    lastResetDate = DateTime.now();
  }
  
  // Hitung selisih hari
  final currentDate = DateTime.now();
  final differenceInDays = currentDate.difference(lastResetDate).inDays;
  
  // Jika sudah mencapai atau melebihi 95 hari, lakukan reset
  if (differenceInDays >= resetThresholdDays) {
    print('Reset data setelah $differenceInDays hari');
    
    // Hapus SEMUA data di expensesBox
    await expensesBox.clear();
    
    // Update tanggal reset terbaru di settingsBox
    await settingsBox.put(lastResetDateKey, currentDate.toIso8601String());
    
    print('Reset expenses selesai pada: $currentDate');
    return true; // Mengembalikan true karena reset dilakukan
  } else {
    print('Belum waktunya reset. $differenceInDays hari berlalu sejak reset terakhir');
    return false;
  }
}