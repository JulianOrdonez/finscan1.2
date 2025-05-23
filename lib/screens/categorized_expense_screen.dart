import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class CategorizedExpenseScreen extends StatelessWidget {
  final String? userId;
  final String category;

  const CategorizedExpenseScreen({Key? key, required this.userId, required this.category}) : super(key: key);

  // Basic category icon mapping (can be expanded)
  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Icons.fastfood;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.movie;
      case 'compras':
        return Icons.shopping_bag;
      case 'servicios':
        return Icons.electrical_services;
      case 'salud':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }

  // Basic category color mapping (can be expanded)
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'comida':
        return Colors.orange;
      case 'transporte':
        return Colors.blue;
      case 'entretenimiento':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.getCurrentUserId();

    if (currentUserId == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Expenses'),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No expenses found in this category.'),
            );
          }

          final filteredExpenses = snapshot.data!.where((expense) => expense.category == category).toList();

          if (filteredExpenses.isEmpty) {
            return const Center(
              child: Text('No expenses found in this category.'),
            );
          }

          return ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              final currencyProvider = Provider.of<CurrencyProvider>(context);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getCategoryColor(expense.category),
                      child: Icon(getCategoryIcon(expense.category), color: Colors.white, size: 20),
                    ),
                    title: Text(
                      expense.title ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text('${expense.description ?? ''} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}'),
                    trailing: Text(
                      currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(expense.amount)),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    // onTap: () {
                    //   // Implement navigation to edit expense if needed
                    // },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}