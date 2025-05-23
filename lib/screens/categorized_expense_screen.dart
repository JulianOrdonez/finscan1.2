import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
class CategorizedExpenseScreen extends StatefulWidget {
  // Assuming userId is needed for fetching categorized expenses
  final String? userId;

  const CategorizedExpenseScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _CategorizedExpenseScreenState createState() =>
      _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Comida':
        return Colors.deepOrange;
      case 'Transporte':
        return Colors.blueAccent;
      case 'Entretenimiento':
        return Colors.purpleAccent;
      default:
        return Colors.grey; // Default color
    }
  }
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Comida':
        return Icons.fastfood;
      case 'Transporte':
        return Icons.directions_car;
      case 'Entretenimiento':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos por Categoría'),
      ),
      body: StreamBuilder<List<Expense>>(
 stream: widget.userId != null
 ? firestoreService.getExpenses(widget.userId!)
 : Stream.empty(),
 builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
 child: Text('No se encontraron gastos categorizados.')
 );
          } else {
 final expenses = snapshot.data!;
            final Map<String, List<Expense>> categorizedExpenses = {};
 
            for (var expense in expenses) {
 if (!categorizedExpenses.containsKey(expense.category)) {
 categorizedExpenses[expense.category] = [];
 }
 categorizedExpenses[expense.category]!.add(expense);
            }
            final categories = categorizedExpenses.keys.toList();
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final expensesInCategory = categorizedExpenses[category]!;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  elevation: 2.0,
                  child: ExpansionTile(// Placeholder
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(category),
                      child: Icon(// Placeholder
                        _getCategoryIcon(category),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '$category (${expensesInCategory.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: expensesInCategory.map((expense) {
                      return ListTile(
                        title: Text(expense.title ?? ''), // Handle null title
                        subtitle: Text(
                            '${expense.description} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}'),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          }
        },
      ),
 );
  }
}