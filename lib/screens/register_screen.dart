import 'package:flutter/material.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        // Show success message
        const SnackBar(content: Text('Registration successful! Welcome!')),
      );

      // Navigation to /home is handled by the auth state listener in main.dart
      // The StreamBuilder will detect the authenticated user and navigate.

    } on Exception catch (e) { // Catch specific Firebase Auth exceptions
      String errorMessage = 'Registration failed. Please try again.\n${e.message}'; // Default error message
      if (e.code == 'email-already-in-use') {
        errorMessage = 'The email address is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }
      // Handle other potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        // Handle other potential errors
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF42A5F5), // A shade of blue
            Color(0xFF90CAF9), // A lighter shade of blue
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Register'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Registrarse', // Changed title text
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration( // Use InputDecoration
                      hintText: 'Nombre Completo', // Updated hint text
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.blue), // Consistent icon
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), // Consistent fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // Consistent border radius
                        borderSide: BorderSide.none, // No border line
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre'; // Updated validation message
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration( // Use InputDecoration
                      hintText: 'Email', // Consistent hint text
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.blue), // Consistent icon
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), // Consistent fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // Consistent border radius
                        borderSide: BorderSide.none, // No border line
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email'; // Updated validation message
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor, ingresa un email válido'; // Updated validation message
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration( // Use InputDecoration
                      hintText: 'Contraseña', // Consistent hint text
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue), // Consistent icon
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8), // Consistent fill color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0), // Consistent border radius
                        borderSide: BorderSide.none, // No border line
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña'; // Updated validation message
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres'; // Updated validation message
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Orange background
                            padding: const EdgeInsets.symmetric(vertical: 15.0), // Consistent padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0), // Consistent border radius
                            ),
                          ),
                          child: const Text(
                            'Registrarse', // Changed button text
                            style: TextStyle(fontSize: 18.0, color: Colors.white), // White text
                          ),
                        ),
                  const SizedBox(height: 20.0),
                  // Removed the "Please remember your password" text as it's not in LoginScreen
                  TextButton(
                    onPressed: () {
                      // Navigate back to the login screen using the named route
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (Route<dynamic> route) => false);
                    },
                    child: const Text(
                      '¿Ya tienes una cuenta? Iniciar Sesión', // Changed text
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}