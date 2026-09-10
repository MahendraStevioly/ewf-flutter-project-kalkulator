import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/number_formatter.dart'; 

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

  // Render format yang bener pas halaman pertama dibuka
  String _formatInitialValue(String val) {
    if (val.isEmpty) return '';
    String cleaned = val.replaceAll('.', ','); 
    final parts = cleaned.split(',');
    
    String integerPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');
    String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    
    if (parts.length > 1) {
      String fractionPart = parts[1].replaceAll(RegExp(r'[^\d]'), '');
      return '$formattedInteger,$fractionPart';
    }
    return formattedInteger;
  }

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
          initialValue: _formatInitialValue(value),
          onChanged: (formattedValue) {
            // Bersihin text biar gampang masuk database (hapus titik, ubah koma jadi titik)
            // Cth UI: "4.100,50" -> dikirim ke backend/onChanged jadi "4100.50"
            final rawValue = formattedValue.replaceAll('.', '').replaceAll(',', '.');
            onChanged(rawValue);
          },
          // Paksa keyboard nampilin tombol koma/titik buat desimal
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            // Pake formatter super yang udah kita beresin kursornya
            IndonesianNumberInputFormatter(
              allowFraction: true,
              maxFractionDigits: 3, 
            ),
          ],
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            prefixStyle: AppTypography.body.copyWith(
              color: AppColors.dark,
            ),
          ),
          style: AppTypography.body,
        ),
      ],
    );
  }
}