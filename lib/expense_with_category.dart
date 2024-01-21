import 'package:sqflite/sqflite.dart' as sqflite;

import 'database.dart';

/// Gets expenses with an offset and a fixed limit of 20.
/// Meant for rendering in lists.
Future<List<ExpenseWithCategory>> getExpensesWithCategories(
  sqflite.Database? db,
  int offset,
) async {
  final actualDb = db ?? await openDatabase();
  // Your database fetching logic
  final List<Map<String, dynamic>> results = await actualDb.rawQuery('''
    SELECT expenses.*, categories.name AS categoryName, categories.color AS categoryColor
    FROM expenses
    INNER JOIN categories ON expenses.category_id = categories.id
    ORDER BY expenses.date DESC
    LIMIT 20
    OFFSET ?
  ''', [offset]);

  return results.map((map) => ExpenseWithCategory.fromMap(map)).toList();
}

/// Gets all expenses, no limit.
/// Meant for exporting.
Future<List<ExpenseWithCategory>> getAllExpensesWithCategories(
  sqflite.Database? db,
) async {
  final actualDb = db ?? await openDatabase();
  // Your database fetching logic
  final List<Map<String, dynamic>> results = await actualDb.rawQuery('''
    SELECT expenses.*, categories.name AS categoryName, categories.color AS categoryColor
    FROM expenses
    INNER JOIN categories ON expenses.category_id = categories.id
    ORDER BY expenses.date DESC
  ''');

  return results.map((map) => ExpenseWithCategory.fromMap(map)).toList();
}

Future<double> getTotalSpent(sqflite.Database? db, int? categoryId) async {
  final actualDb = db ?? await openDatabase();
  final result = categoryId == null
      ? await actualDb.rawQuery("SELECT SUM(amount) AS total FROM expenses")
      : await actualDb.rawQuery('''
    SELECT SUM(amount) AS total
    FROM expenses
    WHERE category_id = ?
  ''', [categoryId]);
  double totalAmount = (result.isNotEmpty)
      ? (result[0]['total'] as num?)?.toDouble() ?? 0.0
      : 0.0;
  return totalAmount;
}

class ExpenseWithCategory {
  final int id;
  final DateTime date;
  final String name;
  final int categoryId;
  final double amount;
  final String categoryName;
  final int categoryColor; // Store color as integer

  ExpenseWithCategory({
    required this.id,
    required this.date,
    required this.name,
    required this.categoryId,
    required this.amount,
    required this.categoryName,
    required this.categoryColor,
  });

  factory ExpenseWithCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseWithCategory(
      id: map['id'],
      date: DateTime.parse(map['date']),
      name: map['name'],
      categoryId: map['category_id'],
      amount: map['amount'],
      categoryName: map['categoryName'],
      categoryColor: map['categoryColor'],
    );
  }
}
