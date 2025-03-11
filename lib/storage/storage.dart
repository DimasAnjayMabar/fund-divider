import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fund_divider.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Wallet (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            balance REAL NOT NULL DEFAULT 0.0
          )
        ''');
        await db.execute('''
          CREATE TABLE Expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            amount REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE Savings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            percentage REAL NOT NULL,
            amount REAL NOT NULL,
            target REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE History (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expense_id INTEGER,
            saving_id INTEGER,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (expense_id) REFERENCES Expenses(id) ON DELETE CASCADE,
            FOREIGN KEY (saving_id) REFERENCES Savings(id) ON DELETE CASCADE
          )
        ''');
        await db.insert('Wallet', {'balance': 0.0});
      },
    );
  }
}
