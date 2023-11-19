import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_lib;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'data_input_form.dart';
import 'expenses_list.dart';
import 'expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  _getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = path_lib.join(documentsDirectory.toString(), 'expenses.db');
    return path;
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

  void loadData() async {
    setState(() {
      _isLoading = true;
    });
    final db = await openDatabase(await _getDatabasePath(),
        version: 1, onCreate: _onCreate);
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    setState(() {
      _expenses = maps.map((expense) => Expense.fromMap(expense)).toList();
      _isLoading = false;
    });
  }

  void _addExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DataInputForm(onAdd: loadData)),
    );
  }

  void _handleDelete(int id) async {
    final db = await openDatabase(await _getDatabasePath(),
        version: 1, onCreate: _onCreate);
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    setState(() {
      _expenses.removeWhere((expense) => expense.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.bar_chart)),
              Tab(icon: Icon(Icons.attach_money)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addExpense,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        body: TabBarView(
          children: [
            const Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                //
                // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                // action in the IDE, or press "p" in the console), to see the
                // wireframe for each widget.
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Pie Chart',
                  ),
                ],
              ),
            ),
            Center(
              child: ExpensesListView(
                expenses: _expenses,
                isLoading: _isLoading,
                onDelete: _handleDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
