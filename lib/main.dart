import 'package:flutter/material.dart';
import 'package:fund_divider/bottom_bar/bottom_bar.dart';
import 'package:fund_divider/popups/error/error.dart';
import 'package:fund_divider/model/error_handler.dart';
import 'package:fund_divider/model/hive.dart';
import 'package:fund_divider/storage/money_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Stack(
        children: [
          const BottomBar(),
          ValueListenableBuilder<String?>(
            valueListenable: ErrorHandler.errorMessage,
            builder: (context, error, child) {
              if (error != null) {
                Future.delayed(Duration.zero, () {
                  showDialog(
                    context: context,
                    builder: (context) => ErrorPopup(errorMessage: error),
                  );
                });
              }
              return const SizedBox.shrink(); // Returns an empty widget when there's no error
            },
          ),
        ],
      ),
    );
  }
}