import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/helpers.dart';
import '../models/expense.dart';
import '../currency_provider.dart';
import '../services/database_helper.dart';

class CategorizedExpenseScreen extends StatefulWidget {
  final int userId;
  const CategorizedExpenseScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CategorizedExpenseScreen> createState() => _CategorizedExpenseScreenState();
}

class _CategorizedExpenseScreenState extends State<CategorizedExpenseScreen> {
  late Future<List<Expense>> expensesFuture;

  @override
  void initState() {
    super.initState();
    refreshExpenses();
  }

  Future<void> refreshExpenses() async {
    setState(() {
      expensesFuture = DatabaseHelper.instance.getAllExpenses(widget.userId);

    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Expense>>(
      future: expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error: An error occurred while loading expenses.'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No expenses found. Add some expenses to see the data.', textAlign: TextAlign.center,));
        }
        
        final expenses = snapshot.data!;
        Map<String, List<Expense>> categorizedExpenses =
            {}; // Map to hold categorized expenses

        // Categorize expenses
        for (var expense in expenses) {
          categorizedExpenses
              .putIfAbsent(expense.category, () => [])
              .add(expense);
        }

 return Consumer<CurrencyProvider>(
 builder: (context, currencyProvider, child) {
 return ListView(
 padding: const EdgeInsets.all(16.0),
 children: categorizedExpenses.entries.map((entry) {
 final totalAmount = entry.value.fold(0.0, (sum, expense) => sum + expense.amount);
 final convertedTotalAmount = currencyProvider.convertAmountToSelectedCurrency(totalAmount);

 return Card(
 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
 child: ExpansionTile(
 leading: CircleAvatar(
 backgroundColor: Helpers.getCategoryColor(entry.key),
 child: Icon(Helpers.getCategoryIcon(entry.key), color: Colors.white, size: 20),
 ),
 title: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
 subtitle: Text(
 'Total: ${currencyProvider.formatAmount(convertedTotalAmount)}',
 style: TextStyle(color: Theme.of(context).colorScheme.secondary),
 ),
 children: entry.value.map((expense) {
 final convertedExpenseAmount = currencyProvider.convertAmountToSelectedCurrency(expense.amount);
 return ListTile(
 contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
 title: Text(
 expense.description,
 style: const TextStyle(
 fontSize: 16,
 ),
 ),
 subtitle: Padding(
 padding: const EdgeInsets.only(top: 4.0),
 child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(expense.date))),
 ),
 trailing: Padding(
 padding: const EdgeInsets.symmetric(horizontal: 8),
 child: Text(
 currencyProvider.formatAmount(convertedExpenseAmount),
 style: const TextStyle(fontWeight: FontWeight.bold),
 ),
 ),
 );
 }).toList(),
 ),
 );
 }).toList(),
 );
 }
        );
      },
    );
  }
}