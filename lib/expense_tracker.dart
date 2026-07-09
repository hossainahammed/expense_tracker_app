import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_modal.dart';
import 'widget/expense_pie_chart.dart';
import 'widget/balance_card.dart';
import 'widget/filter_sort_row.dart';
import 'widget/transaction_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/folder_list_screen.dart';

class ResponsiveExpenseTracker extends StatefulWidget {
  final ValueNotifier<String> themeModeNotifier;

  const ResponsiveExpenseTracker({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<ResponsiveExpenseTracker> createState() =>
      _ResponsiveExpenseTrackerState();
}

class _ResponsiveExpenseTrackerState extends State<ResponsiveExpenseTracker> {
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
  double totalExpense = 0.0;
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  String _selectedDateFilter = 'All Time';

  bool get _isDark {
    final themeMode = widget.themeModeNotifier.value;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    return themeMode == 'system'
        ? platformBrightness == Brightness.dark
        : themeMode == 'dark';
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? expensesString = prefs.getString('expenses');
    double budget = prefs.getDouble('budgetLimit') ?? 2000.0;
    String curr = prefs.getString('currency') ?? '৳';

    setState(() {
      _budgetLimit = budget;
      _currency = curr;
      if (expensesString != null) {
        List<dynamic> jsonList = jsonDecode(expensesString);
        _expense = jsonList.map((json) => Expense.fromJson(json)).toList();
        totalExpense = _expense.fold(0, (sum, item) => sum + item.amount);
      }
    });
  }

  Future<void> _saveExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'expenses',
      jsonEncode(_expense.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveBudgetLimit(double limit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budgetLimit', limit);
  }

  Future<void> _saveCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Groceries':
        return Icons.local_grocery_store_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Entertainment':
        return Icons.movie_creation_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Housing':
        return Icons.home_rounded;
      case 'Healthcare':
        return Icons.medical_services_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Insurance':
        return Icons.health_and_safety_rounded;
      case 'Savings':
        return Icons.savings_rounded;
      case 'Personal Care':
        return Icons.face_retouching_natural_rounded;
      case 'Travel':
        return Icons.flight_takeoff_rounded;
      case 'Gifts':
        return Icons.card_giftcard_rounded;
      case 'Miscellaneous':
        return Icons.category_rounded;
      default:
        return Icons.money_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFFA726);
      case 'Groceries':
        return const Color(0xFF66BB6A);
      case 'Transport':
        return const Color(0xFF42A5F5);
      case 'Entertainment':
        return const Color(0xFFAB47BC);
      case 'Bills':
        return const Color(0xFFEF5350);
      case 'Shopping':
        return const Color(0xFFEC407A);
      case 'Housing':
        return const Color(0xFF8D6E63);
      case 'Healthcare':
        return const Color(0xFF26A69A);
      case 'Education':
        return const Color(0xFF5C6BC0);
      case 'Insurance':
        return const Color(0xFF789262);
      case 'Savings':
        return const Color(0xFF4DB6AC);
      case 'Personal Care':
        return const Color(0xFFFF7043);
      case 'Travel':
        return const Color(0xFF29B6F6);
      case 'Gifts':
        return const Color(0xFFBA68C8);
      case 'Miscellaneous':
        return const Color(0xFF90A4AE);
      default:
        return Colors.grey;
    }
  }

