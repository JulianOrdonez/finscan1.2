import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/services/auth_service.dart';
import 'package:flutter_application_2/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider<CurrencyProvider>(
          create: (context) => CurrencyProvider(),
        ),
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
          home: FutureBuilder<User?>(
            future: (() async {
              await Future.delayed(Duration(milliseconds: 500)); // Add a small delay
              final userId = await AuthService().getCurrentUserId();
              print('Retrieved userId: $userId');
              if (userId != null) {
                return await DatabaseHelper.instance.getUserById(userId);
              }
              return null;
            })(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                print('User snapshot data: ${snapshot.data}');
                final user = snapshot.data;
                if (user != null) {
                  return const HomePage();
                } else {
                  return LoginScreen();
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