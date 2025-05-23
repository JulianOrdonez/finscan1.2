import 'database_helper.dart'; // Asegúrate de que la ruta de importación sea correcta
import 'package:flutter_application_2/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserExistsException implements Exception {
  final String message;
  UserExistsException(this.message);
}

class WeakPasswordException implements Exception {
  final String message;
  WeakPasswordException(this.message);
}
 
class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _loggedInUserIdKey = 'loggedInUserId';

  /// Inicia sesión de un usuario.
  ///
  /// Consulta la base de datos para un usuario con el email y la contraseña proporcionados.
  /// Retorna `true` y almacena el ID del usuario si el inicio de sesión es exitoso, `false` de lo contrario.
  Future<bool> login(String email, String password) async {
    try {
      final user = await _databaseHelper.getUserByEmailAndPassword(email, password);
      if (user != null) {
        // Guardar la sesión en SQLite
        final db = await _databaseHelper.database;
        await db.insert('sessions', {'userId': user.id});

        // Store the user ID in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_loggedInUserIdKey, user.id!);

        print('User ID ${user.id} stored in SharedPreferences and session.');
        return true;
      }
      return false; // User not found or password incorrect
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  /// Handles the sign-in process from the UI.
  ///
  /// Calls the internal `login` method and returns the result.
  Future<bool> signIn(String email, String password) async {
    final bool success = await login(email, password);
    // Additional logic can be added here if needed before returning the result
    return success;
  }

  /// Registra un nuevo usuario.
  ///
  /// Inserta un nuevo usuario en la base de datos. Retorna `true` si el registro
  /// es exitoso, `false` de lo contrario (por ejemplo, si el email ya existe).
  Future<bool> register(String name, String email, String password) async {
    // Verificar si ya existe un usuario con el mismo email
    final existingUser = await _databaseHelper.getUserByEmail(email);
    if (existingUser != null) throw UserExistsException('Registration failed: User with email $email already exists.');
    
    // Basic password length validation
    if (password.length < 6) {
      throw WeakPasswordException('Registration failed: Password must be at least 6 characters long.');
    }

    try {
      final newUser = User(name: name, email: email, password: password); // El ID será auto-generado por la base de datos
      final id = await _databaseHelper.insertUser(newUser);
      // Optionally, log the inserted user details if needed
      // print('Inserted user: ${newUser.toMap()}');
      return true;
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }

  /// Cierra la sesión del usuario actual.
  /// Elimina el ID de usuario almacenado en SharedPreferences y la sesión de la base de datos.
  Future<void> logout() async {
    // Remove user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserIdKey);

    // Elimina la sesión de la base de datos
    final db = await _databaseHelper.database;
    await db.delete('sessions');
  }
  /// Carga la sesión del usuario desde la base de datos.
  ///
  /// Retorna el ID del usuario si hay una sesión activa, de lo contrario retorna `null`.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loggedInUserIdKey);
  }
}