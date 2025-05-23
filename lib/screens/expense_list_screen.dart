import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../helpers.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  final String userId;
  const ExpenseListScreen({Key? key, required this.userId}) : super(key: key);
  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {

  Future<void> _deleteExpense(int id) async {
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

    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final userId = authService.getCurrentUserId();

    if (confirmDelete) {
      if (userId != null) {
        await firestoreService.deleteExpense(userId, id.toString()); // Assuming expense ID is String in Firestore
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully')),
      );
    }
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Sort expenses by date in descending order (latest first)
  List<Expense> _sortExpenses(List<Expense> expenses) {
    // Sort expenses by date in descending order (latest first)
    return expenses..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  }
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final userId = authService.getCurrentUserId();
    return Scaffold(
      body: StreamBuilder<List<Expense>>(
        stream: firestoreService.getExpenses(userId!),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money),
                            const SizedBox(width: 8),
                            Text('Resumen de Gastos',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
 Text('Total Gastado: ${Provider.of<CurrencyProvider>(context).getCurrencySymbol()}${Provider.of<CurrencyProvider>(context).formatAmount(Provider.of<CurrencyProvider>(context).convertAmountToSelectedCurrency(_calculateTotal(sortedExpenses)))}',
                           style: TextStyle(fontSize: 16)
                        ),
                      ],
                    ),
 ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedExpenses.length,
                    itemBuilder: (context, index) {
                      final currencyProvider = Provider.of<CurrencyProvider>(context);
                      final expense = sortedExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor:
                                  Helpers.getCategoryColor(expense.category),
                              child: Icon(
                                  Helpers.getCategoryIcon(expense.category),
                                  color: Colors.white,
                                  size: 20),
                            ),
                            title: Text(
                              expense.title,
                              style: TextStyle(
                                  fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                                  ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                  '${expense.description} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}',
                                  style: const TextStyle(fontSize: 14)),
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(expense.amount)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,

                                        fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () { if (expense.id != null) _deleteExpense(int.parse(expense.id!)); },
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ExpenseFormScreen(
                                          expense: expense, userId: widget.userId)));

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
    );
  }
}