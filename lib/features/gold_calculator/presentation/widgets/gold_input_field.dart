import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class GoldInputField extends StatelessWidget {
  const GoldInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.prefixText,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            prefixStyle: AppTypography.body.copyWith(color: AppColors.dark),
          ),
          style: AppTypography.body,
        ),
      ],
    );
  }
}
