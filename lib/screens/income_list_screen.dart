import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/models/income.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'income_form_screen.dart';

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({Key? key}) : super(key: key);

  @override
  _IncomeListScreenState createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  Future<void> _deleteIncome(BuildContext context, String incomeId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final userId = authService.getCurrentUserId();

    if (userId != null) {
      await firestoreService.deleteIncome(userId, incomeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final userId = authService.getCurrentUserId();

    return Scaffold(
      body: userId == null
          ? const Center(child: Text('User not logged in')) // Handle case where user is not logged in
          : StreamBuilder<List<Income>>(
        stream: firestoreService.getIncomes(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aún no hay ingresos registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );

          } else {
            final incomes = snapshot.data!;
            return ListView.builder(
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final income = incomes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(income.title),
                    subtitle: Text(income.description),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              '+${income.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green, // Keep green for income
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                if (income.id != null) {
                                  _deleteIncome(context, income.id!);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(income.date)),
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],

                    ),

                    // You can add onTap for editing/deleting later
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