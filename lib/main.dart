import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/user.dart';
import 'package:flutter_application_2/screens/home_page.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:flutter_application_2/currency_provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      create: (context) => ThemeProvider(),
      child: ChangeNotifierProvider<CurrencyProvider>(
        create: (context) => CurrencyProvider(),
        child: MyApp(),
      ),
    )
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
              future: DatabaseHelper.instance.getCurrentUserId().then((userId) async {
                if (userId != null) {
                  return await DatabaseHelper.instance.getUserById(userId);
                }
                return null;
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  final user = snapshot.data;
                  if (user != null) {
                    return const HomePage();
                  } else {
                    return LoginScreen();
                  }
                }
              }),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
