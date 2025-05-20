import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter_application_2/screens/support_screen.dart';
import '../currency_provider.dart';
import 'package:flutter_application_2/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // String _selectedCurrency = 'USD'; // Removed as currency is now managed by CurrencyProvider

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  /// Load the selected currency from shared preferences.
  Future<void> _loadSelectedCurrency() async {
    final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('currency') ?? 'COP';
  }

  /// Save the selected currency to shared preferences.
  Future<void> _saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance(); // Kept for saving
    await prefs.setString('currency', currency);
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                "Ajustes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSettingCard(
              title: 'Modo Oscuro',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            _buildSettingCard(
              title: 'Moneda',
              trailing: DropdownButton<String>(
                value: currencyProvider.getSelectedCurrency(),
                items: currencyProvider.supportedCurrencies.map((String currency) {
                  return DropdownMenuItem<String>( // Use the supportedCurrencies list from the currency provider
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    currencyProvider.setSelectedCurrency(newValue); // Update currency in provider
                    _saveSelectedCurrency(newValue); // Change the setCurrency method call to setSelectedCurrency
                  }
                },
              ),
            ),
            _buildSettingCard(
                title: 'Cerrar Sesión',
                leading: Icon(Icons.logout),
                onTap: () => _logout(context)),
            _buildSettingCard(
              title: 'Soporte al Usuario',
              leading: Icon(Icons.support_agent),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    Widget? trailing,
    Icon? leading,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ListTile(
          leading: leading,
          title: Text(title),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}