import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import 'package:provider/provider.dart';
import '../currency_provider.dart';
import '../helpers.dart';

class ExpenseStatsScreen extends StatefulWidget {
  final int userId;
  const ExpenseStatsScreen({super.key, required this.userId});

  @override
  State<ExpenseStatsScreen> createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  late Future<List<Expense>> expensesFuture;
  String _selectedPeriod = 'Mes actual';
  final List<String> _periods = const [
    'Mes actual',
    'Últimos 3 meses',
    'Último año'
  ];

  @override
  void initState() {
    super.initState();
    expensesFuture = DatabaseHelper.instance.getAllExpenses(widget.userId);
  }

  // Filtrar gastos según el período seleccionado
  List<Expense> _filterByPeriod(List<Expense> expenses) {
    final now = DateTime.now();
    DateTime startDate;

    if (_selectedPeriod == 'Mes actual') {
      startDate = DateTime(now.year, now.month, 1);
    } else if (_selectedPeriod == 'Últimos 3 meses') {
      startDate = DateTime(now.year, now.month - 2, 1);
    } else {
      startDate = DateTime(now.year - 1, now.month, now.day);
    }

    return expenses
        .where((expense) => DateTime.parse(expense.date).isAfter(startDate))
        .toList();
  }

  Map<String, double> _getCategoryData(List<Expense> expenses) {
    final Map<String, double> categoryData = {};

    for (var expense in expenses) {
      categoryData[expense.category] =
          (categoryData[expense.category] ?? 0) + expense.amount;
    }

    return categoryData;
  }

  Map<DateTime, double> _getMonthlyData(List<Expense> expenses) {
    final Map<DateTime, double> monthlyData = {};

    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense.date);
      final monthDate = DateTime(expenseDate.year, expenseDate.month);
      monthlyData[monthDate] =
          (monthlyData[monthDate] ?? 0) + expense.amount;
    }

    // Ordenar por fecha
    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, double> categoryData) {
    final total = categoryData.values.fold(0.0, (sum, value) => sum + value);

    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: Helpers.getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<FlSpot> _getLineSpots(Map<DateTime, double> monthlyData) {
    final List<FlSpot> spots = [];
    final months = monthlyData.keys.toList();

    for (int i = 0; i < monthlyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyData[months[i]]!));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<Expense>>(
        future: expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No data to show. Add some expenses to see the charts.',
              textAlign: TextAlign.center,
            ));
          }

          final filteredExpenses = _filterByPeriod(snapshot.data!);
          final categoryData = _getCategoryData(filteredExpenses);
          final monthlyData = _getMonthlyData(filteredExpenses);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: textColor),
                            const SizedBox(width: 8),
                            Text('Período',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          value: _selectedPeriod,
                          items: _periods
                              .map((period) => DropdownMenuItem(
                                  value: period, child: Text(period)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money, color: textColor),
                            const SizedBox(width: 8),
                            Text('Resumen de Gastos',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                        Text(
                            'Número de transacciones: ${filteredExpenses.length}',
                            style: TextStyle(fontSize: 16, color: textColor)),
                        Text(
                          'Total Gastado: ${currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(_calculateTotal(filteredExpenses)))}',
                          style: TextStyle(fontSize: 16, color: textColor),

                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (categoryData.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pie_chart, color: textColor),
                              const SizedBox(width: 8),
                              Text('Gastos por Categoría',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(PieChartData(
                                sections: _buildPieSections(categoryData),
                                centerSpaceRadius: 40,
                                sectionsSpace: 2)),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: categoryData.entries.map((entry) {
                              final color = Helpers.getCategoryColor(entry.key);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                        width: 16, height: 16, color: color),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: Text(entry.key,
                                            style: TextStyle(color: textColor))),
                                    Text(
                                        currencyProvider.formatAmount(currencyProvider.convertAmountToSelectedCurrency(entry.value)),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (monthlyData.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.show_chart, color: textColor),
                              const SizedBox(width: 8),
                              Text('Evolución de Gastos',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget:
                                                  (value, meta) {
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        monthlyData.keys.length) {
                                                  final date = monthlyData.keys
                                                      .toList()[value.toInt()];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                        DateFormat('MM/yy')
                                                            .format(date),
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: textColor)),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                              reservedSize: 30)),
                                      leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget:
                                                  (double value, TitleMeta meta) {
                                                return Text('€${value.toInt()}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: textColor));
                                              },
                                              reservedSize: 40)),
                                      topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false))),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _getLineSpots(monthlyData),
                                      isCurved: true,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      barWidth: 4,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                          show: true,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2)),
                                    ),
                                  ]),
                            ),
                          ),
                        ],
                      ),
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