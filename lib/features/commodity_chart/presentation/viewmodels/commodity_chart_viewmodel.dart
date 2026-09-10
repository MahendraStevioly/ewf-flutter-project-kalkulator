import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CommodityChartViewModel extends ChangeNotifier {
  // Secara default, saat layar dibuka, tampilkan Emas
  String _selectedSymbol = AppConstants.symbolGold;

  String get selectedSymbol => _selectedSymbol;

  // Fungsi ini dipanggil saat pengguna mengklik tab (Emas, Perak, Minyak, dll)
  void changeCommodity(String newSymbol) {
    if (_selectedSymbol != newSymbol) {
      _selectedSymbol = newSymbol;
      notifyListeners(); // Menyuruh UI update grafik
    }
  }
}