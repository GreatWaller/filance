import 'package:flutter/material.dart';

class ExpenseCategory {
  final int? id;
  final String name;
  final IconData icon;
  final bool isIncomeCategory;

  ExpenseCategory({
    this.id,
    required this.name,
    required this.icon,
    this.isIncomeCategory = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'isIncomeCategory': isIncomeCategory ? 1 : 0,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: map['iconFontFamily']),
      isIncomeCategory: map['isIncomeCategory'] == 1,
    );
  }
}
