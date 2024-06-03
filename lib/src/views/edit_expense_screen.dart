import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  EditExpenseScreen(this.expense);

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _date;
  late ExpenseCategory _category;
  late bool _isIncome;

  @override
  void initState() {
    super.initState();
    _title = widget.expense.title;
    _amount = widget.expense.amount;
    _date = widget.expense.date;
    _category = widget.expense.category;
    _isIncome = widget.expense.isIncome;
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<ExpenseProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                initialValue: _amount.toString(),
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMd().format(_date)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              DropdownButtonFormField<ExpenseCategory>(
                value: _category,
                items: categories.map((category) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SwitchListTile(
                title: Text('Is Income'),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedExpense = Expense(
        id: widget.expense.id,
        title: _title,
        amount: _amount,
        date: _date,
        category: _category,
        isIncome: _isIncome,
      );

      Provider.of<ExpenseProvider>(context, listen: false)
          .updateExpense(updatedExpense);
      Navigator.of(context).pop();
    }
  }
}
