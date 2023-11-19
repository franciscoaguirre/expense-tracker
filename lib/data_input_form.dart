import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'date_picker_form_field.dart';

class DataInputForm extends StatefulWidget {
  final Function() onAdd;

  const DataInputForm({super.key, required this.onAdd});

  @override
  DataInputFormState createState() => DataInputFormState();
}

class DataInputFormState extends State<DataInputForm> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  final List<String> categories = [
    'Accomodation',
    'Transportation',
    'Restaurants',
    'Groceries',
    'Drugstore',
    'Entertainment',
    'Other',
  ];
  String? selectedCategory;

  Database? db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    db?.close();
    super.dispose();
  }

  _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = path_lib.join(documentsDirectory.toString(), 'expenses.db');
    return path;
  }

  _initDatabase() async {
    String path = await _getDatabasePath();
    db = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        name TEXT,
        category TEXT,
        amount REAL
      )
    ''');
  }

  void _submitData() async {
    Map<String, dynamic> expense = {
      'date': selectedDate.toIso8601String(),
      'name': nameController.text,
      'category': selectedCategory,
      'amount': double.parse(amountController.text),
    };
    await db?.insert('expenses', expense);

    nameController.clear();
    amountController.clear();
    setState(() {
      selectedDate = DateTime.now();
      selectedCategory = null;
    });
    widget.onAdd();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleDateChange(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DatePickerFormField(
              selectedDate: selectedDate,
              onDateChanged: _handleDateChange,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            // Category Dropdown
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedCategory,
              hint: const Text('Category'),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Amount Input
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            // Submit Button
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
