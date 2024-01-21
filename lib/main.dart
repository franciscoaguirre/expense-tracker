import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'database.dart';
import 'data_input_form.dart';
import 'expenses_list.dart';
import 'expense.dart';
import 'expense_with_category.dart';
import 'pie_chart.dart';
import 'csv_utils.dart';
import 'category.dart';
import 'category_form.dart';
import 'categories_list.dart';

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

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<ExpenseWithCategory> _expenses = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool showingAdditionalActionButtons = false;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late sqflite.Database db;
  int _expensesOffset = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scrollController.addListener(_scrollListener);
    _initDatabase();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    db.close();
    super.dispose();
  }

  _initDatabase() async {
    db = await openDatabase();
    loadData();
  }

  loadData() async {
    setState(() {
      _isLoading = true;
    });

    final List<ExpenseWithCategory> expensesWithCategories =
        await getExpensesWithCategories(db, _expensesOffset);
    final List<Category> categories = await getCategories(db);
    setState(() {
      _expenses = expensesWithCategories;
      _categories = categories;
      _isLoading = false;
    });
    print(_expenses.length);
  }

  void _addExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DataInputForm(onSubmit: loadData)),
    );
  }

  void _addCategory() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CategoryForm(onSubmit: loadData)));
  }

  void _editExpense(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              DataInputForm(onSubmit: loadData, expenseToEdit: expense)),
    );
  }

  void _editCategory(Category category) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CategoryForm(onSubmit: loadData, categoryToEdit: category)));
  }

  void _handleDeleteExpense(int id) async {
    final db = await openDatabase();
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    setState(() {
      _expenses.removeWhere((expense) => expense.id == id);
    });
  }

  void _handleDeleteCategory(int id) async {
    final db = await openDatabase();
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    setState(() {
      _categories.removeWhere((category) => category.id == id);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchMoreExpenses();
    }
  }

  _fetchMoreExpenses() async {
    _expensesOffset += 20;
    final List<ExpenseWithCategory> nextPage =
        await getExpensesWithCategories(db, _expensesOffset);
    setState(() {
      _expenses = _expenses + nextPage;
      _isLoading = false; // Still need to show the loading in the right place
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<MenuOption>(
            onSelected: (menuOption) =>
                onSelectedMenuOption(menuOption, loadData),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOption>>[
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart)),
            Tab(icon: Icon(Icons.category)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showingAdditionalActionButtons = !showingAdditionalActionButtons;
          });
        },
        tooltip: 'Add',
        child: showingAdditionalActionButtons
            ? const Icon(Icons.close)
            : const Icon(Icons.add),
      ),
      body: Stack(children: [
        TabBarView(
          controller: _tabController,
          children: [
            ListView(controller: _scrollController, children: [
              PieChartView(
                expenses: _expenses,
                isLoading: _isLoading,
              ),
              ExpensesListView(
                expenses: _expenses,
                isLoading: _isLoading,
                onDelete: _handleDeleteExpense,
                onEdit: _editExpense,
              )
            ]),
            Center(
              child: CategoriesListView(
                categories: _categories,
                isLoading: _isLoading,
                onDelete: _handleDeleteCategory,
                onEdit: _editCategory,
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 80.0,
          right: 16.0,
          child: AnimatedOpacity(
            opacity: showingAdditionalActionButtons ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        showingAdditionalActionButtons = false;
                        _addCategory();
                      });
                    },
                    heroTag: null,
                    mini: true,
                    child: const Icon(Icons.add_chart)),
                const SizedBox(height: 2.0),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      showingAdditionalActionButtons = false;
                    });
                    _addExpense();
                  },
                  heroTag: null,
                  mini: true,
                  child: const Icon(Icons.money),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
