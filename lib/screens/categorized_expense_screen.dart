import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/expense.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:intl/intl.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  final int userId;

  const CategorizedExpenseScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CategorizedExpenseScreenState createState() => _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
  late Future<Map<String, List<Expense>>> _categorizedExpensesFuture;

  @override
  void initState() {
    super.initState();
    _categorizedExpensesFuture = _fetchAndCategorizeExpenses();
  }

  Future<Map<String, List<Expense>>> _fetchAndCategorizeExpenses() async {
    final expenses = await DatabaseHelper.instance.getExpenses(widget.userId);
    final Map<String, List<Expense>> categorizedExpenses = {};

    for (var expense in expenses) {
      if (!categorizedExpenses.containsKey(expense.category)) {
        categorizedExpenses[expense.category] = [];
      }
      categorizedExpenses[expense.category]!.add(expense);
    }

    return categorizedExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos por Categoría'),
      ),
      body: FutureBuilder<Map<String, List<Expense>>>(
        future: _categorizedExpensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron gastos por categoría.'));
          } else {
            final categorizedExpenses = snapshot.data!;
            final categories = categorizedExpenses.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final expensesInCategory = categorizedExpenses[category]!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  child: ExpansionTile(
                    title: Text(
                      '$category (${expensesInCategory.length})',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: expensesInCategory.map((expense) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // Use Expanded to prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${expense.description} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}'),
                                ],
                              ),
                            ),
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}', // Use CurrencyProvider for symbol later
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}