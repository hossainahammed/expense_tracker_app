import 'package:flutter/material.dart';
import '../expense_modal.dart';
import 'folder_detail_screen.dart';

class FolderListScreen extends StatefulWidget {
  final List<Expense> expenses;
  final String currency;
  final VoidCallback onExpensesUpdated;

  const FolderListScreen({
    super.key,
    required this.expenses,
    required this.currency,
    required this.onExpensesUpdated,
  });

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  Map<String, List<Expense>> _getGroupedExpenses() {
    final Map<String, List<Expense>> grouped = {};
    for (var expense in widget.expenses) {
      final folderName = (expense.folderName?.trim().isNotEmpty == true)
          ? expense.folderName!.trim()
          : 'Uncategorized';
      if (!grouped.containsKey(folderName)) {
        grouped[folderName] = [];
      }
      grouped[folderName]!.add(expense);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _getGroupedExpenses();
    final folderNames = groupedExpenses.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Folders'),
      ),
      body: folderNames.isEmpty
          ? const Center(
              child: Text(
                'No expenses found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: folderNames.length,
              itemBuilder: (context, index) {
                final folderName = folderNames[index];
                final folderExpenses = groupedExpenses[folderName]!;
                final total = folderExpenses.fold(
                    0.0, (sum, item) => sum + item.amount);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        folderName == 'Uncategorized'
                            ? Icons.folder_off_rounded
                            : Icons.folder_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      folderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${folderExpenses.length} transaction${folderExpenses.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: Text(
                      '${widget.currency}${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FolderDetailScreen(
                            folderName: folderName,
                            expenses: folderExpenses,
                            allExpenses: widget.expenses,
                            currency: widget.currency,
                            onExpensesUpdated: () {
                              widget.onExpensesUpdated();
                              setState(() {}); // refresh the list
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
