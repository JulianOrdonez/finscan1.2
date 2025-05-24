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
      final authService =
          Provider.of<AuthService>(context, listen: false);
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

      if (widget.expense == null) { // Correct comparison
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
        title: Text(widget.expense == null ? 'Agregar Gasto' : 'Editar Gasto'),
 ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,

          child: ListView(
            children: <Widget>[
              _buildTextFormField(_titleController, 'Título', 'Por favor ingresa un título'),
              SizedBox(height: 16.0),
              _buildTextFormField(_descriptionController, 'Descripción', '', maxLines: 3),
              SizedBox(height: 16.0),
              _buildAmountTextFormField(_amountController),
              SizedBox(height: 16.0),
              _buildCategoryDropdown(),
              SizedBox(height: 16.0),
              _buildDateFormField(),
              SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                onPressed: _saveExpense,
                child: Text(widget.expense == null ? 'Guardar Gasto' : 'Actualizar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller,
      String labelText, String? validationMessage,
      {int? maxLines}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // More rounded corners
 borderSide: BorderSide(
 color: Colors.blueAccent, // Added border color

 ),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
      validator: (value) {
        if (validationMessage != null && (value == null || value.isEmpty)) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildAmountTextFormField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Monto',
        border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(12.0),
 borderSide: BorderSide(
 color: Colors.blueAccent,
 ),
 ), // Added border color
                  filled: true,
                  fillColor: Colors.grey[200],
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un monto';
        }
        if (double.tryParse(value) == null) {
          return 'Por favor ingresa un número válido';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
 color: Colors.blueAccent,
 ),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      items: expenseCategories.map((String category) {
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
    );
  }

  Widget _buildDateFormField() {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Fecha',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
 color: Colors.blueAccent,
 ),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _selectDate(context), validator: (value) {
 if (value == null || value.isEmpty) {
 return 'Por favor selecciona una fecha'; // Changed error message to Spanish
                  }
                  return null;
                },
              ),
    );
  }
}
