import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'expense.dart';

class PieChartView extends StatelessWidget {
  final List<Expense> expenses;
  final bool isLoading;

  const PieChartView({
    super.key,
    required this.expenses,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 40,
            color: Colors.blue,
            title: '40%',
          ),
          PieChartSectionData(
            value: 60,
            color: Colors.red,
            title: '60%',
          ),
        ],
      ),
    );
  }
}
