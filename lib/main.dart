import 'package:flutter/material.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'splash_screen.dart'; // Import SplashScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await WalletService.init();
  FlutterError.onError = (FlutterErrorDetails details) {
    ErrorHandler.showError(details.exceptionAsString());
    FlutterError.dumpErrorToConsole(details);
  };
  await Hive.openBox<Wallet>('walletBox');
  await Hive.openBox<Expenses>('expensesBox');
  await Hive.openBox<History>('historyBox'); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fund Divider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Use SplashScreen instead of BottomBar()
    );
  }
}
