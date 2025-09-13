import 'package:hive/hive.dart';
part 'hive.g.dart';

@HiveType(typeId: 0)
class Wallet {
  @HiveField(0)
  int id;

  @HiveField(1)
  double balance;

  Wallet({required this.id, required this.balance});
}

@HiveType(typeId: 1)
class Savings {
  @HiveField(0)
  int id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double percentage;

  @HiveField(3)
  double amount;

  @HiveField(4)
  double target;

  @HiveField(6)
  DateTime date_added;

  Savings(
      {required this.id,
      required this.description,
      required this.percentage,
      required this.amount,
      required this.target,
      required this.date_added});
}

@HiveType(typeId: 2)
class Expenses {
  @HiveField(0)
  int id;

  @HiveField(1)
  String description;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date_added;

  Expenses(
      {required this.id,
      required this.description,
      required this.amount,
      required this.date_added});
}

@HiveType(typeId: 3)
class History {
  @HiveField(0)
  int id;

  @HiveField(1)
  Savings? saving; // Reference to a Savings object

  @HiveField(2)
  Expenses? expense; // Reference to an Expenses object

  @HiveField(3)
  DateTime dateAdded;

  History({
    required this.id,
    this.saving,
    this.expense,
    required this.dateAdded,
  });
}

@HiveType(typeId: 4)
class Username {
  @HiveField(0)
  String name;

  Username({required this.name});
}
