// ============================================================
//  APP CHIP — Filter ke gol buttons ("All", "Programming" ...)
// ============================================================
import 'package:flutter/material.dart';

import '../config/app_colors.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected; // true = orange (chuna hua)
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chips ki aadi (horizontal) scroll hone wali line
class ChipBar extends StatelessWidget {
  const ChipBar({super.key, required this.labels, required this.selected, required this.onSelected});

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String label = labels[index];
          return AppChip(
            label: label,
            selected: label == selected,
            onTap: () => onSelected(label),
          );
        },
      ),
    );
  }
}
