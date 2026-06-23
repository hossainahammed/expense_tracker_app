import 'package:flutter/material.dart';

class FilterSortRow extends StatelessWidget {
  final String selectedFilter;
  final String selectedSort;
  final List<String> categories;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;

  const FilterSortRow({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.categories,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                  color: isDarkMode
                      ? const Color(0x7F334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.filter_alt_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  dropdownColor: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  items: ['All', ...categories]
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onFilterChanged(val);
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
                  color: isDarkMode
                      ? const Color(0x7F334155)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSort,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.sort_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  dropdownColor: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(14),
                  items: ['Newest', 'Amount']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) onSortChanged(val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
