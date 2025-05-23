import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/register_screen.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/home_page.dart'; // Assuming you have a home page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final userId = await Provider.of<AuthService>(context, listen: false).getCurrentUserId();
    if (userId != null) {
      Navigator.pushReplacementNamed(context, '/home'); // Use named route if available
       // Alternatively: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }


  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final success = await authService.login(_email!, _password!);

        if (success) {
          Navigator.pushReplacementNamed(context, '/home'); // Use named route if available
          // Alternatively: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } on Exception catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${e.toString()}')),
          );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          title: const Text('Login'),
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
                    'Iniciar Sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value;
                    }
                  ),
                  const SizedBox(height: 30.0),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange, // Orange background
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 18.0, color: Colors.white), // White text
                          ),
                        ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      '¿No tienes una cuenta? Regístrate',
                      style: TextStyle(color: Colors.white), // White text
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}