import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class CategorySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static IconData iconFor(String category) {
    switch (category) {
      case 'Facilities':
        return Icons.apartment;
      case 'Water':
        return Icons.water_drop_outlined;
      case 'Electricity':
        return Icons.bolt;
      case 'Safety':
        return Icons.shield_outlined;
      case 'Sanitation':
        return Icons.delete_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.categories.map((category) {
        final isSelected = category == selected;
        return GestureDetector(
          onTap: () => onChanged(category),
          child: Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : const Color(0xFFF1F0FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  iconFor(category),
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
                const SizedBox(height: 6),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}