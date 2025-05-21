import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart'; // Asegúrate de que la ruta de importación sea correcta
import 'package:flutter_application_2/models/user.dart';

/// Servicio para manejar la autenticación de usuarios.
class AuthService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const String _loggedInUserIdKey = 'loggedInUserId';

  /// Inicia sesión de un usuario.
  ///
  /// Consulta la base de datos para un usuario con el email y la contraseña proporcionados.
  /// Retorna `true` y almacena el ID del usuario si el inicio de sesión es exitoso, `false` de lo contrario.
  Future<bool> login(String email, String password) async {
    final user = await _databaseHelper.getUserByEmailAndPassword(email, password);
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_loggedInUserIdKey, user.id!); // Usamos user.id! porque user no es nulo aquí
      return true;
    }
    return false;
  }

  /// Registra un nuevo usuario.
  ///
  /// Inserta un nuevo usuario en la base de datos. Retorna `true` si el registro
  /// es exitoso, `false` de lo contrario (por ejemplo, si el email ya existe).
  Future<bool> register(String name, String email, String password) async {
    // Verificar si ya existe un usuario con el mismo email
    final existingUser = await _databaseHelper.getUserByEmail(email);
    if (existingUser != null) {
      return false; // Ya existe un usuario con este email
    }

    try {
      final newUser = User(name: name, email: email, password: password); // El ID será auto-generado por la base de datos
      await _databaseHelper.insertUser(newUser);
      return true;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return false;
    }
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Elimina el ID de usuario almacenado en SharedPreferences.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserIdKey);
  }

  /// Obtiene el ID del usuario actualmente conectado.
  ///
  /// Retorna el ID del usuario si hay un usuario conectado, de lo contrario retorna `null`.
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_loggedInUserIdKey);
  }
}