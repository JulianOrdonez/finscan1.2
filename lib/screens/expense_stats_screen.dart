import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ExpenseStatsScreen extends StatefulWidget {
  const ExpenseStatsScreen({Key? key}) : super(key: key);

  @override
  _ExpenseStatsScreenState createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {

  Map<String, double> _getExpenseDataByCategory(List<Expense> expenses) {
    Map<String, double> data = {};
    for (var expense in expenses) {
      data.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return data;
  }

  double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    final userId = authService.getCurrentUserId();

    return Scaffold( // Scaffold removed as it's part of HomePage
      appBar: AppBar(
        title: const Text('Expense Statistics'),
      ),
      body: userId == null
          ? const Center(child: Text('User not logged in.')) // Handle case where user is not logged in
          : StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses recorded yet.'));
          } else {
            final expenses = snapshot.data!;
            final totalExpenses = _calculateTotalExpenses(expenses);
            final expenseDataByCategory = _getExpenseDataByCategory(expenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [ // Translate text to Spanish
                          Text(
                            'Total Expenses:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(totalExpenses))}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gastos por Categoría:', // Translated
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200, // Adjust height as needed
                    child: PieChart(
                      PieChartData(
                        sections: expenseDataByCategory.entries.map((entry) {
                          final percentage = (entry.value / totalExpenses) * 100;
                          return PieChartSectionData(
                            color: _getColorForCategory(entry.key), // Implement a helper for colors
                            value: entry.value, // Apply color based on category
                            title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Detalle por Categoría:', // Translated
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: expenseDataByCategory.length,
                    itemBuilder: (context, index) {
                      final entry = expenseDataByCategory.entries.elementAt(index);
                      final percentage = (entry.value / totalExpenses) * 100;
                      return ListTile(
                        leading: Container(
                          width: 16,
                          height: 16,
                          color: _getColorForCategory(entry.key), // Apply color based on category
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                            '${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(entry.value))} (${percentage.toStringAsFixed(1)}%)'),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Color _getColorForCategory(String category) {
    // Implement a function to return a color based on the category
    // You can use a predefined map of categories to colors
    switch (category) {
      case 'Comida': // Translated
        return Colors.redAccent;
      case 'Transporte': // Translated
        return Colors.blueAccent;
      case 'Compras': // Translated
        return Colors.purpleAccent;
      case 'Entretenimiento': // Translated
        return Colors.orangeAccent;
      case 'Servicios': // Translated
        return Colors.greenAccent;
      case 'Salud': // Translated
        return Colors.tealAccent;
      case 'Educación': // Translated
        return Colors.cyanAccent;
      case 'Otros': // Translated
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}