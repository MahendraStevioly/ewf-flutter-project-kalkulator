import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class ResultRow extends StatelessWidget {
  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withAlpha(30) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? AppColors.primary.withAlpha(120) : AppColors.lightGray,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: isHighlight ? AppColors.dark : AppColors.gray,
            ),
          ),
          Text(
            value,
            style: AppTypography.value.copyWith(
              color: isHighlight ? AppColors.primary : AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}
