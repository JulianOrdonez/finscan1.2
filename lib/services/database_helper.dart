import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/models/income.dart'; // Assuming you have these models
import 'package:flutter_application_2/models/expense.dart'; // Assuming you have these models


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
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        // Enable foreign keys
        db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Crea las tablas de usuario, ingresos, gastos y sesiones
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
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS incomes');
      await db.execute('DROP TABLE IF EXISTS expenses');
      await db.execute('DROP TABLE IF EXISTS sessions');
      await _onCreate(db, newVersion);
    }
  }


  // Métodos para la tabla de usuarios
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    final id = await db.insert('users', user.toMap());
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

  // Method to clear the database (useful for development)
  Future<void> clearDatabase() async {
    Database db = await instance.database;
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS incomes');
    await db.execute('DROP TABLE IF EXISTS expenses');
    await db.execute('DROP TABLE IF EXISTS sessions');
    await _onCreate(db, _databaseVersion);
    await db.close();
    _database = null; // Reset the database instance
  }
}