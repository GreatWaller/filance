import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'package:go_router/go_router.dart';

import '../widgets/expense_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final monthlyIncome = expenseProvider.getMonthlyTotal(true);
    final monthlyExpense = expenseProvider.getMonthlyTotal(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('账单'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              context.go('/b/manage-categories');
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '本月总收入',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${monthlyIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '本月总支出',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${monthlyExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ExpenseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/b/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
