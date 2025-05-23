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
  Future<bool> login(String email, String password) async {
    try {
      final user = await _databaseHelper.getUserByEmailAndPassword(email, password);
      if (user == null) {
        return false; // Invalid email or password
      }

      // Insert session information into the database
      final db = await _databaseHelper.database;
      // Before inserting, delete any existing session for this user to ensure only one active session
      await db.delete('sessions', where: 'userId = ?', whereArgs: [user.id!]);
      await db.insert('sessions', {'userId': user.id!});

      print('User logged in successfully: ${user.email}');
      return true;
    } catch (e) {
      print('Error during login: $e');
      // Consider more specific error handling or rethrowing if needed
      return false; // Indicate login failure for other errors
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    try {
      // Get the current user ID from the session table before deleting
      final currentUserId = await getCurrentUserId();
      if (currentUserId != null) {
        // Remove session information from the database
        final db = await _databaseHelper.database;
        await db.delete('sessions', where: 'userId = ?', whereArgs: [currentUserId]);
        print('Session for user $currentUserId deleted from database.');
      }

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
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> sessions = await db.query('sessions', limit: 1);
      if (sessions.isNotEmpty) {
        return sessions.first['userId'] as int;
      }
      // Fallback to SharedPreferences if needed (though database should be primary source)
      // final prefs = await SharedPreferences.getInstance();
      // return prefs.getInt(_loggedInUserIdKey);
      return null; // No active session found
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }
}