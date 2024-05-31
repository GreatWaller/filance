import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/expense_list_view.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              context.go('/b/manage-categories');
            },
          ),
        ],
      ),
      body: ExpenseList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/b/add');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
