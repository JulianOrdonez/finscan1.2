import 'dart:async';
import 'package:path/path.dart';
import 'package:flutter_application_2/models/expense.dart';
import '../models/user.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseHelper {
  static const _databaseName = "expenses_app.db";
  static const _databaseVersion = 1;

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

  /// Initialize the database.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  /// Create tables.
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
          CREATE TABLE $tableCurrentUser (
            $columnCurrentUserId INTEGER PRIMARY KEY
          )
          ''');
  }

  /// Insert a user into the database.
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, {
      columnUserEmail: user.email,
      columnUserName: user.name,
      columnUserPassword: user.password,
    });
  }


  /// Get the current user's ID from the database.
  Future<int?> getCurrentUserId() async {
    Database db = await instance.database;
    try {
      List<Map<String, dynamic>> result = await db.query(tableCurrentUser);
      if (result.isNotEmpty) {
        return result.first[columnCurrentUserId] as int;
      }
    } catch (e) {}
    return null;
  }

  /// Get a user by their ID from the database.
  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        tableUsers,
        where: '$columnUserId = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return User.fromMap(result.first,);
      }
    } catch (e) {}
    return null;
  }

   /// Clear the current user from the database.
   Future<void> clearCurrentUser() async {
    Database db = await instance.database;
    try {
      await db.delete(tableCurrentUser);
    } catch (e) {
      print('Error clearing current user: $e');
    }
  }

  /// Get all expenses for a given user ID from the database.
  Future<List<Expense>> getAllExpenses(int userId) async {
    Database db = await instance.database;
    try {
      List<Map<String, dynamic>> result = await db.query(
        tableExpenses,
        where: '$columnExpenseUserId = ?',
        whereArgs: [userId],
      );
    return result.map((map) => Expense.fromMap(map)).toList();
    } catch (e) {}
    return [];
  }

  /// Delete an expense from the database.
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

  Future<int> insertExpense(Expense expense) async {
    Database db = await instance.database;
    try {
      Map<String, dynamic> expenseMap = expense.toMap();
      expenseMap.remove('id');
      return await db.insert(tableExpenses, expenseMap);
    } catch (e) {
        print('Error inserting expense: $e');
        return -1;
    }
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
}