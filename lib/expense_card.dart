import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Function() onDelete;

  const ExpenseCard({super.key, required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(expense.date);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Date: $formattedDate'),
                Text('Name: ${expense.name}'),
                Text('Category: ${expense.category}'),
                Text('Amount: ${expense.amount}'),
              ],
            ),
            const Spacer(),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
