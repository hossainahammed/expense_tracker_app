import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'expense_modal.dart';
import 'widget/expense_pie_chart.dart';
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

  void _showForm({Expense? existingExpense, int? index}) {
    String selectedCategory = existingExpense?.category ?? categories.first;
    TextEditingController titleController = TextEditingController(
      text: existingExpense?.title ?? '',
    );
    TextEditingController amountController = TextEditingController(
      text: existingExpense != null ? existingExpense.amount.toString() : '',
    );
    DateTime expenseDateTime = existingExpense?.date ?? DateTime.now();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
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
                              );
                            } else {
                              _addExpense(
                                titleController.text,
                                double.parse(amountController.text),
                                expenseDateTime,
                                selectedCategory,
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
  ) {
    setState(() {
      _expense.add(
        Expense(title: title, amount: amount, date: date, category: category),
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
  ) {
    setState(() {
      totalExpense -= _expense[index].amount;
      _expense[index] = Expense(
        title: title,
        amount: amount,
        date: date,
        category: category,
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
    List<Expense> filtered =
        _selectedFilter == 'All'
            ? _expense
            : _expense.where((e) => e.category == _selectedFilter).toList();

    if (_selectedSort == 'Newest') {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    } else {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    }
    return filtered;
  }

  Widget _buildBalanceCard(
    double remainingBalance,
    double progressPercent,
    Color progressColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.isDarkMode
                  ? [const Color(0xFF4F46E5), const Color(0xFF6D28D9)]
                  : [const Color(0xFF6366F1), const Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (widget.isDarkMode
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF6366F1))
                .withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Available Balance",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (remainingBalance < 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Limit Exceeded",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$_currency${remainingBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Spent",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_currency${totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Budget",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_currency${_budgetLimit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
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
              widget.isDarkMode
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

  Widget _buildFilterAndSortRow() {
    final isDarkMode = widget.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 12.0,
        bottom: 4.0,
      ),
      child: Row(
        children: [
          // Category Filter Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isDarkMode
                          ? const Color(0x7F334155)
                          : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.filter_alt_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  dropdownColor: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  items:
                      ['All', ...categories]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFilter = val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort Dropdown
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isDarkMode
                          ? const Color(0x7F334155)
                          : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSort,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.sort_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  dropdownColor: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  items:
                      ['Newest', 'Amount']
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSort = val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildTransactionItem(Expense e) {
    final catColor = _getCategoryColor(e.category);
    final originalIndex = _expense.indexOf(e);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isDarkMode
                  ? const Color(0x4C334155)
                  : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(e.category), color: catColor, size: 24),
        ),
        title: Text(
          e.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(
                DateFormat.yMMMd().format(e.date),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      widget.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  e.category,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-$_currency${e.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                size: 20,
                color: Colors.grey,
              ),
              onSelected: (action) {
                if (action == 'edit') {
                  _showForm(existingExpense: e, index: originalIndex);
                } else if (action == 'delete') {
                  _confirmDeleteExpense(originalIndex);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double remainingBalance = _budgetLimit - totalExpense;
    final double progressPercent =
        _budgetLimit > 0 ? (totalExpense / _budgetLimit).clamp(0.0, 1.0) : 0.0;

    Color progressColor = Colors.teal;
    if (progressPercent >= 0.9) {
      progressColor = Colors.redAccent;
    } else if (progressPercent >= 0.7) {
      progressColor = Colors.orangeAccent;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "Expense Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _setBudgetLimit,
            tooltip: 'Budget Limit',
          ),
          PopupMenuButton<String>(
            icon: Text(
              _currency,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            tooltip: 'Select Currency',
            onSelected: (value) async {
              setState(() => _currency = value);
              await _saveCurrency(value);
            },
            itemBuilder:
                (context) =>
                    ['৳', '\$', '€', '₹', '£']
                        .map((c) => PopupMenuItem(value: c, child: Text(c)))
                        .toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
        child: CustomScrollView(
          slivers: [
            // 1. Compact Dropdown Filters Row (Placed FIRST, before balance card)
            SliverToBoxAdapter(child: _buildFilterAndSortRow()),
            // 2. Balance Card
            SliverToBoxAdapter(
              child: _buildBalanceCard(
                remainingBalance,
                progressPercent,
                progressColor,
              ),
            ),
            // 3. Chart Card
            SliverToBoxAdapter(child: _buildChartCard()),
            // 4. Transactions Title Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  "Transactions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  return _buildTransactionItem(e);
                }, childCount: _filteredExpenses.length),
              ),
            // Bottom padding so items don't get covered by FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}
