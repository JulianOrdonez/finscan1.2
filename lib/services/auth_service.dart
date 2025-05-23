import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/services/database_helper.dart';

/// Custom exception for when a user with the provided email already exists.
class UserExistsException implements Exception {
  final String message;
  UserExistsException(this.message);

  @override
  String toString() {
    return 'UserExistsException: $message';
  }
}

/// Custom exception for when a provided password is too weak.
class WeakPasswordException implements Exception {
  final String message;
  WeakPasswordException(this.message);

  @override
  String toString() {
    return 'WeakPasswordException: $message';
  }
}

/// Custom exception for authentication failures (e.g., invalid credentials).
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() {
    return 'AuthenticationException: $message';
  }
}

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _loggedInUserIdKey = 'loggedInUserId';

  /// Registers a new user.
  ///
  /// Throws [UserExistsException] if a user with the email already exists.
  /// Throws [WeakPasswordException] if the password is too short (less than 6 characters).
  /// Throws [Exception] for other registration errors.
  Future<void> register(String name, String email, String password) async {
    // Basic validation
    if (password.length < 6) {
      throw WeakPasswordException('Password should be at least 6 characters long.');
    }

    // Check if user already exists
    final existingUser = await _databaseHelper.getUserByEmail(email);
    if (existingUser != null) {
      throw UserExistsException('User with email $email already exists.');
    }

    try {
      final newUser = User(name: name, email: email, password: password);
      await _databaseHelper.insertUser(newUser);
      print('User registered successfully: ${newUser.email}');
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register user.');
    }
  }

  /// Logs in a user.
  ///
  /// Throws [AuthenticationException] if login fails (invalid email or password).
  /// Throws [Exception] for other login errors.
  Future<void> login(String email, String password) async {
    try {
      final user = await _databaseHelper.getUserByEmailAndPassword(email, password);
      if (user == null) {
        throw AuthenticationException('Invalid email or password.');
      }

      // Store the user ID in SharedPreferences for session management
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_loggedInUserIdKey, user.id!);

      // You might also want to store session information in the database if needed
      // final db = await _databaseHelper.database;
      // await db.insert('sessions', {'userId': user.id});

      print('User logged in successfully: ${user.email}');
    } catch (e) {
      print('Error during login: $e');
      if (e is AuthenticationException) {
        rethrow; // Rethrow the specific authentication exception
      }
      throw Exception('Failed to log in.');
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInUserIdKey);

      // You might also want to remove session information from the database
      // final db = await _databaseHelper.database;
      // await db.delete('sessions', where: 'userId = ?', whereArgs: [userId]); // Need to get current user ID first

      print('User logged out.');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to log out.');
    }
  }

  /// Gets the ID of the currently logged-in user.
  /// Returns null if no user is logged in.
  Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_loggedInUserIdKey);
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }
}