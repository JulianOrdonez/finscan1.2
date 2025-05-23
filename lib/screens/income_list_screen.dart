import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../models/income.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'income_form_screen.dart';

class IncomeListScreen extends StatefulWidget {
  final String? userId;
  const IncomeListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  Future<void> _deleteIncome(String id) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este ingreso?'),
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

    if (confirmDelete == true) {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      if (widget.userId != null) {
        await firestoreService.deleteIncome(widget.userId!, id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingreso eliminado exitosamente')),
        );
      }
    }
  }

  double _calculateTotal(List<Income> incomes) {
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  // Sort incomes by date in descending order (latest first)
  List<Income> _sortIncomes(List<Income> incomes) {
    return incomes..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final authService = Provider.of<AuthService>(context);
    final userId = authService.getCurrentUserId();

    if (userId == null) {
      return const Center(child: Text('Usuario no autenticado.'));
    }

    return Scaffold(
      body: StreamBuilder<List<Income>>(
        stream: firestoreService.getIncomes(userId),
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
                  'No hay ingresos registrados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          final sortedIncomes = _sortIncomes(snapshot.data!);

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
                            Icon(Icons.attach_money),
                            const SizedBox(width: 8),
                             Text('Resumen de Ingresos',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                         Text('Total Ingresado: ${Provider.of<CurrencyProvider>(context).getCurrencySymbol()}${Provider.of<CurrencyProvider>(context).formatAmount(Provider.of<CurrencyProvider>(context).convertAmountToSelectedCurrency(_calculateTotal(sortedIncomes)))}',
                           style: TextStyle(fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedIncomes.length,
                    itemBuilder: (context, index) {
                       final currencyProvider = Provider.of<CurrencyProvider>(context);
                      final income = sortedIncomes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                           padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.green, // Default color for income
                              child: Icon(Icons.monetization_on,
                                  color: Colors.white, size: 20), // Default icon for income
                            ),
                            title: Text(
                              income.title,
                              style: TextStyle(fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${income.description} - ${DateFormat('dd/MM/yyyy').format(DateTime.parse(income.date))}',
                                style: const TextStyle(fontSize: 14)),
                            ),
                            trailing: Row(
                               mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(income.amount)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    if (income.id != null) {
                                      _deleteIncome(income.id!);
                                    }
                                  },
                                ),
                              ],
                            ),
                             onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => IncomeFormScreen(
                                          income: income, userId: widget.userId)));
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