import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'database.dart';

class PieChartView extends StatefulWidget {
  const PieChartView({
    super.key,
  });

  @override
  PieChartViewState createState() => PieChartViewState();
}

class CategoryWithTotal {
  final String name;
  final int color;
  final double total;

  CategoryWithTotal({
    required this.name,
    required this.color,
    required this.total,
  });

  factory CategoryWithTotal.fromMap(Map<String, dynamic> map) {
    return CategoryWithTotal(
      name: map['name'],
      color: map['color'],
      total: map['total'],
    );
  }
}

/// Gets all amounts spent, no limit.
/// Meant for making charts.
Future<List<CategoryWithTotal>> getAllSpentPerCategory() async {
  // Your database fetching logic
  final db = await openDatabase(); // TODO: Reuse database connection from main?
  final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT SUM(expenses.amount) AS total, categories.name, categories.color
    FROM expenses
    INNER JOIN categories ON expenses.category_id = categories.id
    GROUP BY categories.name
  ''');

  return results.map((map) => CategoryWithTotal.fromMap(map)).toList();
}

class PieChartViewState extends State<PieChartView> {
  List<CategoryWithTotal> _totalSpentPerCategory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final spentPerCategory = await getAllSpentPerCategory();
    setState(() {
      _totalSpentPerCategory = spentPerCategory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
        height: 400.0,
        child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: PieChart(
              PieChartData(
                sections: _totalSpentPerCategory
                    .map((category) => PieChartSectionData(
                          value: category.total,
                          title: category.name,
                          color: Color(category.color),
                        ))
                    .toList(),
              ),
            )));
  }
}

class CategoryWithAmount {
  final String name;
  final double amount;
  final int color;

  CategoryWithAmount({
    required this.name,
    required this.amount,
    required this.color,
  });
}
