import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/expense_provider.dart';

class ReportScreen extends StatefulWidget {
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.getExpensesForMonth(_selectedMonth);
    final incomeData =
        _generateCategoryData(expenses.where((e) => e.isIncome).toList());
    final expenseData =
        _generateCategoryData(expenses.where((e) => !e.isIncome).toList());

    return Scaffold(
      appBar: AppBar(
        title: Text('报表'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildTotalSummary(expenseProvider),
            SizedBox(height: 20),
            _buildPieChart('支出分布', expenseData),
            SizedBox(height: 20),
            // _buildPieChart('收入分布', incomeData),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedMonth =
                  DateTime(_selectedMonth.year, _selectedMonth.month - 1);
            });
          },
        ),
        Text(
          DateFormat('yyyy年MM月').format(_selectedMonth),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedMonth =
                  DateTime(_selectedMonth.year, _selectedMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildTotalSummary(ExpenseProvider provider) {
    final totalIncome = provider.getMonthlyTotal(true, _selectedMonth);
    final totalExpense = provider.getMonthlyTotal(false, _selectedMonth);
    final netIncome = totalIncome - totalExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本月总收入: \$${totalIncome.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: Colors.green)),
            Text('本月总支出: \$${totalExpense.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: Colors.red)),
            Text('净收入: \$${netIncome.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateCategoryData(List expenses) {
    final Map<String, double> data = {};

    for (var expense in expenses) {
      data.update(expense.category.name, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }

    return data.entries.map((entry) {
      return PieChartSectionData(
          color: _getRandomColor(),
          value: entry.value,
          title: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
          radius: 50,
          titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900]),
          titlePositionPercentageOffset: 2);
    }).toList();
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Widget _buildPieChart(String title, List<PieChartSectionData> sections) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
