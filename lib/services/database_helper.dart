import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter_application_2/models/income.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/models/expense.dart';


class DatabaseHelper {
  static const int _databaseVersion = 1;
  static const String _databaseName = 'finscan.db';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // IMPORTANT: Calling clearDatabase() here will wipe all existing data.
    // Remove this call in production.
    await clearDatabase();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        // Enable foreign keys
        db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Crea las tablas de usuario, ingresos y gastos
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        receiptPath TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For now, simply drop and recreate tables for schema changes
    // In a real app, you would handle migrations more carefully
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS incomes');
    await db.execute('DROP TABLE IF EXISTS expenses');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await _onCreate(db, newVersion);
  }


  // Métodos para la tabla de usuarios
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    final id = await db.insert('users', user.toMap());
    print('Inserted user with ID: $id');
    return id;
  }

  Future<User?> getUserByEmail(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    Database db = await instance.database;
    print('Attempting to get user by email: $email and password: $password');
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    print('User not found for email: $email');
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
    print('Attempting to get user by ID: $id');
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],

    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Métodos para la tabla de ingresos
  Future<int> insertIncome(Income income) async {
    Database db = await instance.database;
    print('Inserting income: ${income.toMap()}');
    return await db.insert('incomes', income.toMap());
  }

  Future<List<Income>> getIncomes(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    print('Fetched ${maps.length} incomes for userId: $userId');
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  Future<int> updateIncome(Income income) async {
    print('Updating income with ID: ${income.id}');
    Database db = await instance.database;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    print('Deleting income with ID: $id');
    Database db = await instance.database;
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // Métodos para la tabla de gastos
  Future<int> insertExpense(Expense expense) async {
    Database db = await instance.database;
    print('Inserting expense: ${expense.toMap()}');
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    print('Fetched ${maps.length} expenses for userId: $userId');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

    Future<List<Expense>> getAllExpenses() async {
    print('Fetching all expenses');
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }


  Future<int> updateExpense(Expense expense) async {
    print('Updating expense with ID: ${expense.id}');
    Database db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    print('Deleting expense with ID: $id');
    Database db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método para limpiar la base de datos (solo para desarrollo/debugging)
  Future<void> clearDatabase() async {
    print('Clearing database...');
    Database db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS incomes');
    await db.execute('DROP TABLE IF EXISTS expenses');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await _onCreate(db, _databaseVersion);
    // Cerrar y reabrir la base de datos para asegurar que los cambios se apliquen
    await db.close();
    print('Database cleared and recreated.');
    _database = null; // Resetear la instancia de la base de datos
  }
}