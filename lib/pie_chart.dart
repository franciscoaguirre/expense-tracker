import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'expense_with_category.dart';

class PieChartView extends StatelessWidget {
  final List<ExpenseWithCategory> expenses;
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

    final Map<String, CategoryWithAmount> amountPerCategory = {};
    for (var expense in expenses) {
      amountPerCategory[expense.categoryName] = CategoryWithAmount(
        name: expense.categoryName,
        amount: (amountPerCategory[expense.categoryName]?.amount ?? 0.0) +
            expense.amount,
        color: expense.categoryColor,
      );
    }

    return SizedBox(
        height: 400.0,
        child: Padding(
            padding: const EdgeInsets.all(64.0),
            child: PieChart(
              PieChartData(
                sections: amountPerCategory
                    .map((categoryName, category) => MapEntry(
                        categoryName,
                        PieChartSectionData(
                          value: category.amount,
                          title: categoryName,
                          color: Color(category.color),
                        )))
                    .values
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
