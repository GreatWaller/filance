import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_category.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'package:go_router/go_router.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedCategory;
  bool _isIncome = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        Provider.of<ExpenseProvider>(context, listen: false).categories.first;
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newExpense = Expense(
        title: _title,
        amount: _amount,
        date: _selectedDate,
        category: _selectedCategory!,
        isIncome: _isIncome,
      );
      Provider.of<ExpenseProvider>(context, listen: false)
          .addExpense(newExpense);
      context.go('/b');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<ExpenseProvider>(context).categories;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem<ExpenseCategory>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon),
                        const SizedBox(width: 10),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Category'),
              ),
              SwitchListTile(
                title: Text('Income'),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                    _selectedCategory = categories.firstWhere(
                        (cat) => cat.isIncomeCategory == _isIncome,
                        orElse: () => categories.first);
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
