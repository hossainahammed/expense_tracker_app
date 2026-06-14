import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../Expense_modal.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Expense> expenses;
  final String currency;

  const ExpensePieChart(
      {super.key, required this.expenses, required this.currency});

  @override
  Widget build(BuildContext context) {
    // Calculate total sum of all expenses
    final double total = expenses.fold(
        0.0, (sum, expense) => sum + expense.amount);

    final Map<String, double> dataMap = {};
    for (var expense in expenses) {
      dataMap.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }

    final List<PieChartSectionData> sections = dataMap.entries.map((entry) {
      final double value = entry.value;
      final String category = entry.key;
      final Color color = _getCategoryColor(category);
      // Calculate percentage for the category
      final double percentage = total == 0 ? 0 : (value / total) * 100;
      return PieChartSectionData(
        color: color,
        value: value,
        // Show value as percentage with one decimal place and % sign
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    List<Widget> legendWidgets = dataMap.entries.map((entry) {
      final String category = entry.key;
      final Color color = _getCategoryColor(category);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: color,
              ),
            ),
            SizedBox(width: 6),
            // Wrap text to handle overflow
            Expanded(
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12, // Reduced font size
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 1, // Limit to one line
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
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        // Legend on the right
        Container(
          width: 100,
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: legendWidgets,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Color(0xFFFFA726); // Orange - appetizing and warm
      case 'Groceries':
        return Color(0xFF66BB6A); // Green - fresh and natural
      case 'Transport':
        return Color(0xFF42A5F5); // Blue - calm and reliable
      case 'Entertainment':
        return Color(0xFFAB47BC); // Purple - fun and energetic
      case 'Bills':
        return Color(0xFFEF5350); // Red - important and urgent
      case 'Shopping':
        return Color(0xFFEC407A); // Pink - trendy and eye-catching
      case 'Housing':
        return Color(0xFF8D6E63); // Brown - stable and grounded
      case 'Healthcare':
        return Color(0xFF26A69A); // Teal - health and wellness
      case 'Education':
        return Color(0xFF5C6BC0); // Indigo - knowledge and trust
      case 'Insurance':
        return Color(0xFF789262); // Olive green - security and safety
      case 'Savings':
        return Color(0xFF4DB6AC); // Light teal - growth and stability
      case 'Personal Care':
        return Color(0xFFFF7043); // Deep orange - self-care and warmth
      case 'Travel':
        return Color(0xFF29B6F6); // Light blue - freedom and exploration
      case 'Gifts':
        return Color(0xFFBA68C8); // Light purple - generosity and kindness
      case 'Miscellaneous':
        return Color(0xFF90A4AE); // Blue grey - neutral and miscellaneous
      default:
        return Colors.grey; // Fallback color
    }
  }
}

//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case 'Food':
//         return Colors.redAccent;
//       case 'Transport':
//         return Colors.blueAccent;
//       case 'Entertainment':
//         return Colors.green;
//       case 'Bills':
//         return Colors.orange;
//       case 'Shopping':
//         return Colors.pinkAccent;
//       case 'Hospital':
//         return Colors.red;
//       case 'Medichine':
//         return Colors.lightBlue;
//       default:
//         return Colors.grey;
//     }
//   }
// }