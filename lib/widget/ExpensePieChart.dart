import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Expense_modal.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenses;
  final String currency;

  const ExpensePieChart({
    super.key,
    required this.expenses,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total sum of all expenses
    final double total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final Map<String, double> dataMap = {};
    for (var expense in expenses) {
      dataMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final List<PieChartSectionData> sections = dataMap.entries.map((entry) {
      final double value = entry.value;
      final String category = entry.key;
      final Color color = _getCategoryColor(category);
      final double percentage = total == 0 ? 0 : (value / total) * 100;

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 20, // Slimmer sections for elegant donut look
        showTitle: true,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    List<Widget> legendWidgets = dataMap.entries.map((entry) {
      final String category = entry.key;
      final double value = entry.value;
      final Color color = _getCategoryColor(category);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$currency${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pie chart on the left
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 3,
              centerSpaceRadius: 40, // Elegant donut spacing
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Scrollable Legend on the right to prevent overflow
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: legendWidgets,
              ),
            ),
          ),
        ),
      ],
    );
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
}