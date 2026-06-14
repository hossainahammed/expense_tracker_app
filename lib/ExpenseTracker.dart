import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Expense_modal.dart';
import 'widget/ExpensePieChart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponsiveExpenseTracker extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const ResponsiveExpenseTracker({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ResponsiveExpenseTracker> createState() => _ResponsiveExpenseTrackerState();
}

class _ResponsiveExpenseTrackerState extends State<ResponsiveExpenseTracker> {
 // final List<String> categories = ['Food', 'Transport', 'Entertainment', 'Bills', 'Shopping', 'Hospital','Medicine','Groceries','Education','Savings & Investments','Personal Care','Travel','Gifts & Donations','Insurance','Others'];
  final List<String> categories = [
    'Food',
    'Groceries',
    'Transport',
    'Entertainment',
    'Bills',
    'Shopping',
    'Housing',
    'Healthcare',
    'Education',
    'Insurance',
    'Savings',
    'Personal Care',
    'Travel',
    'Gifts',
    'Miscellaneous',
  ];
  List<Expense> _expense = [];

  String _currency = '৳';
  double _budgetLimit = 2000.0;
  double totall_expanse = 0.0;
  double remaining_balance=0.0;
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';

  Future<void> _saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> _loadData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Load expenses
  }

  Future<void> _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesString = prefs.getString('expenses');
    if (expensesString != null) {
      List<dynamic> jsonList = jsonDecode(expensesString);
      _expense = jsonList.map((json) => Expense.fromJson(json)).toList();
      totall_expanse = _expense.fold(0, (sum, item) => sum + item.amount);
    }
  }

  Future<void> _saveExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('expenses', jsonEncode(_expense.map((e) => e.toJson()).toList()));
  }

  void _showForm({Expense? existingExpense, int? index}) {
    String selectedCategory = existingExpense?.category ?? categories.first;
    TextEditingController titleController = TextEditingController(text: existingExpense?.title ?? '');
    TextEditingController amountController = TextEditingController(
        text: existingExpense != null ? existingExpense.amount.toString() : '');
    DateTime expenseDateTime = existingExpense?.date ?? DateTime.now();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Padding for keyboard
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content height
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: categories
                      .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                  decoration: InputDecoration(labelText: 'Select Category'),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          double.tryParse(amountController.text) != null) {
                        if (existingExpense != null && index != null) {
                          _editExpense(index, titleController.text, double.parse(amountController.text),
                              expenseDateTime, selectedCategory);
                        } else {
                          _addExpense(titleController.text, double.parse(amountController.text),
                              expenseDateTime, selectedCategory);
                        }
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text(
                      existingExpense != null ? "Update Expense" : "Add Expense",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setBudgetLimit() {
    TextEditingController budgetController = TextEditingController(text: _budgetLimit.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Budget Limit"),
          content: TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Budget Limit'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                double? newLimit = double.tryParse(budgetController.text);
                if (newLimit != null) {
                  setState(() {
                    _budgetLimit = newLimit;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Set"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _addExpense(String title, double amount, DateTime date, String category) {
    setState(() {
      _expense.add(Expense(title: title, amount: amount, date: date, category: category));
      totall_expanse += amount;
      _saveExpenses(); // Save expenses after adding
    });
  }

  void _editExpense(int index, String title, double amount, DateTime date, String category) {
    setState(() {
      totall_expanse -= _expense[index].amount;
      _expense[index] = Expense(title: title, amount: amount, date: date, category: category);
      totall_expanse += amount;
      _saveExpenses(); // Save expenses after editing
    });
  }

  void _confirmDeleteExpense(int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExpense(index); // Delete expense
                Navigator.of(ctx).pop(); // Close dialog
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    setState(() {
      totall_expanse -= _expense[index].amount;
      _expense.removeAt(index);
      _saveExpenses(); // Save expenses after deleting
    });
  }

  List<Expense> get _filteredExpenses {
    List<Expense> filtered = _selectedFilter == 'All'
        ? _expense
        : _expense.where((e) => e.category == _selectedFilter).toList();

    if (_selectedSort == 'Newest') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Track Your Expenses"),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_money),
            onPressed: _setBudgetLimit, // Call the method to set budget limit
          ),
          DropdownButton<String>(
            value: _currency,
            items: ['৳', '\$', '€', '₹']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _currency = value);
            },
          ),
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showForm,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            children: [
              if (totall_expanse > _budgetLimit)
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.redAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Budget Limit Exceeded!", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: ['All', ...categories]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedFilter = value);
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedSort,
                    items: ['Newest', 'Amount']
                        .map((c) => DropdownMenuItem(value: c, child: Text("Sort by $c")))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedSort = value);
                    },
                  ),
                ],
              ),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8.0),
                child: _expense.isEmpty
                    ? Center(child: Text("No data to show in pie chart."))
                    : ExpensePieChart(expenses: _expense, currency: _currency),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 100,
                      child: Card(
                        color: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total Expense',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$_currency${totall_expanse.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      height: 100,
                      child: Card(
                        color: (_budgetLimit - totall_expanse) < 0 ? Colors.redAccent : Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Available Balance',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$_currency${(_budgetLimit - totall_expanse).toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),



              Expanded(
                child: ListView.builder(
                  itemCount: _filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final e = _filteredExpenses[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(e.category[0]),
                        ),
                        title: Text(e.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat.yMMMd().format(e.date)}'),
                            Text('Category: ${e.category} | $_currency${e.amount}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showForm(existingExpense: e, index: index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _confirmDeleteExpense(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}