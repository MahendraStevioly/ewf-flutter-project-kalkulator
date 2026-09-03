import '../../../../core/services/api_service.dart';
import '../../../../core/utils/number_formatter.dart';

/// ViewModel untuk Gold Calculator
/// Mengelola semua business logic dan state untuk kalkulasi emas fisik
class GoldCalculatorViewModel {
  final ApiService _apiService = ApiService();

  // Input values
  String hargaBeli = '';
  String hargaJual = '';
  String modalAwalInput = '';
  String kursUsdIdrInput = '18000';

  // Parameters
  double modalAwal = 0;
  double kursUsdIdr = 18000;
  double konversiTozG = 31.1;

  // Live Exchange Rate State
  bool isFetchingRate = false;
  double? liveRate;

  /// Mengambil kurs USD/IDR secara live dari internet
  Future<double?> fetchLiveExchangeRate() async {
    isFetchingRate = true;
    final rate = await _apiService.fetchLiveUsdIdrRate();
    if (rate != null && rate > 0) {
      liveRate = rate;
      kursUsdIdr = rate;
      kursUsdIdrInput = rate.toStringAsFixed(0);
    }
    isFetchingRate = false;
    return rate;
  }

  // Result state
  Map<String, dynamic>? hasil;
  String? errorMessage;
  bool isCalculating = false;

  /// Helper untuk parse formatted number string
  /// Mendukung format USD (2,700.50) dan IDR (100.000.000,00)
  double? parseFormattedNumber(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    String cleaned = input.replaceAll('Rp', '').replaceAll('\$', '').replaceAll(' ', '').trim();
    if (cleaned.isEmpty) return null;
    final result = parseDecimal(cleaned);
    return result == 0 && cleaned != '0' && cleaned != '0.00' && cleaned != '0,00' ? null : result;
  }

  /// Validasi input values
  bool validateInputs() {
    if (hargaBeli.trim().isEmpty || hargaJual.trim().isEmpty) {
      errorMessage = 'Mohon isi Harga Beli dan Harga Jual';
      return false;
    }

    if (modalAwalInput.trim().isEmpty) {
      errorMessage = 'Mohon isi Modal Awal';
      return false;
    }

    final hb = parseFormattedNumber(hargaBeli);
    final hj = parseFormattedNumber(hargaJual);
    final modal = parseFormattedNumber(modalAwalInput);
    final kurs = parseFormattedNumber(kursUsdIdrInput) ?? 18000.0;

    if (hb == null || hj == null || hb <= 0 || hj <= 0) {
      errorMessage = 'Harga Beli dan Harga Jual harus berupa angka positif';
      return false;
    }

    if (modal == null || modal <= 0) {
      errorMessage = 'Modal Awal harus berupa angka positif';
      return false;
    }

    if (kurs <= 0) {
      errorMessage = 'Kurs USD/IDR harus berupa angka positif';
      return false;
    }

    errorMessage = null;
    return true;
  }

  /// Hitung keuntungan emas fisik
  /// Formula:
  /// HHB = HB × Kurs ÷ TOZ
  /// HHJ = HJ × Kurs ÷ TOZ
  /// Selisih = HHJ − HHB
  /// Gram Emas = Modal ÷ HHB
  /// Keuntungan Bersih = Gram Emas × Selisih
  void calculate() {
    if (!validateInputs()) {
      return;
    }

    isCalculating = true;

    try {
      final hb = parseFormattedNumber(hargaBeli)!;
      final hj = parseFormattedNumber(hargaJual)!;
      final modal = parseFormattedNumber(modalAwalInput)!;
      final kurs = parseFormattedNumber(kursUsdIdrInput) ?? 18000.0;

      modalAwal = modal;
      kursUsdIdr = kurs;

      // Hitungan berdasarkan formula
      final hhb = (hb * kursUsdIdr) / konversiTozG;
      final hhj = (hj * kursUsdIdr) / konversiTozG;
      final selisih = hhj - hhb;
      final gramEmas = modalAwal / hhb;
      final keuntunganBersih = gramEmas * selisih;

      hasil = {
        'hb': hb,
        'hj': hj,
        'modalAwal': modalAwal,
        'kurs': kursUsdIdr,
        'hhb': hhb,
        'hhj': hhj,
        'selisih': selisih,
        'gramEmas': gramEmas,
        'keuntunganBersih': keuntunganBersih,
      };

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      hasil = null;
    }

    isCalculating = false;
  }

  /// Format rupiah (2 desimal tanpa pembulatan / dipotong desimalnya)
  String formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0,00';
    final isNegative = value < 0;
    final absVal = value.abs();
    final str = absVal.toStringAsFixed(8);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    final decPart = parts[1].substring(0, 2);
    final prefix = isNegative ? '-Rp' : 'Rp';
    return '$prefix$intPart,$decPart';
  }

  /// Format gram (2 desimal tanpa pembulatan / dipotong desimalnya)
  String formatGram(double value) {
    if (value.isNaN || value.isInfinite) return '0,00 gram';
    final isNegative = value < 0;
    final absVal = value.abs();
    final str = absVal.toStringAsFixed(8);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    final decPart = parts[1].substring(0, 2);
    final prefix = isNegative ? '-' : '';
    return '$prefix$intPart,$decPart gram';
  }

  /// Reset semua state
  void reset() {
    hargaBeli = '';
    hargaJual = '';
    modalAwalInput = '';
    kursUsdIdrInput = '18000';
    modalAwal = 0;
    kursUsdIdr = 18000;
    hasil = null;
    errorMessage = null;
    isCalculating = false;
  }

  /// Update modal awal
  void setModalAwal(double value) {
    modalAwal = value;
    modalAwalInput = value.toString();
  }

  /// Update kurs
  void setKursUsdIdr(double value) {
    kursUsdIdr = value;
    kursUsdIdrInput = value.toString();
  }

  /// Update konversi TOZ
  void setKonversiTozG(double value) {
    konversiTozG = value;
  }
}
