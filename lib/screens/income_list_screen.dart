import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/income.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:intl/intl.dart';

class IncomeListScreen extends StatefulWidget {
  final int userId;

  const IncomeListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _IncomeListScreenState createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  late Future<List<Income>> _incomesFuture;

  @override
  void initState() {
    super.initState();
    _refreshIncomeList();
  }

  Future<void> _refreshIncomeList() async {
    setState(() {
      _incomesFuture = DatabaseHelper.instance.getIncomes(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Income>>(
        future: _incomesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No incomes added yet.'));
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+${income.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          income.date, // Assuming income.date is a String
                          style: const TextStyle(fontSize: 12.0, color: Colors.grey),
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