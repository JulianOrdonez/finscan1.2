import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final String? userId;
  const ExpenseListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
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
      case 'compras':
        return Colors.green;
      case 'servicios':
        return Colors.teal;
      case 'salud':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _deleteExpense(String id) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmDelete == true && widget.userId != null) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      await firestoreService.deleteExpense(widget.userId!, id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> _sortExpenses(List<Expense> expenses) {
    return expenses..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    if (widget.userId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    return Scaffold(
      body: StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(widget.userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay gastos registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final sortedExpenses = _sortExpenses(snapshot.data!);

          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.0, // Add top padding considering the notch
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure summary card stretches
              children: [
                SizedBox(height: 16.0), // Add significant space above the summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8), // Added space above summary title
                        Row(
                          children: const [
                            Icon(Icons.money),
                            SizedBox(width: 8),
                            Text('Resumen de Gastos',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Gastado: ${currencyProvider.getCurrencySymbol()}${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(_calculateTotal(sortedExpenses)))}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = sortedExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: getCategoryColor(expense.category),
                              child: Icon(getCategoryIcon(expense.category),
                                  color: Colors.white,
                                  size: 20),
                            ),
                            title: Text(
                              expense.title ?? '',
                              style: TextStyle(
                                  fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                                  ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                  '${expense.description ?? ''} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}',
                                  style: const TextStyle(fontSize: 14)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(expense.amount)),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    if (expense.id != null) {
                                      _deleteExpense(expense.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpenseFormScreen(
                                      expense: expense, userId: widget.userId),
                                   ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseFormScreen(expense: null, userId: widget.userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}