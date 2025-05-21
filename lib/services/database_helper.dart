import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter_application_2/models/income.dart';
import 'package:flutter_application_2/models/expense.dart';

// Modelo para el usuario
class User {
  int id;
  String name;
  String email;
  String password;

  User({required this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
    );
  }
}



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
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
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
        category TEXT NOT NULL,
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
  }

  // Métodos para la tabla de usuarios
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert('users', user.toMap());
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
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(int id) async {
    Database db = await instance.database;
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
    return await db.insert('incomes', income.toMap());
  }

  Future<List<Income>> getIncomesByUserId(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC', // Opcional: ordenar por fecha
    );
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  Future<int> updateIncome(Income income) async {
    Database db = await instance.database;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
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
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpensesByUserId(int userId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC', // Opcional: ordenar por fecha
    );
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

    Future<List<Expense>> getAllExpenses() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }


  Future<int> updateExpense(Expense expense) async {
    Database db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}