  Future<void> _showForm({Expense? existingExpense, int? index, String? defaultFolder}) async {
    String selectedCategory = existingExpense?.category ?? categories.first;
    TextEditingController titleController = TextEditingController(
      text: existingExpense?.title ?? '',
    );
    TextEditingController amountController = TextEditingController(
      text: existingExpense != null ? existingExpense.amount.toString() : '',
    );
    TextEditingController folderController = TextEditingController(
      text: existingExpense?.folderName ?? defaultFolder ?? '',
    );
    DateTime expenseDateTime = existingExpense?.date ?? DateTime.now();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      existingExpense != null ? "Edit Expense" : "Add Expense",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: folderController,
                      decoration: InputDecoration(
                        labelText: 'Folder Name (Optional)',
                        prefixIcon: const Icon(Icons.folder_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: categories.length,
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final isSelected = selectedCategory == cat;
                          final catColor = _getCategoryColor(cat);
                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedCategory = cat;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? catColor.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? catColor
                                          : Colors.grey.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getCategoryIcon(cat),
                                    color: isSelected ? catColor : Colors.grey,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isSelected ? catColor : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transaction Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: expenseDateTime,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                expenseDateTime = pickedDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                          label: Text(
                            DateFormat.yMMMd().format(expenseDateTime),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty &&
                              double.tryParse(amountController.text) != null) {
                            if (existingExpense != null && index != null) {
                              _editExpense(
                                index,
                                titleController.text,
                                double.parse(amountController.text),
                                expenseDateTime,
                                selectedCategory,
                                folderController.text.trim().isNotEmpty ? folderController.text.trim() : null,
                              );
                            } else {
                              _addExpense(
                                titleController.text,
                                double.parse(amountController.text),
                                expenseDateTime,
                                selectedCategory,
                                folderController.text.trim().isNotEmpty ? folderController.text.trim() : null,
                              );
                            }
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          existingExpense != null
                              ? "Update Expense"
                              : "Add Expense",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _setBudgetLimit() {
    TextEditingController budgetController = TextEditingController(
      text: _budgetLimit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Set Budget Limit"),
          content: TextField(
            controller: budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Budget Limit',
              prefixIcon: const Icon(Icons.account_balance_wallet_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                double? newLimit = double.tryParse(budgetController.text);
                if (newLimit != null) {
                  setState(() {
                    _budgetLimit = newLimit;
                  });
                  if (context.mounted) Navigator.pop(context);
                  await _saveBudgetLimit(newLimit);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Set"),
            ),
          ],
        );
      },
    );
  }

  void _addExpense(
    String title,
    double amount,
    DateTime date,
    String category,
    String? folderName,
  ) {
    setState(() {
      _expense.add(
        Expense(title: title, amount: amount, date: date, category: category, folderName: folderName),
      );
      totalExpense += amount;
      _saveExpenses();
    });
  }

  void _editExpense(
    int index,
    String title,
    double amount,
    DateTime date,
    String category,
    String? folderName,
  ) {
    setState(() {
      totalExpense -= _expense[index].amount;
      _expense[index] = Expense(
        title: title,
        amount: amount,
        date: date,
        category: category,
        folderName: folderName,
      );
      totalExpense += amount;
      _saveExpenses();
    });
  }

  void _confirmDeleteExpense(int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteExpense(index);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(int index) {
    setState(() {
      totalExpense -= _expense[index].amount;
      _expense.removeAt(index);
      _saveExpenses();
    });
  }

  List<Expense> get _filteredExpenses {
    List<Expense> filtered = _expense;

    // 1. Filter by category
    if (_selectedFilter != 'All') {
      filtered = filtered.where((e) => e.category == _selectedFilter).toList();
    }

    // 2. Filter by date range
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDateFilter == 'Today') {
      filtered =
          filtered.where((e) {
            return e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day;
          }).toList();
    } else if (_selectedDateFilter == 'This Week') {
      final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
      filtered =
          filtered.where((e) {
            final eDateZero = DateTime(e.date.year, e.date.month, e.date.day);
            return eDateZero.isAfter(startOfWeek) ||
                eDateZero.isAtSameMomentAs(startOfWeek);
          }).toList();
    } else if (_selectedDateFilter == 'This Month') {
      filtered =
          filtered.where((e) {
            return e.date.year == now.year && e.date.month == now.month;
          }).toList();
    } else if (_selectedDateFilter == 'This Year') {
      filtered =
          filtered.where((e) {
            return e.date.year == now.year;
          }).toList();
    }

    // 3. Sort (create a new list to avoid side effects on _expense if no filtering occurred)
    filtered = List.from(filtered);
    if (_selectedSort == 'Newest') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return filtered;
  }



  Widget _buildChartCard() {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              _isDark
                  ? const Color(0x7F334155)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child:
          _expense.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 40,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "No expense data recorded",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ExpensePieChart(expenses: _expense, currency: _currency),
    );
  }



  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              "No matching transactions",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildDrawer(String themeModeSetting) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SpendWise',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder_copy_rounded, color: Theme.of(context).colorScheme.primary),
            title: const Text('Folders'),
            subtitle: const Text('Manage expense categories'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderListScreen(
                    expenses: _expense,
                    currency: _currency,
                    onExpensesUpdated: () {
                      setState(() {
                         totalExpense = _expense.fold(0, (sum, item) => sum + item.amount);
                         _saveExpenses();
                      });
                    },
                    onShowForm: ({Expense? existingExpense, String? defaultFolder}) async {
                      int? idx;
                      if (existingExpense != null) {
                        idx = _expense.indexOf(existingExpense);
                      }
                      await _showForm(
                        existingExpense: existingExpense,
                        index: idx,
                        defaultFolder: defaultFolder,
                      );
                      // After form closes, force update
                      setState(() {
                         totalExpense = _expense.fold(0, (sum, item) => sum + item.amount);
                      });
                    },
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              themeModeSetting == 'system'
                  ? Icons.brightness_auto_rounded
                  : (_isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
            ),
            title: const Text('Theme Mode'),
            subtitle: Text(
              themeModeSetting == 'system'
                  ? 'System Default'
                  : (themeModeSetting == 'dark' ? 'Dark Mode' : 'Light Mode'),
            ),
            onTap: () async {
              String nextMode;
              if (themeModeSetting == 'system') {
                nextMode = 'light';
              } else if (themeModeSetting == 'light') {
                nextMode = 'dark';
              } else {
                nextMode = 'system';
              }
              widget.themeModeNotifier.value = nextMode;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('themeMode', nextMode);
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: const Text('Budget Limit'),
            subtitle: Text('Current: $_currency${_budgetLimit.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context); // Close drawer before opening dialog
              _setBudgetLimit();
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments_rounded),
            title: const Text('Currency'),
            subtitle: Text('Current: $_currency'),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.arrow_drop_down_rounded),
              tooltip: 'Select Currency',
              onSelected: (value) async {
                setState(() => _currency = value);
                await _saveCurrency(value);
              },
              itemBuilder: (context) => ['৳', '\$', '€', '₹', '£']
                  .map((c) => PopupMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double remainingBalance = _budgetLimit - totalExpense;
    final double progressPercent =
        _budgetLimit > 0 ? (totalExpense / _budgetLimit).clamp(0.0, 1.0) : 0.0;
    Color progressColor = Colors.green;
    if (progressPercent >= 0.9) {
      progressColor = Colors.redAccent;
    } else if (progressPercent >= 0.7) {
      progressColor = Colors.orangeAccent;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 720;

    return ValueListenableBuilder<String>(
      valueListenable: widget.themeModeNotifier,
      builder: (context, themeModeSetting, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text(
              "SpendWise",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  themeModeSetting == 'system'
                      ? Icons.brightness_auto_rounded
                      : (_isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded),
                ),
                onPressed: () async {
                  String nextMode;
                  if (themeModeSetting == 'system') {
                    nextMode = 'light';
                  } else if (themeModeSetting == 'light') {
                    nextMode = 'dark';
                  } else {
                    nextMode = 'system';
                  }
                  widget.themeModeNotifier.value = nextMode;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('themeMode', nextMode);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          nextMode == 'system'
                              ? 'System Default'
                              : (nextMode == 'dark' ? 'Dark Mode' : 'Light Mode'),
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                tooltip: 'Toggle Theme',
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: _buildDrawer(themeModeSetting),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showForm,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              "Add Expense",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: isWide
                ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Balance and Chart Cards
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          BalanceCard(
                            currency: _currency,
                            remainingBalance: remainingBalance,
                            totalExpense: totalExpense,
                            budgetLimit: _budgetLimit,
                            progressPercent: progressPercent,
                            progressColor: progressColor,
                          ),
                          _buildChartCard(),
                        ],
                      ),
                    ),
                  ),
                  // Divider line
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: _isDark
                        ? const Color(0x4C334155)
                        : const Color(0xFFE2E8F0),
                  ),
                  // Right Column: Filters and Transactions
                  Expanded(
                    flex: 6,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: FilterSortRow(
                            selectedFilter: _selectedFilter,
                            selectedSort: _selectedSort,
                            categories: categories,
                            onFilterChanged: (val) {
                              setState(() => _selectedFilter = val);
                            },
                            onSortChanged: (val) {
                              setState(() => _selectedSort = val);
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              top: 16.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Transactions",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _isDark
                                              ? const Color(0x7F334155)
                                              : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedDateFilter,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                      icon: const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      dropdownColor: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(12),
                                      items:
                                          [
                                            'All Time',
                                            'Today',
                                            'This Week',
                                            'This Month',
                                            'This Year',
                                          ]
                                          .map(
                                            (c) => DropdownMenuItem(
                                              value: c,
                                              child: Text(c),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _selectedDateFilter = val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_filteredExpenses.isEmpty)
                          SliverToBoxAdapter(child: _buildEmptyState())
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final e = _filteredExpenses[index];
                              return TransactionItem(
                                expense: e,
                                currency: _currency,
                                onEdit: () => _showForm(
                                  existingExpense: e,
                                  index: _expense.indexOf(e),
                                ),
                                onDelete: () => _confirmDeleteExpense(
                                  _expense.indexOf(e),
                                ),
                                categoryIcon: _getCategoryIcon(e.category),
                                categoryColor: _getCategoryColor(e.category),
                              );
                            }, childCount: _filteredExpenses.length),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  // 1. Compact Dropdown Filters Row (Placed FIRST, before balance card)
                  SliverToBoxAdapter(
                    child: FilterSortRow(
                      selectedFilter: _selectedFilter,
                      selectedSort: _selectedSort,
                      categories: categories,
                      onFilterChanged: (val) {
                        setState(() => _selectedFilter = val);
                      },
                      onSortChanged: (val) {
                        setState(() => _selectedSort = val);
                      },
                    ),
                  ),
                  // 2. Balance Card
                  SliverToBoxAdapter(
                    child: BalanceCard(
                      currency: _currency,
                      remainingBalance: remainingBalance,
                      totalExpense: totalExpense,
                      budgetLimit: _budgetLimit,
                      progressPercent: progressPercent,
                      progressColor: progressColor,
                    ),
                  ),
                  // 3. Chart Card
                  SliverToBoxAdapter(child: _buildChartCard()),
                  // 4. Transactions Title Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 16.0,
                        bottom: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Transactions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _isDark
                                        ? const Color(0x7F334155)
                                        : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedDateFilter,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                icon: const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                dropdownColor: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                                items:
                                    [
                                      'All Time',
                                      'Today',
                                      'This Week',
                                      'This Month',
                                      'This Year',
                                    ]
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedDateFilter = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 5. Transactions List or Empty State
                  if (_filteredExpenses.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final e = _filteredExpenses[index];
                        return TransactionItem(
                          expense: e,
                          currency: _currency,
                          onEdit: () => _showForm(
                            existingExpense: e,
                            index: _expense.indexOf(e),
                          ),
                          onDelete: () => _confirmDeleteExpense(
                            _expense.indexOf(e),
                          ),
                          categoryIcon: _getCategoryIcon(e.category),
                          categoryColor: _getCategoryColor(e.category),
                        );
                      }, childCount: _filteredExpenses.length),
                    ),
                  // Bottom padding so items don't get covered by FAB
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
      ),
    );
  },
);
}
}
