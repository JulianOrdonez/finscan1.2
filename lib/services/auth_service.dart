import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/models/user.dart';

class AuthService {
  static Future<int?> getCurrentUserId() async {
    return await DatabaseHelper.instance.getCurrentUserId();
  }

  Future<bool> login(String email, String password) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final users = await db.query('users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, password]);
      if (users.isNotEmpty) {
        final user = User.fromMap(users.first);
        await DatabaseHelper.instance.setCurrentUser(user.id);
        return true;
      }
      return false;
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    }
  }

  Future<bool> createUser(User user) async {
    try {
      final id = await DatabaseHelper.instance.insertUser(user);
      if (id > 0) {
        user.id = id;
        await DatabaseHelper.instance.setCurrentUser(user.id);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await DatabaseHelper.instance.clearCurrentUser();
    } catch (e) {
      rethrow;
    }
  }
}