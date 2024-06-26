import 'expense_category.dart';

class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final bool isIncome;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': category.id,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, ExpenseCategory category) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: category,
      isIncome: map['isIncome'] == 1,
    );
  }
}
