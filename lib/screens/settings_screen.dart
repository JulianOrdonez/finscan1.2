//Hasta aqui melo
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
import 'support_screen.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final supportController = TextEditingController();

  Future<void> generateAndSavePdf(BuildContext context) async {
    final firestoreService = FirestoreService();
    final incomes = await firestoreService.getIncomes(widget.userId ?? '').first;
    final expenses = await firestoreService.getExpenses(widget.userId ?? '').first;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(currentUser?.email ?? 'Usuario no disponible'),
              ),
            ),
            const SizedBox(height: 20),

            // Cambiar moneda
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on),
                title: const Text("Moneda"),
                trailing: const Text(
                'USD',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            // Dark Mode Switch
            Card(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Modo Oscuro'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Generar reporte
            Card(
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.blueAccent),
                title: const Text('Generar Reporte (PDF)'),
                trailing: const Icon(Icons.download),
                onTap: () => generateAndSavePdf(context),
              ),
            ),

            const SizedBox(height: 10),

            // Soporte
           ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportScreen()),
                );
              },
              child: const Text('Ir a Soporte'),
            ),

             const SizedBox(height: 20),

            // Cerrar sesión
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                await AuthService().signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
