import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/database_helper.dart';

class ReportService {
  Future<Uint8List> generateReport(int userId) async {
    final DatabaseHelper _dbHelper = DatabaseHelper.instance;

    // Fetch data
    List<Expense> expenses = await _dbHelper.getExpenses(userId);
    List<Income> incomes = await _dbHelper.getIncomes(userId);

    // Calculate statistics
    double totalIncome =
        incomes.fold(0.0, (sum, income) => sum + income.amount);
    double totalExpense =
        expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    double balance = totalIncome - totalExpense;

    // Group expenses by category for potential breakdown in report
    Map<String, double> expensesByCategory = {};
    for (var expense in expenses) {
      expensesByCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Financial Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Summary',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Total Income: \$${totalIncome.toStringAsFixed(2)}'),
              pw.Text('Total Expense: \$${totalExpense.toStringAsFixed(2)}'),
              pw.Text('Balance: \$${balance.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      color: balance >= 0 ? PdfColors.green : PdfColors.red)),
              pw.SizedBox(height: 20),
              pw.Text('Income Details',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: incomes.length,
                itemBuilder: (context, index) {
                  final income = incomes[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(income.title),
                      pw.Text('\$${income.amount.toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text('Expense Details',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(expense.title),
                      pw.Text('-\$${expense.amount.toStringAsFixed(2)}'),
                    ],
                  );
                },
              ),
              pw.SizedBox(height: 20),
              pw.Text('Recommendations',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              // Add some basic recommendations based on the balance
              if (balance < 0)
                pw.Text(
                    'Recommendation: Your expenses exceed your income. Consider reviewing your spending habits.'),
              if (totalExpense > totalIncome * 0.8 && balance >= 0)
                pw.Text(
                    'Recommendation: Your expenses are high relative to your income. Look for areas to save.'),
              if (balance >= 0 && totalExpense < totalIncome * 0.5)
                pw.Text(
                    'Recommendation: You are managing your finances well! Keep up the good work and consider saving or investing.'),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}