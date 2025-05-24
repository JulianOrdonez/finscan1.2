import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
 
class ExpenseFormScreen extends StatefulWidget {
  final String? userId;
  final Expense? expense;

  const ExpenseFormScreen({Key? key, required this.userId, this.expense}) : super(key: key);

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<String> expenseCategories = const [
    'Comida',
    'Transporte',
    'Compras',
    'Entretenimiento',
    'Servicios',
    'Salud',
    'Educación',
    'Otros',
  ];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _selectedCategory = 'Comida'; // Default category

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title ?? '';
      _descriptionController.text = widget.expense!.description ?? ''; // Handle null
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
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final String? userId = authService.getCurrentUserId(); // Correct way to get Firebase user ID
 if (userId == null) {
        // Handle case where user is not logged in (should not happen with current flow)
        return;
      }
      final newExpense = Expense(
        id: widget.expense?.id, // Use existing ID for updates
        userId: userId, // Pass the Firebase user ID (String)
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _dateController.text,
        category: _selectedCategory,
      );

      if (widget.expense == null) {
        // Add new expense to Firestoreß
        await firestoreService.addExpense(userId, newExpense);
      } else {
        // Update existing expense in Firestore
        await firestoreService.updateExpense(userId, newExpense);
      }
      Navigator.of(context).pop();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
 decoration: const InputDecoration(
 labelText: 'Title',
 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
 ),
                validator: (value) { // Existing validator
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
 decoration: const InputDecoration(
 labelText: 'Description',
 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
 ),
              ),
              TextFormField(
                controller: _amountController,
 decoration: const InputDecoration(
 labelText: 'Amount',
 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
 ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
 decoration: const InputDecoration(
 labelText: 'Category',
 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
 ),
                items: expenseCategories.map((String category) { // Use the defined list
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
                  labelText: 'Date',
 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveExpense,
                child: Text(widget.expense == null ? 'Save Expense' : 'Update Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}