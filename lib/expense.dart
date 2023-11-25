class Expense {
  final int? id; // Optional; for database reference
  final DateTime date;
  final String name;
  final int categoryId;
  final double amount;

  Expense({
    this.id,
    required this.date,
    required this.name,
    required this.categoryId,
    required this.amount,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      name: map['name'],
      categoryId: map['category_id'],
      amount: map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'category_id': categoryId,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'Expense(date: $date, name: $name, category_id: $categoryId, amount: $amount)';
  }
}
