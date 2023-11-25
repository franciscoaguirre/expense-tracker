import 'package:flutter/material.dart';

import 'database.dart';
import 'data_input_form.dart';
import 'expenses_list.dart';
import 'expense.dart';
import 'expense_with_category.dart';
import 'pie_chart.dart';
import 'csv_utils.dart';

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

enum MenuOption { exportData, importData }

void onSelectedMenuOption(MenuOption option, Function() callback) async {
  switch (option) {
    case MenuOption.exportData:
      exportExpensesToCSV();
      break;
    case MenuOption.importData:
      await importExpensesFromCSV();
      await callback();
      break;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<ExpenseWithCategory> _expenses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      _isLoading = true;
    });
    final List<ExpenseWithCategory> expensesWithCategories =
        await getExpensesWithCategories();
    setState(() {
      _expenses = expensesWithCategories;
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
    final db = await openDatabase();
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
          actions: <Widget>[
            PopupMenuButton<MenuOption>(
              onSelected: (menuOption) =>
                  onSelectedMenuOption(menuOption, loadData),
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MenuOption>>[
                const PopupMenuItem<MenuOption>(
                  value: MenuOption.exportData,
                  child: Text("Export Data"),
                ),
                const PopupMenuItem<MenuOption>(
                  value: MenuOption.importData,
                  child: Text("Import Data"),
                ),
              ],
            ),
          ],
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(64.0),
                child: PieChartView(
                  expenses: _expenses,
                  isLoading: _isLoading,
                ),
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
