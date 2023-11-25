import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'date_picker_form_field.dart';
import 'database.dart';
import 'category.dart';

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

  int? selectedCategory;

  List<Category> categories = [];
  late sqflite.Database db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  _initDatabase() async {
    db = await openDatabase();
    categories = await getCategories(db);
  }

  void _submitData() async {
    Map<String, dynamic> expense = {
      'date': selectedDate.toIso8601String(),
      'name': nameController.text,
      'category_id': selectedCategory,
      'amount': double.parse(amountController.text),
    };
    await db.insert('expenses', expense);

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
            DropdownButtonFormField<int>(
              isExpanded: true,
              value: selectedCategory,
              hint: const Text('Category'),
              onChanged: (newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<int>>((Category value) {
                return DropdownMenuItem<int>(
                  value: value.id,
                  child: Text(value.name),
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
