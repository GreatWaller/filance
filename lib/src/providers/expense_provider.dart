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
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            "CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, categoryId INTEGER)",
          );
          await db.execute(
            "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, icon INTEGER, iconFontFamily TEXT)",
          );
          await db.insert('categories',
              ExpenseCategory(name: '餐饮', icon: Icons.restaurant).toMap());
          await db.insert('categories',
              ExpenseCategory(name: '购物', icon: Icons.shopping_cart).toMap());
        },
      ),
    );
    await loadExpenses();
    await loadCategories();
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
}
