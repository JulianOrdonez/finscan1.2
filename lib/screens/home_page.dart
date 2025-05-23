import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'expense_list_screen.dart';
import 'income_list_screen.dart';
import 'settings_screen.dart';
import 'expense_stats_screen.dart'; // Assuming this is another screen you want in the bottom nav

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  String? _userId;

  @override
  void initState() {
    print('HomePage initState called');
    super.initState();
    // Initialize screens here, potentially after getting the userId
    _initializeScreens();
  }

  void _initializeScreens() {
    final authService = Provider.of<AuthService>(context, listen: false);
    _userId = authService.getCurrentUserId();
    print('HomePage _initializeScreens userId: $_userId');

    if (_userId != null) {
      _screens = <Widget>[
        ExpenseListScreen(userId: _userId!),
        IncomeListScreen(userId: _userId!),
        ExpenseStatsScreen(userId: _userId!), // Assuming ExpenseStatsScreen also takes userId
        SettingsScreen(userId: _userId!),
      ];
    } else {
      // Handle case where userId is null, maybe navigate to login or show a loading indicator
      _screens = <Widget>[
        const Center(child: Text('User not logged in')),
        const Center(child: Text('User not logged in')),
        const Center(child: Text('User not logged in')),
        const Center(child: Text('User not logged in')),
      ];
      // Consider adding a listener or navigating to login if userId becomes null
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Re-initialize screens in build if userId could change dynamically
    // Or handle userId change with a listener or FutureBuilder if asynchronous
    // For simplicity, assuming userId is constant after initState for this example.
    // If userId can change, you might need a Consumer or FutureBuilder here.

    return Scaffold(
      body: Center(
        child: _screens.isNotEmpty ? _screens.elementAt(_selectedIndex) : const CircularProgressIndicator(), // Show loading or handle empty screens
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Ingresos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}