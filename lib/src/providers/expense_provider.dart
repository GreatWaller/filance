import 'package:filance/src/models/expense_category.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  late Database _database;

  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;

  Future<void> initializeDB() async {
    _database = await databaseFactoryFfi.openDatabase(
      join(await getDatabasesPath(), 'expense_tracker.db'),
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute(
            "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, categoryId INTEGER, isIncome INTEGER)",
          );
          await db.execute(
            "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, icon INTEGER, iconFontFamily TEXT, isIncomeCategory INTEGER)",
          );
          // Insert default categories
          int foodCategoryId = await db.insert(
              'categories',
              ExpenseCategory(
                      name: '餐饮',
                      icon: Icons.restaurant,
                      isIncomeCategory: false)
                  .toMap());
          int shoppingCategoryId = await db.insert(
              'categories',
              ExpenseCategory(
                      name: '购物',
                      icon: Icons.shopping_cart,
                      isIncomeCategory: false)
                  .toMap());
          int salaryCategoryId = await db.insert(
              'categories',
              ExpenseCategory(
                      name: '工资',
                      icon: Icons.attach_money,
                      isIncomeCategory: true)
                  .toMap());

          // Insert default expenses
          await db.insert(
              'expenses',
              Expense(
                      title: '午餐',
                      amount: 50.0,
                      date: DateTime.now(),
                      category: ExpenseCategory(
                          id: foodCategoryId,
                          name: '餐饮',
                          icon: Icons.restaurant,
                          isIncomeCategory: false),
                      isIncome: false)
                  .toMap());

          await db.insert(
              'expenses',
              Expense(
                      title: '购物',
                      amount: 200.0,
                      date: DateTime.now(),
                      category: ExpenseCategory(
                          id: shoppingCategoryId,
                          name: '购物',
                          icon: Icons.shopping_cart,
                          isIncomeCategory: false),
                      isIncome: false)
                  .toMap());

          await db.insert(
              'expenses',
              Expense(
                      title: '工资',
                      amount: 5000.0,
                      date: DateTime.now(),
                      category: ExpenseCategory(
                          id: salaryCategoryId,
                          name: '工资',
                          icon: Icons.attach_money,
                          isIncomeCategory: true),
                      isIncome: true)
                  .toMap());
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              "ALTER TABLE expenses ADD COLUMN isIncome INTEGER DEFAULT 0",
            );
            await db.execute(
              "ALTER TABLE categories ADD COLUMN isIncomeCategory INTEGER DEFAULT 0",
            );
          }
        },
      ),
    );
    loadCategories();
    await loadExpenses();
  }

  Future<void> loadExpenses() async {
    final List<Map<String, dynamic>> maps = await _database.query('expenses');
    _expenses = List.generate(maps.length, (i) {
      final category =
          _categories.firstWhere((cat) => cat.id == maps[i]['categoryId']);
      return Expense.fromMap(maps[i], category);
    });
    notifyListeners();
  }

  Future<void> loadCategories() async {
    final List<Map<String, dynamic>> maps = await _database.query('categories');
    _categories = List.generate(maps.length, (i) {
      return ExpenseCategory.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _database.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _expenses.add(expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await _database.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    await _database.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  Future<void> addCategory(ExpenseCategory category) async {
    await _database.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(ExpenseCategory category) async {
    await _database.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    final index = _categories.indexWhere((c) => c.id == category.id);
    _categories[index] = category;
    notifyListeners();
  }

  Future<void> deleteCategory(int id) async {
    await _database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }

  double getMonthlyTotal(bool isIncome) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(Duration(days: 1));

    return _expenses.where((expense) {
      return expense.isIncome == isIncome &&
          expense.date.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(Duration(days: 1)));
    }).fold(0.0, (sum, item) => sum + item.amount);
  }
}
