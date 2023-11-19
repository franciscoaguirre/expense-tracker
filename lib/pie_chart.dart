import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'expense.dart';

Color getRandomColor() {
  Random random = Random();
  // Generate a random RGB color
  int r = random.nextInt(256); // Red value between 0 and 255
  int g = random.nextInt(256); // Green value between 0 and 255
  int b = random.nextInt(256); // Blue value between 0 and 255
  return Color.fromRGBO(r, g, b, 1); // Alpha is set to 1 for full opacity
}

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

    final Map<String, double> amountPerCategory = {};
    for (var expense in expenses) {
      amountPerCategory[expense.category] =
          (amountPerCategory[expense.category] ?? 0.0) + expense.amount;
    }

    return PieChart(
      PieChartData(
        sections: amountPerCategory
            .map((category, amount) => MapEntry(
                category,
                PieChartSectionData(
                  value: amount,
                  title: category,
                  color: getRandomColor(),
                )))
            .values
            .toList(),
      ),
    );
  }
}
