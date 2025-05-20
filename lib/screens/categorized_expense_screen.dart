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
        title: const Text('Categorized Expenses'),
      ),
      body: FutureBuilder<Map<String, List<Expense>>>(
        future: _categorizedExpensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categorized expenses found.'));
          } else {
            final categorizedExpenses = snapshot.data!;
            final categories = categorizedExpenses.keys.toList();

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final expensesInCategory = categorizedExpenses[category]!;

                return ExpansionTile(
                  title: Text('$category (${expensesInCategory.length})'),
                  children: expensesInCategory.map((expense) {
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text('${expense.description} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))}'),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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