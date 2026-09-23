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
    String cleaned = input
        .replaceAll('Rp', '')
        .replaceAll('\$', '')
        .replaceAll(' ', '')
        .trim();
    if (cleaned.isEmpty) return null;
    final result = parseDecimal(cleaned);
    return result == 0 &&
            cleaned != '0' &&
            cleaned != '0.00' &&
            cleaned != '0,00'
        ? null
        : result;
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

    if (kurs <= 0) {
      errorMessage = 'Kurs USD/IDR harus berupa angka positif';
      return false;
    }

    errorMessage = null;
    return true;
  }

  /// Hitung keuntungan emas fisik
  /// Hitung keuntungan emas fisik
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

      modalAwal = modal.truncateToDouble();
      kursUsdIdr = kurs.truncateToDouble();

      // 1. Hitung harga beli dan selisih (dipotong sesuai tampilan rupiah tanpa desimal)
      final hhb = ((hb * kursUsdIdr) / konversiTozG).truncateToDouble();
      final hhj = ((hj * kursUsdIdr) / konversiTozG).truncateToDouble();
      final selisih = (hhj - hhb).truncateToDouble();

      // 2. Hitung gram emas (nilai mentah / panjang)
      final gramEmasRaw = modalAwal / hhb;
      
      // 3. KUNCI SINKRONISASI LAYAR & KALKULATOR MANUAL
      // Kita pangkas paksa gram emas menjadi 2 angka di belakang koma tanpa pembulatan.
      // Ini mensimulasikan apa yang dilihat user di fungsi formatGram().
      // Contoh: 10.12876 * 100 = 1012.876 -> di-truncate jadi 1012.0 -> dibagi 100 jadi 10.12
      final gramEmasLayar = (gramEmasRaw * 100).truncateToDouble() / 100;
      
      // 4. Hasil kali ini dijamin 100% SAMA PERSIS dengan ketikan di kalkulator fisik Anda!
      final keuntunganBersih = gramEmasLayar * selisih;

      hasil = {
        'hb': hb,
        'hj': hj,
        'modalAwal': modalAwal,
        'kurs': kursUsdIdr,
        'hhb': hhb,
        'hhj': hhj,
        'selisih': selisih,
        'gramEmas': gramEmasRaw, // Tetap gunakan raw agar formatGram tidak error
        'keuntunganBersih': keuntunganBersih,
      };

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      hasil = null;
    }

    isCalculating = false;
  }

  /// Format rupiah tanpa pecahan desimal.
  String formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0';
    final isNegative = value < 0;
    final intPart = value.abs().truncate().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    final prefix = isNegative ? '-Rp' : 'Rp';
    return '$prefix$intPart';
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