import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/income.dart';
import 'package:flutter_application_2/services/database_helper.dart';
import 'package:intl/intl.dart';

class IncomeFormScreen extends StatefulWidget {
  final int userId;
  final Income? income; // Para editar un ingreso existente

  const IncomeFormScreen({Key? key, required this.userId, this.income}) : super(key: key);

  @override
  _IncomeFormScreenState createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>(); // GlobalKey para el estado del formulario
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
      // Parse the date string from the database into a DateTime object
      _selectedDate = DateTime.parse(widget.income!.date);
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

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final newIncome = Income(
        id: widget.income?.id, // Si es edición, mantiene el ID
        userId: widget.userId, // Asegúrate de que userId esté disponible aquí
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        // Format the DateTime object to a String for saving to the database
        date: _selectedDate.toIso8601String().split('T').first,
      );
      if (widget.income == null) {
        // Agregar nuevo ingreso
        await DatabaseHelper.instance.insertIncome(newIncome);
      } else {
        // Actualizar ingreso existente
        await DatabaseHelper.instance.updateIncome(newIncome);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? 'Agregar Ingreso' : 'Editar Ingreso'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una cantidad';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text('Fecha: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveIncome,
                child: Text(widget.income == null ? 'Guardar Ingreso' : 'Actualizar Ingreso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
