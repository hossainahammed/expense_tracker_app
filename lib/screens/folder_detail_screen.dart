import 'package:flutter/material.dart';
import '../expense_modal.dart';
import '../widget/pdf_generator.dart';
import '../widget/transaction_item.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  final List<Expense> expenses;
  final List<Expense> allExpenses;
  final String currency;
  final VoidCallback onExpensesUpdated;
  final Future<void> Function({Expense? existingExpense, String? defaultFolder}) onShowForm;

  const FolderDetailScreen({
    super.key,
    required this.folderName,
    required this.expenses,
    required this.allExpenses,
    required this.currency,
    required this.onExpensesUpdated,
    required this.onShowForm,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood_rounded;
      case 'Groceries': return Icons.local_grocery_store_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Entertainment': return Icons.movie_creation_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Housing': return Icons.home_rounded;
      case 'Healthcare': return Icons.medical_services_rounded;
      case 'Education': return Icons.school_rounded;
      case 'Insurance': return Icons.health_and_safety_rounded;
      case 'Savings': return Icons.savings_rounded;
      case 'Personal Care': return Icons.face_retouching_natural_rounded;
      case 'Travel': return Icons.flight_takeoff_rounded;
      case 'Gifts': return Icons.card_giftcard_rounded;
      case 'Miscellaneous': return Icons.category_rounded;
      default: return Icons.money_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFFFA726);
      case 'Groceries': return const Color(0xFF66BB6A);
      case 'Transport': return const Color(0xFF42A5F5);
      case 'Entertainment': return const Color(0xFFAB47BC);
      case 'Bills': return const Color(0xFFEF5350);
      case 'Shopping': return const Color(0xFFEC407A);
      case 'Housing': return const Color(0xFF8D6E63);
      case 'Healthcare': return const Color(0xFF26A69A);
      case 'Education': return const Color(0xFF5C6BC0);
      case 'Insurance': return const Color(0xFF789262);
      case 'Savings': return const Color(0xFF4DB6AC);
      case 'Personal Care': return const Color(0xFFFF7043);
      case 'Travel': return const Color(0xFF29B6F6);
      case 'Gifts': return const Color(0xFFBA68C8);
      case 'Miscellaneous': return const Color(0xFF90A4AE);
      default: return Colors.grey;
    }
  }

  void _confirmDeleteExpense(Expense expense) {
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
                _deleteExpense(expense);
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

  void _deleteExpense(Expense expense) {
    setState(() {
      widget.expenses.remove(expense);
      widget.allExpenses.remove(expense);
      widget.onExpensesUpdated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Generate PDF',
            onPressed: () {
              PdfGenerator.generateAndPrintFolderReport(
                widget.folderName,
                widget.expenses,
                widget.currency,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Folder Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.currency}${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.expenses.isEmpty
                ? const Center(
                    child: Text(
                      'No expenses in this folder',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = widget.expenses[index];
                      return TransactionItem(
                        expense: expense,
                        currency: widget.currency,
                        onEdit: () async {
                          await widget.onShowForm(
                            existingExpense: expense,
                            defaultFolder: widget.folderName,
                          );
                          // The `onExpensesUpdated` from `FolderListScreen` triggers a rebuild there,
                          // but since we passed the exact `widget.expenses` list, and `ResponsiveExpenseTracker`
                          // modifies `_expense` which updates references, we might need to filter again.
                          // Wait, `widget.expenses` is a list created in `FolderListScreen`'s `_getGroupedExpenses`.
                          // So when the global list updates, `widget.expenses` here DOES NOT automatically get the new item
                          // until `FolderListScreen` re-runs `_getGroupedExpenses`.
                          // But we can trigger `setState` and update our local `widget.expenses` 
                          // by filtering `widget.allExpenses` again!
                          setState(() {
                            widget.expenses.clear();
                            widget.expenses.addAll(
                              widget.allExpenses.where((e) {
                                final folder = (e.folderName?.trim().isNotEmpty == true) ? e.folderName!.trim() : 'Uncategorized';
                                return folder == widget.folderName;
                              })
                            );
                            widget.onExpensesUpdated();
                          });
                        },
                        onDelete: () => _confirmDeleteExpense(expense),
                        categoryIcon: _getCategoryIcon(expense.category),
                        categoryColor: _getCategoryColor(expense.category),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await widget.onShowForm(defaultFolder: widget.folderName);
          setState(() {
            widget.expenses.clear();
            widget.expenses.addAll(
              widget.allExpenses.where((e) {
                final folder = (e.folderName?.trim().isNotEmpty == true) ? e.folderName!.trim() : 'Uncategorized';
                return folder == widget.folderName;
              })
            );
            widget.onExpensesUpdated();
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Expense",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
