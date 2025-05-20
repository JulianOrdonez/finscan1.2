import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_helper.dart';
import '../helpers.dart';

class ExpenseFormScreen extends StatefulWidget {
  final int userId;
  final Expense? expense;

  const ExpenseFormScreen({Key? key, required this.userId, this.expense}) : super(key: key);

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedCategory = 'Comida'; // Default category

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.expense!.date));
      _selectedCategory = widget.expense!.category;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        id: widget.expense?.id ?? 0, // 0 for new expense, existing id for edit
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _dateController.text,
        receiptPath: '', // Placeholder for receipt path
      );

      if (widget.expense == null) {
        await DatabaseHelper.instance.insertExpense(newExpense);
      } else {
        await DatabaseHelper.instance.updateExpense(newExpense);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // AppBar title 'Add Expense' to 'Añadir Gasto' and 'Edit Expense' to 'Editar Gasto'
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'), // Label 'Title' to 'Título'
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título'; // Validation message 'Please enter a title' to 'Por favor ingresa un título'
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'), // Label 'Description' to 'Descripción'
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Cantidad'), // Label 'Amount' to 'Cantidad'
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una cantidad'; // Validation message 'Please enter an amount' to 'Por favor ingresa una cantidad'
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido'; // Validation message 'Please enter a valid number' to 'Por favor ingresa un número válido'
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría',), // Label 'Category' to 'Categoría'
                items: Helpers.expenseCategories.map((String category) { // Default category 'Comida' is already present in helpers.dart and used here.
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Fecha', // Label 'Date' to 'Fecha'
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) { // Validation message 'Please select a date' to 'Por favor selecciona una fecha'
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(widget.expense == null ? 'Guardar Gasto' : 'Actualizar Gasto'), // Button text 'Save Expense' to 'Guardar Gasto' and 'Update Expense' to 'Actualizar Gasto'
              ),
            ],
          ),
        ),
      ),
    );
  }
}