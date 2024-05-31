import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_category.dart';
import '../widgets/icon_picker_dialog.dart';

class ManageCategoriesScreen extends StatefulWidget {
  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  IconData _icon = Icons.category;

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCategory = ExpenseCategory(name: _name, icon: _icon);
      Provider.of<ExpenseProvider>(context, listen: false)
          .addCategory(newCategory);
      // Navigator.of(context).pop();
      context.go('/b');
    }
  }

  void _selectIcon() async {
    final IconData? selectedIcon = await showDialog<IconData>(
      context: context,
      builder: (context) {
        return IconPickerDialog();
      },
    );

    if (selectedIcon != null) {
      setState(() {
        _icon = selectedIcon;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<ExpenseProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: Icon(category.icon),
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Provider.of<ExpenseProvider>(context, listen: false)
                          .deleteCategory(category.id!);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Category Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  // TextFormField(
                  //   decoration: InputDecoration(labelText: 'Icon'),
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Please enter an icon';
                  //     }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     _icon = value!;
                  //   },
                  // ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_icon),
                        onPressed: _selectIcon,
                      ),
                      Text('Select Icon'),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitData,
                    child: Text('Add Category'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
