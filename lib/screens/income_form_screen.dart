import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/income.dart'; // Import the Income model

class IncomeFormScreen extends StatefulWidget {
  final Income? income;
  final String? userId;

  const IncomeFormScreen({Key? key, required this.userId, this.income})
      : super(key: key);

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _titleController.text = widget.income!.title;
      _descriptionController.text = widget.income!.description;
      _amountController.text = widget.income!.amount.toString();
      // Assuming income.date is stored as a String in the Income model
      _selectedDate = DateTime.parse(widget.income!.date);
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final userId = authService.getCurrentUserId();

      if (userId == null) {
        // Handle case where user is not logged in
        return;
      }

      final newOrUpdatedIncome = Income(
        id: widget.income?.id, // Use existing id for edit, null for new
        userId: userId, // Assign the current user ID
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate).toString(), // Store date as String
      );

      if (widget.income == null) {
        // Ensure income object is non-nullable when adding
        await firestoreService.addIncome(userId, newOrUpdatedIncome);
      } else {
        // Ensure income object is non-nullable when updating
        await firestoreService.updateIncome(userId, newOrUpdatedIncome);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? 'Añadir Ingreso' : 'Editar Ingreso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
 decoration: InputDecoration(
 labelText: 'Título',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 ),
 prefixIcon: Icon(Icons.text_fields), // Added icon
 ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
 decoration: InputDecoration(
 labelText: 'Descripción',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 ),
 prefixIcon: Icon(Icons.description), // Added icon
 ),
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
 decoration: InputDecoration(
 labelText: 'Cantidad',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 ),
 prefixIcon: Icon(Icons.attach_money), // Added icon
 ),
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una cantidad';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InkWell( // Use InkWell to make it tappable and look like a form field
                onTap: () => _selectDate(context),
                child: InputDecorator( // InputDecorator to give it a form field look
                  decoration: InputDecoration(
 labelText: 'Fecha',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 ),
 prefixIcon: Icon(Icons.calendar_today), // Added icon
 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveIncome,
                child: Text(widget.income == null ? 'Save Income' : 'Update Income'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}