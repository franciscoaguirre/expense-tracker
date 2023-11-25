import 'package:flutter/material.dart';

import 'expense_with_category.dart';
import 'expense_card.dart';
import 'expense.dart';

class ExpensesListView extends StatelessWidget {
  final List<ExpenseWithCategory> expenses;
  final Function(int) onDelete;
  final Function(Expense) onEdit;
  final bool isLoading;

  const ExpensesListView({
    super.key,
    required this.expenses,
    required this.onDelete,
    required this.isLoading,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (expenses.isEmpty) {
      return const Center(child: Text("No expenses found"));
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        return ExpenseCard(
          expense: expenses[index],
          onDelete: () {
            onDelete(expenses[index].id);
          },
          onEdit: () {
            onEdit(Expense.fromExpenseWithCategory(expenses[index]));
          },
        );
      },
    );
  }
}
