class Expense {
  final int? id; // Optional; for database reference
  final DateTime date;
  final String name;
  final String category;
  final double amount;

  Expense({
    this.id,
    required this.date,
    required this.name,
    required this.category,
    required this.amount,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'category': category,
      'amount': amount,
    };
  }

  @override
  String toString() {
    return 'Expense(date: $date, name: $name, category: $category, amount: $amount)';
  }
}
