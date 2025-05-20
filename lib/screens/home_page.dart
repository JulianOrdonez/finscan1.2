import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/expense_stats_screen.dart';
import 'package:flutter_application_2/screens/settings_screen.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'categorized_expense_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int? _userId;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await DatabaseHelper.instance.getCurrentUserId();
    setState(() {
      _userId = userId;
      if (_userId != null) {
        _screens = [
          ExpenseListScreen(userId: _userId!),
          ExpenseStatsScreen(userId: _userId!),
          CategorizedExpenseScreen(userId: _userId!),
          const SettingsScreen(),
        ];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const LoginScreen();
    }
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('FinScan'),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.themeData.colorScheme.primary,
                  themeProvider.themeData.colorScheme.primaryContainer
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: Center(
            key: ValueKey<int>(_selectedIndex),
            child: _screens[_selectedIndex],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.list), label:  'Gastos'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label:  'Estadísticas'),
            BottomNavigationBarItem(
                icon: Icon(Icons.category), label:  'Categorías'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Ajustes'),
            ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF64B5F6),
          unselectedItemColor: themeProvider.themeData.unselectedWidgetColor,
          onTap: _onItemTapped,
          backgroundColor: themeProvider.themeData.cardColor,
          selectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto'),
          type: BottomNavigationBarType.fixed,

        ),
      );
    });
  }
}