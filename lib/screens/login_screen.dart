import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Handles the login process.
  ///
  /// Validates the form and attempts to log in the user with the provided
  /// email and password. Navigates to the home screen on successful login
  /// or shows an error message on failure.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _authService
          .login(_emailController.text, _passwordController.text)
          .then((isLogged) {
        if (isLogged) {
          _navigateToHome();
        } else {
          _showErrorSnackBar('Usuario o contraseña incorrectos');
        }
      });
    } catch (e) {
      _showErrorSnackBar('Error de conexion');
      }
  }

  /// Navigates to the home screen.
  ///
  /// Uses [Navigator] to replace the current route with the [HomePage].
  void _navigateToHome() {
    Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
      );
  }

  /// Navigates to the registration screen.
  ///
  /// Pushes the [RegisterScreen] route onto the navigator, allowing the user
  /// to create a new account.
  void _navigateToRegister() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {    
    final themeProvider = Provider.of<ThemeProvider>(context);
    return  Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.appBarGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'FinScan',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Roboto', color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su correo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Roboto', color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese su contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.themeData.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                  ),
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _navigateToRegister,
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 16, decoration: TextDecoration.underline),
                    foregroundColor: Colors.white
                  ),
                  child: const Text('¿No tienes una cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

