import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'category.dart';
import 'database.dart';
import 'utils.dart';

class CategoryForm extends StatefulWidget {
  final Function() onSubmit;
  final Category? categoryToEdit;

  const CategoryForm({super.key, required this.onSubmit, this.categoryToEdit});

  @override
  CategoryFormState createState() => CategoryFormState();
}

class CategoryFormState extends State<CategoryForm> {
  final nameController = TextEditingController();
  late sqflite.Database db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    db = await openDatabase();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  void _submitData() async {
    Map<String, dynamic> category = {
      'name': nameController.text,
      'color': getRandomColor().value,
    };

    await db.insert('categories', category);

    widget.onSubmit();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
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
