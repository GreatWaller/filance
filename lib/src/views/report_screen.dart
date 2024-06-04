import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ReportScreen extends StatefulWidget {
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  int _selectedYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报表'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: '月度报表'),
            const Tab(text: '年度报表'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyReport(context),
          _buildYearlyReport(context),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.getExpensesForMonth(_selectedMonth);
    final incomeData =
        _generateCategoryData(expenses.where((e) => e.isIncome).toList());
    final expenseData =
        _generateCategoryData(expenses.where((e) => !e.isIncome).toList());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 20),
          _buildTotalSummary(expenseProvider, _selectedMonth),
          // const SizedBox(height: 20),
          // _buildPieChart('收入分布', incomeData),
          const SizedBox(height: 20),
          _buildPieChart('支出分布', expenseData),
          SizedBox(height: 20),
          _buildMonthlyExpenseCategoryList(expenses),
        ],
      ),
    );
  }

  Widget _buildMonthlyExpenseCategoryList(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var expense in expenses.where((e) => !e.isIncome)) {
      categoryTotals.update(
          expense.category.name, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
      totalExpense += expense.amount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildHeaderCell('类别'),
                _buildHeaderCell('占比'),
                _buildHeaderCell('花费'),
              ],
            ),
            Divider(),
            ...categoryTotals.entries.map((entry) {
              final percentage = (entry.value / totalExpense) * 100;
              return Row(
                children: [
                  _buildCell(entry.key),
                  _buildCell('${percentage.toStringAsFixed(2)}%'),
                  _buildCell('${entry.value.toStringAsFixed(2)}'),
                ],
              );
            }).toList(),
            // Divider(),
            // Row(
            //   children: [
            //     _buildCell('总计', isHeader: true),
            //     _buildCell('\$${totalExpense.toStringAsFixed(2)}',
            //         isHeader: true),
            //     _buildCell('100%', isHeader: true),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildYearlyReport(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.getExpensesForYear(_selectedYear);
    final incomeData =
        _generateMonthlyData(expenses.where((e) => e.isIncome).toList());
    final expenseData =
        _generateMonthlyData(expenses.where((e) => !e.isIncome).toList());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildYearSelector(),
          SizedBox(height: 20),
          // _buildLineChart('年度收入', incomeData, Colors.green),
          // SizedBox(height: 20),
          _buildLineChart(
              '年度收支', [expenseData, incomeData], [Colors.red, Colors.green]),
          const SizedBox(height: 20),
          _buildYearlyExpenseList(expenses),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedMonth =
                  DateTime(_selectedMonth.year, _selectedMonth.month - 1);
            });
          },
        ),
        Text(
          DateFormat('yyyy年MM月').format(_selectedMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
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

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedYear--;
            });
          },
        ),
        Text(
          '$_selectedYear年',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedYear++;
            });
          },
        ),
      ],
    );
  }
  // Widget _buildTotalSummary(ExpenseProvider provider, DateTime selectedMonth) {
  //   final totalIncome = provider.getMonthlyTotal(true, selectedMonth);
  //   final totalExpense = provider.getMonthlyTotal(false, selectedMonth);
  //   final netIncome = totalIncome - totalExpense;

  //   return Card(
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('本月总收入: \$${totalIncome.toStringAsFixed(2)}',
  //               style: const TextStyle(fontSize: 18, color: Colors.green)),
  //           Text('本月总支出: \$${totalExpense.toStringAsFixed(2)}',
  //               style: const TextStyle(fontSize: 18, color: Colors.red)),
  //           Text('净收入: \$${netIncome.toStringAsFixed(2)}',
  //               style:
  //                   const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildTotalSummary(ExpenseProvider provider, DateTime selectedMonth) {
    final totalIncome = provider.getMonthlyTotal(true, selectedMonth);
    final totalExpense = provider.getMonthlyTotal(false, selectedMonth);
    final netIncome = totalIncome - totalExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildSummaryCell(
                    '本月总收入', '${totalIncome.toStringAsFixed(2)}', Colors.green),
                _buildSummaryCell(
                    '本月总支出', '${totalExpense.toStringAsFixed(2)}', Colors.red),
                _buildSummaryCell(
                    '结余', '${netIncome.toStringAsFixed(2)}', Colors.black,
                    isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCell(String title, String value, Color color,
      {bool isBold = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
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
          titlePositionPercentageOffset: 0.5);
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  List<FlSpot> _generateMonthlyData(List<Expense> expenses) {
    final Map<int, double> data = {};

    for (var expense in expenses) {
      final month = expense.date.month;
      data.update(month, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }

    return data.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
  }

  Widget _buildLineChart(
      String title, List<List<FlSpot>> data, List<Color> color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData:
                      const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const textStyle =
                                TextStyle(color: Colors.black, fontSize: 12);
                            switch (value.toInt()) {
                              case 1:
                                return const Text('1月', style: textStyle);
                              case 2:
                                return const Text('2月', style: textStyle);
                              case 3:
                                return const Text('3月', style: textStyle);
                              case 4:
                                return const Text('4月', style: textStyle);
                              case 5:
                                return const Text('5月', style: textStyle);
                              case 6:
                                return const Text('6月', style: textStyle);
                              case 7:
                                return const Text('7月', style: textStyle);
                              case 8:
                                return const Text('8月', style: textStyle);
                              case 9:
                                return const Text('9月', style: textStyle);
                              case 10:
                                return const Text('10月', style: textStyle);
                              case 11:
                                return const Text('11月', style: textStyle);
                              case 12:
                                return const Text('12月', style: textStyle);
                              default:
                                return const Text('');
                            }
                          },
                          interval: 1),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  // lineBarsData: [
                  //   LineChartBarData(
                  //     spots: data[0],
                  //     isCurved: true,
                  //     color: color[0],
                  //     barWidth: 4,
                  //     belowBarData: BarAreaData(
                  //         show: true, color: color[0].withOpacity(0.3)),
                  //   ),
                  //   LineChartBarData(
                  //     spots: data[1],
                  //     isCurved: true,
                  //     color: color[1],
                  //     barWidth: 4,
                  //     belowBarData: BarAreaData(
                  //         show: true, color: color[1].withOpacity(0.3)),
                  //   ),
                  // ],
                  lineBarsData: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final spots = entry.value;
                    return LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color[index % color.length],
                      barWidth: 4,
                      belowBarData: BarAreaData(
                          show: true,
                          color: color[index % color.length].withOpacity(0.3)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildYearlyExpenseList(List<Expense> expenses) {
  //   final groupedExpenses = <String, List<Expense>>{};

  //   for (var expense in expenses) {
  //     final month = DateFormat('yyyy-MM').format(expense.date);
  //     groupedExpenses.putIfAbsent(month, () => []).add(expense);
  //   }

  //   return Column(
  //     children: groupedExpenses.entries.map((entry) {
  //       return ExpansionTile(
  //         title: Text(entry.key),
  //         children: entry.value.map((expense) {
  //           return ListTile(
  //             title: Text(expense.title),
  //             subtitle: Text(DateFormat('yyyy-MM-dd').format(expense.date)),
  //             trailing: Text(
  //                 '${expense.isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}'),
  //           );
  //         }).toList(),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildYearlyExpenseList(List<Expense> expenses) {
    final Map<int, Map<String, double>> monthlySummary = {};
    double totalIncome = 0;
    double totalExpense = 0;

    for (var expense in expenses) {
      final month = expense.date.month;
      if (!monthlySummary.containsKey(month)) {
        monthlySummary[month] = {'income': 0, 'expense': 0};
      }
      if (expense.isIncome) {
        monthlySummary[month]!['income'] =
            monthlySummary[month]!['income']! + expense.amount;
      } else {
        monthlySummary[month]!['expense'] =
            monthlySummary[month]!['expense']! + expense.amount;
      }
    }

    for (var summary in monthlySummary.values) {
      totalIncome += summary['income']!;
      totalExpense += summary['expense']!;
    }
    final totalBalance = totalIncome - totalExpense;

    return Column(
      children: [
        _buildTableHeader(),
        ...monthlySummary.entries.map((entry) {
          final month = entry.key;
          final summary = entry.value;
          final income = summary['income']!;
          final expense = summary['expense']!;
          final balance = income - expense;

          return _buildTableRow(month.toString(), income, expense, balance);
        }).toList(),
        _buildTableRow('总计', totalIncome, totalExpense, totalBalance,
            isTotal: true),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildTableCell('月份', isHeader: true),
            _buildTableCell('收入', isHeader: true),
            _buildTableCell('支出', isHeader: true),
            _buildTableCell('结余', isHeader: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
      String month, double income, double expense, double balance,
      {bool isTotal = false}) {
    return Container(
      color: isTotal ? Colors.grey[300] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildTableCell(month),
            _buildTableCell(income.toStringAsFixed(2), isIncome: true),
            _buildTableCell('${expense.toStringAsFixed(2)}', isExpense: true),
            _buildTableCell('${balance.toStringAsFixed(2)}', isBalance: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text,
      {bool isHeader = false,
      bool isIncome = false,
      bool isExpense = false,
      bool isBalance = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isIncome
              ? Colors.green
              : isExpense
                  ? Colors.red
                  : isBalance
                      ? Colors.black
                      : Colors.black,
        ),
      ),
    );
  }
}
