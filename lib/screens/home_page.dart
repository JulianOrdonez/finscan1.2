import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/theme_provider.dart';
import 'package:flutter_application_2/services/auth_service.dart'; // Import AuthService
import 'categorized_expense_screen.dart';
import 'expense_form_screen.dart';
import 'income_form_screen.dart';
import 'income_list_screen.dart';
import 'package:flutter_application_2/screens/expense_list_screen.dart';
import 'package:flutter_application_2/screens/expense_stats_screen.dart';
import 'package:flutter_application_2/screens/settings_screen.dart';
import 'login_screen.dart'; // Assuming LoginScreen is needed for redirection

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
    // Use AuthService to get the current user ID, which now reads from the database session table.
    final userId = await AuthService().getCurrentUserId(); 
    
    // No need to await this setState, as it's synchronous.
    setState(() {
      _userId = userId;
      if (_userId != null) {
        _screens = [
          ExpenseListScreen(userId: _userId!),
          IncomeListScreen(userId: _userId!),
          ExpenseStatsScreen(userId: _userId!),
          CategorizedExpenseScreen(userId: _userId!),
          SettingsScreen(userId: _userId!),
        ];
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                title: Text(
                  'Añadir Gasto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpenseFormScreen(userId: _userId!),
                    ),
                  ).then((_) {
                    if (_selectedIndex == 0) {
                      _loadUserId(); // Refresh expense list if currently on that tab
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                title: Text(
                  'Añadir Ingreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                     color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IncomeFormScreen(userId: _userId!),
                    ),
                  ).then((_) {
                    if (_selectedIndex == 1) {
                      _loadUserId(); // Refresh income list if currently on that tab
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to wait for _loadUserId to complete
    // The FutureBuilder needs to await the result of _loadUserId to determine
    // whether to show the loading indicator, the home content, or the login screen.
    return FutureBuilder<int?>( // Specify the return type of the future
      future: _loadUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ); // Show loading indicator while waiting
        } else if (snapshot.hasData && snapshot.data != null) {
          // If the future completed successfully and _userId is not null,
          // display the home page content.
        } else if (snapshot.hasError || _userId == null) {
          // If there's an error or _userId is still null after loading,
          // navigate to the LoginScreen.
          // Using a post-frame callback to avoid issues with
          // Navigator.push during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
          return const SizedBox.shrink(); // Return an empty widget while navigating
        } else {
          // Once _userId is loaded and not null, display the home page content
          // If _userId is loaded successfully, display the home page content
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
                        themeProvider.themeData.colorScheme.primaryContainer,
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
                  BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Gastos'),
                  BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Ingresos'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.category), label: 'Categorías'),
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
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddOptions(context),
                tooltip: 'Agregar', // Already translated
                child: const Icon(Icons.add),
              ),
            );
          });
        }
      },
    );
  }
}