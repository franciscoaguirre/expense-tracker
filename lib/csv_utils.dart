import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

import 'database.dart';
import 'expense_with_category.dart';

Color getRandomColor() {
  Random random = Random();
  // Generate a random RGB color
  int r = random.nextInt(256); // Red value between 0 and 255
  int g = random.nextInt(256); // Green value between 0 and 255
  int b = random.nextInt(256); // Blue value between 0 and 255
  return Color.fromRGBO(r, g, b, 1); // Alpha is set to 1 for full opacity
}

Future<void> exportExpensesToCSV() async {
  List<ExpenseWithCategory> expenses = await getExpensesWithCategories();

  List<List<dynamic>> rows = [];
  rows.add(["ID", "Name", "Category", "Amount", "Date"]); // Example columns
  for (var expense in expenses) {
    rows.add([
      expense.id,
      expense.name,
      expense.categoryName,
      expense.amount,
      expense.date
    ]);
  }

  String csvData = const ListToCsvConverter().convert(rows);
  final directory = await FilePicker.platform.getDirectoryPath();
  if (directory != null) {
    final pathOfTheFileToWrite = directory + "/my_expenses.csv";
    File file = File(pathOfTheFileToWrite);
    await file.writeAsString(csvData, encoding: utf8);
  }
}

Future<void> importExpensesFromCSV() async {
  final db = await openDatabase();
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    String fileContent = await file.readAsString(encoding: utf8);
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(fileContent);
    rowsAsListOfValues.removeAt(0); // Remove header
    const categoryIndex = 2;

    await db.delete('categories');
    var categoryMap = <String, int>{};
    for (var row in rowsAsListOfValues) {
      if (!categoryMap.containsKey(row[categoryIndex])) {
        int id = await db.insert('categories', {
          'name': row[categoryIndex],
          'color': getRandomColor().value,
        });
        categoryMap[row[categoryIndex]] = id;
      }
    }

    await db.delete('expenses');
    for (var row in rowsAsListOfValues) {
      await db.insert('expenses', {
        'id': row[0],
        'name': row[1],
        'category_id': categoryMap[row[categoryIndex]],
        'amount': row[3],
        'date': row[4]
      });
    }
  }
}
