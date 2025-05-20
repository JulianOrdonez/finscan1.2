import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/income.dart';

class DatabaseHelper {
  static const _databaseName = "expenses_app.db";
  static const _databaseVersion = 2; // Increased database version

  static const tableUsers = 'users';
  static const columnUserId = 'id';
  static const columnUserEmail = 'email';
  static const columnUserName = 'name';
  static const columnUserPassword = 'password';

  static const tableExpenses = 'expenses';
  static const columnExpenseId = 'id';
  static const columnExpenseUserId = 'user_id';
  static const columnExpenseTitle = 'title';
  static const columnExpenseDescription = 'description';
  static const columnExpenseAmount = 'amount';
  static const columnExpenseCategory = 'category';
  static const columnExpenseDate = 'date';
  static const columnExpenseReceiptPath = 'receiptPath';

  static const tableIncomes = 'incomes';
  static const columnIncomeId = 'id';
  static const columnIncomeUserId = 'user_id';
  static const columnIncomeTitle = 'title';
  static const columnIncomeDescription = 'description';
  static const columnIncomeAmount = 'amount';
  static const columnIncomeDate = 'date';

  static const tableCurrentUser = 'current_user';
  static const columnCurrentUserId = 'id';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableUsers (
            $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnUserName TEXT,
            $columnUserEmail TEXT,
            $columnUserPassword TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableExpenses (
            $columnExpenseId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnExpenseUserId INTEGER,
            $columnExpenseTitle TEXT,
            $columnExpenseDescription TEXT,
            $columnExpenseAmount REAL,
            $columnExpenseCategory TEXT,
            $columnExpenseDate TEXT,
            $columnExpenseReceiptPath TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableIncomes (
            $columnIncomeId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnIncomeUserId INTEGER,
            $columnIncomeTitle TEXT,
            $columnIncomeDescription TEXT,
            $columnIncomeAmount REAL,
            $columnIncomeDate TEXT
          )
          ''');
     await db.execute('''
          CREATE TABLE $tableCurrentUser (
            $columnCurrentUserId INTEGER PRIMARY KEY
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
          CREATE TABLE $tableIncomes (
            $columnIncomeId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnIncomeUserId INTEGER,
            $columnIncomeTitle TEXT,
            $columnIncomeDescription TEXT,
            $columnIncomeAmount REAL,
            $columnIncomeDate TEXT
          )
          ''');
    }
  }

  // User CRUD
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, {
      columnUserEmail: user.email,
      columnUserName: user.name,
      columnUserPassword: user.password,
    });
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUserEmail = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        tableUsers,
        where: '$columnUserId = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      }
    } catch (e) {
      print('Error getting user by ID: $e');
    }
    return null;
  }


  // Current User
  Future<int?> getCurrentUserId() async {
    Database db = await instance.database;
    try {
      List<Map<String, dynamic>> result = await db.query(tableCurrentUser);
      if (result.isNotEmpty) {
        return result.first[columnCurrentUserId] as int;
      }
    } catch (e) {
       print('Error getting current user ID: $e');
    }
    return null;
  }

  Future<int> setCurrentUser(int userId) async {
    Database db = await instance.database;
    try {
      await clearCurrentUser();
      return await db.insert(tableCurrentUser, {columnCurrentUserId: userId});
    } catch (e) {
      print('Error setting current user: $e');
      return -1;
    }
  }

  Future<void> clearCurrentUser() async {
    Database db = await instance.database;
    try {
      await db.delete(tableCurrentUser);
    } catch (e) {
      print('Error clearing current user: $e');
    }
  }


  // Expense CRUD
  Future<int> insertExpense(Expense expense) async {
    Database db = await instance.database;
    try {
      Map<String, dynamic> expenseMap = expense.toMap();
      expenseMap.remove('id'); // Ensure ID is not inserted if it's auto-generated
      return await db.insert(tableExpenses, expenseMap);
    } catch (e) {
        print('Error inserting expense: $e');
        return -1;
    }
  }

  Future<List<Expense>> getExpenses(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableExpenses,
      where: '$columnExpenseUserId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await instance.database;
    try {
      return await db.update(tableExpenses, expense.toMap(), where: '$columnExpenseId = ?', whereArgs: [expense.id]);
    } catch (e) {
      print('Error updating expense: $e');
      return -1;
    }
  }

  Future<int> deleteExpense(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(
        tableExpenses,
        where: '$columnExpenseId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting expense: $e');
      return -1;
    }
  }

  // Income CRUD
  Future<int> insertIncome(Income income) async {
    Database db = await instance.database;
    try {
      Map<String, dynamic> incomeMap = income.toMap();
       incomeMap.remove('id'); // Ensure ID is not inserted if it's auto-generated
      return await db.insert(tableIncomes, incomeMap);
    } catch (e) {
        print('Error inserting income: $e');
        return -1;
    }
  }

  Future<List<Income>> getIncomes(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableIncomes,
      where: '$columnIncomeUserId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  Future<int> updateIncome(Income income) async {
    Database db = await instance.database;
    try {
      return await db.update(tableIncomes, income.toMap(), where: '$columnIncomeId = ?', whereArgs: [income.id]);
    } catch (e) {
      print('Error updating income: $e');
      return -1;
    }
  }

  Future<int> deleteIncome(int id) async {
    Database db = await instance.database;
    try {
      return await db.delete(
        tableIncomes,
        where: '$columnIncomeId = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting income: $e');
      return -1;
    }
  }
}