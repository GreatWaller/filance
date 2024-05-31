import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class ExpenseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(expense.category.icon),
                Text(
                  expense.isIncome ? '收入' : '支出',
                  style: TextStyle(
                      fontSize: 12,
                      color: expense.isIncome ? Colors.green : Colors.red),
                ),
              ],
            ),
            title: Text('\$${expense.amount.toStringAsFixed(2)}'),
            // subtitle: Text(
            //   '${expense.date.toLocal().toString().split(' ')[0]}',
            // ),
            subtitle: Text(
                '${expense.date.toLocal().toString().split(' ')[0]}  ${expense.title}'),
            // trailing: Text(expense.date.toLocal().toString()),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Provider.of<ExpenseProvider>(context, listen: false)
                    .deleteExpense(expense.id!);
              },
            ),
          ),
        );
      },
    );
  }
}
