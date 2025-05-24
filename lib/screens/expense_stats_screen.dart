import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart'; // Import rxdart to combine streams
import '../currency_provider.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class ExpenseStatsScreen extends StatefulWidget {
  final String? userId;
  const ExpenseStatsScreen({Key? key, required this.userId}) : super(key: key);

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

  Map<String, double> _getIncomeDataByCategory(List<Income> incomes) {
    Map<String, double> data = {};
    for (var income in incomes) {
      data.update(income.title, (value) => value + income.amount,
          ifAbsent: () => income.amount);
    }
    return data;
  }

  double _calculateTotalIncome(List<Income> incomes) {
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  double _calculateBalance(double totalIncome, double totalExpenses) {
    return totalIncome - totalExpenses;
  }

  Color _getColorForCategory(String category) {
    // Implement a function to return a color based on the category
    // You can use a predefined map of categories to colors
    switch (category) {
      case 'Comida':
        return Colors.redAccent;
      case 'Transporte':
        return Colors.blueAccent;
      case 'Compras':
        return Colors.purpleAccent;
      case 'Entretenimiento':
        return Colors.orangeAccent;
      case 'Servicios':
        return Colors.greenAccent;
      case 'Salud':
        return Colors.tealAccent;
      case 'Educación':
        return Colors.cyanAccent;
      case 'Otros':
        return Colors.grey;
      case 'Salario': // New income category
        return Colors.lightGreen;
      case 'Inversiones': // New income category
        return Colors.blueGrey;
      case 'Regalos': // New income category
        return Colors.pinkAccent;
      // Add more cases for other categories (both expense and income)
      default:
        return Colors.blueGrey;
    }
  }


  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    final userId = widget.userId;

    if (userId == null) {
      return const Center(child: Text('Usuario no autenticado.'));
    }

    return StreamBuilder<List<Expense>>(
      stream: firestoreService.getExpenses(userId),
      builder: (context, expenseSnapshot) {
        if (expenseSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (expenseSnapshot.hasError) {
          return Center(child: Text('Error al cargar gastos: ${expenseSnapshot.error}'));
        }

        final expenses = expenseSnapshot.data ?? [];
        final totalExpenses = _calculateTotalExpenses(expenses);
        final expenseDataByCategory = _getExpenseDataByCategory(expenses);

        return StreamBuilder<List<Income>>(
          stream: firestoreService.getIncomes(userId),
          builder: (context, incomeSnapshot) {
            if (incomeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (incomeSnapshot.hasError) {
              return Center(child: Text('Error al cargar ingresos: ${incomeSnapshot.error}'));
            }

            final incomes = incomeSnapshot.data ?? [];
            final totalIncome = _calculateTotalIncome(incomes);
            final incomeDataByCategory = _getIncomeDataByCategory(incomes);
            final balance = _calculateBalance(totalIncome, totalExpenses);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Balance Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance General:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(balance))}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.green : Colors.red), // Color based on balance
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Total Expenses Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Gastos:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(totalExpenses))}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent), // Color for expenses
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Expense Pie Chart
                  Text(
                    'Gastos por Categoría:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  expenseDataByCategory.isEmpty
                      ? const Center(child: Text('No hay datos de gastos por categoría.'))
                      : Container(
                    height: 250, // Adjusted height
                    child: PieChart(
                      PieChartData(
                        sections: expenseDataByCategory.entries.map((entry) {
                          final percentage = (entry.value / totalExpenses) * 100;
                          return PieChartSectionData(
                            color: _getColorForCategory(entry.key), // Apply color based on category
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 80, // Increased radius
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            badgeWidget: _buildCategoryBadge(entry.key, entry.value, currencyProvider), // Add badge for category name and amount
                            badgePositionPercentageOffset: 1.2, // Adjust badge position
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 60, // Increased center space
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Expense Details List
                  Text(
                    'Detalle de Gastos por Categoría:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  expenseDataByCategory.isEmpty
                      ? const Center(child: Text('No hay detalles de gastos por categoría.'))
                      : ListView.builder(
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
                  const SizedBox(height: 24),

                  // Total Income Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Ingresos:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(totalIncome))}',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent), // Color for income
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Income Pie Chart
                  Text(
                    'Ingresos por Categoría:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  incomeDataByCategory.isEmpty
                      ? const Center(child: Text('No hay datos de ingresos por categoría.'))
                      : Container(
                    height: 250, // Adjusted height
                    child: PieChart(
                      PieChartData(
                        sections: incomeDataByCategory.entries.map((entry) {
                          final percentage = (entry.value / totalIncome) * 100;
                          return PieChartSectionData(
                            color: _getColorForCategory(entry.key), // Reuse color function or create a new one for income categories
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                             radius: 80, // Increased radius
                            titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                             badgeWidget: _buildCategoryBadge(entry.key, entry.value, currencyProvider), // Add badge for category name and amount
                             badgePositionPercentageOffset: 1.2, // Adjust badge position
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 60, // Increased center space
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Income Details List
                  Text(
                    'Detalle de Ingresos por Categoría:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  incomeDataByCategory.isEmpty
                      ? const Center(child: Text('No hay detalles de ingresos por categoría.'))
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: incomeDataByCategory.length,
                    itemBuilder: (context, index) {
                      final entry = incomeDataByCategory.entries.elementAt(index);
                      final percentage = (entry.value / totalIncome) * 100;
                      return ListTile(
                        leading: Container(
                          width: 16,
                          height: 16,
                          color: _getColorForCategory(entry.key), // Reuse color function or create a new one for income categories
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
          },
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category, double amount, CurrencyProvider currencyProvider) {
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '${category}: ${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(amount))}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}