import 'package:sqflite/sqflite.dart' as sqflite;

import 'database.dart';

class Category {
  final int id;
  final String name;
  final int color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'Category(name: $name, color: $color)';
  }
}

Future<List<Category>> getCategories(sqflite.Database? db) async {
  final actualDb = db ?? await openDatabase();
  final List<Map<String, dynamic>> results =
      await actualDb.query('categories', columns: ['id', 'name', 'color']);
  return results.map((map) => Category.fromMap(map)).toList();
}
