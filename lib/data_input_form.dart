import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'date_picker_form_field.dart';
import 'database.dart';
import 'category.dart';
import 'expense.dart';

class DataInputForm extends StatefulWidget {
  final Function() onSubmit;
  final Expense? expenseToEdit;

  const DataInputForm({super.key, required this.onSubmit, this.expenseToEdit});

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
    final categoriesFromDatabase = await getCategories(db);
    setState(() {
      categories = categoriesFromDatabase;
    });
    if (widget.expenseToEdit != null) {
      _initFields();
    }
  }

  _initFields() {
    nameController.text = widget.expenseToEdit!.name;
    amountController.text = widget.expenseToEdit!.amount.toString();
    selectedDate = widget.expenseToEdit!.date;
    selectedCategory = widget.expenseToEdit!.categoryId;
  }

  void _submitData() async {
    Map<String, dynamic> expense = {
      'date': selectedDate.toIso8601String(),
      'name': nameController.text,
      'category_id': selectedCategory,
      'amount': double.parse(amountController.text),
    };

    if (widget.expenseToEdit != null) {
      await db.update('expenses', expense,
          where: 'id = ?', whereArgs: [widget.expenseToEdit!.id]);
    } else {
      await db.insert('expenses', expense);
    }

    nameController.clear();
    amountController.clear();
    setState(() {
      selectedDate = DateTime.now();
      selectedCategory = null;
    });
    widget.onSubmit();

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
              items: categories.map<DropdownMenuItem<int>>((Category category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Text(category.name),
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
