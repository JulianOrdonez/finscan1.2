import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/database_helper.dart';

class IncomeFormScreen extends StatefulWidget {
  final int userId;
  final Income? income;

  const IncomeFormScreen({Key? key, required this.userId, this.income})
      : super(key: key);

  @override
  _IncomeFormScreenState createState() => _IncomeFormScreenState();
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

  Future<void> _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final income = Income(
        id: widget.income?.id,
        userId: widget.userId,
        title: _titleController.text,
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
      );

      if (widget.income == null) {
        await DatabaseHelper.instance.insertIncome(income);
      } else {
        await DatabaseHelper.instance.updateIncome(income);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.income == null ? 'Add Income' : 'Edit Income'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
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
              const SizedBox(height: 16.0),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
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