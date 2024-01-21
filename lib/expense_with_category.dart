import 'database.dart';

Future<List<ExpenseWithCategory>> getExpensesWithCategories() async {
  // Your database fetching logic
  final db = await openDatabase();
  final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT expenses.*, categories.name AS categoryName, categories.color AS categoryColor
    FROM expenses
    INNER JOIN categories ON expenses.category_id = categories.id
    ORDER BY -expenses.date
  ''');

  return results.map((map) => ExpenseWithCategory.fromMap(map)).toList();
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
