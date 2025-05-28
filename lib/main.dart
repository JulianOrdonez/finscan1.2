import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/screens/support_screen.dart';
import 'package:flutter_application_2/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Importa firebase_core
import 'package:flutter_application_2/services/firestore_service.dart'; // Import FirestoreService
import 'package:firebase_auth/firebase_auth.dart'; // Import for Firebase User type
import 'firebase_options.dart'; // Importa firebase_options.dart

void main() async { // main ahora es async
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los widgets estén inicializados
  await Firebase.initializeApp( // Inicializa Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await DatabaseHelper.instance.clearDatabase(); // FOR DEBUGGING ONLY - REMOVE LATER
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<CurrencyProvider>(
          create: (context) => CurrencyProvider(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FinScan - Gastos',
          theme: themeProvider.themeData,
          routes: {
            '/register': (context) => RegisterScreen(),
            '/home': (context) => HomePage(),
            '/support': (context) => SupportScreen(),
          }, // Removed trailing comma
          home: StreamBuilder<User?>( // Use Firebase User type
            stream: Provider.of<AuthService>(context).authStateChanges,
            builder: (context, snapshot) {
              print('Auth state changed. Snapshot data: ${snapshot.data}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
              } else {
                // If there is data, it means a user is logged in
                if (snapshot.hasData) {
                  return const HomePage(); // User is logged in, show home page
                } else {
                  return LoginScreen(); // User is not logged in, show login page
                }
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
