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
    } else if (picked == null) {
      // Animation if date picker is dismissed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selección de fecha cancelada'),
        ),
      );
    }
  }

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firestoreService =
          Provider.of<FirestoreService>(context, listen: false);
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
        date: DateFormat('yyyy-MM-dd')
            .format(_selectedDate)
            .toString(), // Store date as String
      );

      if (widget.income == null) {
        await firestoreService.addIncome(userId, newOrUpdatedIncome);
      } else {
        await firestoreService.updateIncome(userId, newOrUpdatedIncome);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingreso actualizado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
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
 decoration: InputDecoration(
 labelText: 'Título',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Colors.blueAccent.shade100),
                  ),
 focusedBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
 ),
 contentPadding:
 const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0), // Adjusted padding
                ),
 validator: (value) {
 if (value == null || value.isEmpty) {
 return 'Por favor ingresa un título';
                  }
 return null;
                },
              ),
 SizedBox(height: 20.0),
 TextFormField(
 controller: _descriptionController,
 maxLines: 3,
 decoration: InputDecoration(
 labelText: 'Descripción',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
                  ),
 focusedBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                  ),
 contentPadding:
 const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                ),
              ),
 SizedBox(height: 20.0),
 TextFormField(
 controller: _amountController,
 decoration: InputDecoration(
 labelText: 'Cantidad',
 border: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Colors.blueAccent.shade100),
 ),
 focusedBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                  ),
 contentPadding:
 const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                ),
 keyboardType: TextInputType.number,
 validator: (value) {
 if (value == null || value.isEmpty) {
 return 'Por favor ingresa una cantidad';
 }
 return null;
                },
              ),
 SizedBox(height: 20.0),
              InkWell(
 onTap: () => _selectDate(context),
 child: InputDecorator(
 decoration: InputDecoration(
 labelText: 'Fecha',
 focusedBorder: OutlineInputBorder(
 borderRadius: BorderRadius.circular(8.0),
 borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: TextStyle(fontSize: 16.0)),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30.0),
 ElevatedButton(
 onPressed: _saveIncome,
 style: ElevatedButton.styleFrom(
 padding: EdgeInsets.symmetric(vertical: 16.0),
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(8.0),
                  ),
 backgroundColor: Theme.of(context).primaryColor,
 elevation: 5.0,
                ),

                child: Text(
 widget.income == null ? 'Guardar Ingreso' : 'Actualizar Ingreso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}