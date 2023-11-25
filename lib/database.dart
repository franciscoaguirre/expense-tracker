export "package:expense_tracker/database.dart";

import 'dart:io';
import "package:sqflite/sqflite.dart" as sqflite;
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';

Future<sqflite.Database> openDatabase() async {
  return sqflite.openDatabase(
    await _getDatabasePath(),
    onCreate: _onCreate,
    version: 1,
  );
}

_getDatabasePath() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = path_lib.join(documentsDirectory.toString(), 'expenses.db');
  return path;
}

_onCreate(sqflite.Database db, int version) async {
  await db.execute('''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE,
      color INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      name TEXT,
      category_id INTEGER,
      amount REAL,
      FOREIGN KEY (category_id) REFERENCES category(id)
    )
  ''');
}
