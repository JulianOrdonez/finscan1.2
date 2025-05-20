import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../services/database_helper.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'package:flutter_application_2/screens/login_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter_application_2/screens/support_screen.dart';
import '../currency_provider.dart';
import 'package:flutter_application_2/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('currency') ?? 'COP';
    currencyProvider.setSelectedCurrency(savedCurrency);
  }

  Future<void> _saveSelectedCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  Future<void> _generateAndShareReport(BuildContext context) async {
    final userId = widget.userId;

    final status = await Permission.storage.request();
    if (status.isGranted) {
      final expenses = await DatabaseHelper.instance.getExpenses(userId);
      final incomes = await DatabaseHelper.instance.getIncomes(userId);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Financial Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Expenses:',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              '${expense.title} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}'),
                          pw.Text(
                              '-${expense.amount.toStringAsFixed(2)} ${Provider.of<CurrencyProvider>(this.context).getCurrencySymbol()}'),
                        ],
                      ),
                    );
                  },
                ),
                pw.SizedBox(height: 20),
                pw.Text('Incomes:',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.ListView.builder(
                  itemCount: incomes.length,
                  itemBuilder: (context, index) {
                    final income = incomes[index];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                              '${income.title} - ${DateFormat('dd/MM/yyyy').format(income.date)}'),
                          pw.Text(
                              '+${income.amount.toStringAsFixed(2)} ${Provider.of<CurrencyProvider>(this.context).getCurrencySymbol()}'),
                        ],
                      ),
                    );
                  },
                ),
                // You can add total calculations and other summaries here
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/finscan_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], text: 'Here is your FinScan financial report.');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission not granted')),
      );
    }
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
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    currencyProvider.setSelectedCurrency(newValue);
                    _saveSelectedCurrency(newValue);
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
            _buildSettingCard(
              title: 'Generar Reporte',
              leading: Icon(Icons.receipt),
              onTap: () => _generateAndShareReport(context),
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