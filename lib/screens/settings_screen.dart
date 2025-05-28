import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../theme_provider.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  Future<void> generateAndSavePdf(BuildContext context) async {
    final firestoreService = FirestoreService();
    final incomes = await firestoreService.getIncomes(userId ?? '').first;
    final expenses = await firestoreService.getExpenses(userId ?? '').first;

    double totalIncome = incomes.fold(0, (sum, item) => sum + item.amount);
    double totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);

    final doc = pw.Document();

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Reporte de Gastos e Ingresos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Ingresos:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Cantidad', 'Descripción'],
              data: incomes.map((income) => [
                income.date != null
                    ? '${DateTime.parse(income.date!).day}/${DateTime.parse(income.date!).month}/${DateTime.parse(income.date!).year}'
                    : 'N/A',
                '\$${income.amount.toStringAsFixed(2)}',
                income.description ?? 'N/A',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Gastos:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Fecha', 'Cantidad', 'Categoría', 'Descripción'],
              data: expenses.map((expense) => [
                expense.date != null
                    ? '${DateTime.parse(expense.date!).day}/${DateTime.parse(expense.date!).month}/${DateTime.parse(expense.date!).year}'
                    : 'N/A',
                '\$${expense.amount.toStringAsFixed(2)}',
                expense.category ?? 'N/A',
                expense.description ?? 'N/A',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Resumen:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Total Ingresos: \$${totalIncome.toStringAsFixed(2)}'),
            pw.Text('Total Gastos: \$${totalExpense.toStringAsFixed(2)}'),
            pw.Text(
              'Balance: \$${(totalIncome - totalExpense).toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: (totalIncome - totalExpense) >= 0 ? PdfColors.green : PdfColors.red,
              ),
            ),
          ],
        );
      },
    ));

    try {
      final output = await getExternalStorageDirectory();
      final filePath = "${output!.path}/Reporte_FinScan.pdf";
      final file = File(filePath);
      await file.writeAsBytes(await doc.save());

      // Mostrar confirmación y opción para abrir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reporte guardado en $filePath"),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () => OpenFile.open(filePath),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final supportController = TextEditingController();
    String selectedCurrency = 'USD';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              'Ajustes',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      currentUser?.email ?? 'Usuario no disponible',
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.insert_chart, color: Colors.blueAccent),
              title: const Text('Guardar Reporte PDF'),
              trailing: const Icon(Icons.download),
              onTap: () => generateAndSavePdf(context),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
