import '../models/user.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _loggedInUserIdKey = 'loggedInUserId';

  /// Logs in a user.
  ///
  /// Queries the database for a user with the provided email and password.
  /// Returns `true` and stores the user ID if login is successful, `false` otherwise.
  Future<bool> login(String email, String password) async {
    final user = await _databaseHelper.getUserByEmailAndPassword(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_loggedInUserIdKey, user.id);
      return true;
    }
    return false;
  }

  /// Registers a new user.
  ///
  /// Inserts a new user into the database. Returns `true` if registration
  /// is successful, `false` otherwise.
  Future<bool> register(String name, String email, String password) async {
    // Check if user with the same email already exists
    final existingUser = await _databaseHelper.getUserByEmail(email);
    if (existingUser != null) {
      return false; // User with this email already exists
    }

    try {
      final newUser = User(id: 0, name: name, email: email, password: password); // ID will be auto-generated
      await _databaseHelper.insertUser(newUser);
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  /// Logs out the current user.
  ///
  /// Clears the stored user ID from shared preferences.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserIdKey);
  }

  /// Gets the currently logged-in user ID.
  ///
  /// Returns the user ID if a user is logged in, otherwise returns `null`.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loggedInUserIdKey);
  }
}