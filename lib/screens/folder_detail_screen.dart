import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../expense_modal.dart';
import '../widget/pdf_generator.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  final List<Expense> expenses;
  final List<Expense> allExpenses;
  final String currency;
  final VoidCallback onExpensesUpdated;

  const FolderDetailScreen({
    super.key,
    required this.folderName,
    required this.expenses,
    required this.allExpenses,
    required this.currency,
    required this.onExpensesUpdated,
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
                      final catColor = _getCategoryColor(expense.category);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: catColor.withValues(alpha: 0.15),
                            child: Icon(_getCategoryIcon(expense.category), color: catColor),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(DateFormat.yMMMd().format(expense.date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.currency}${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  _deleteExpense(expense);
                                },
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
    );
  }
}
