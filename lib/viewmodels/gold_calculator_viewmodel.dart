/// ViewModel untuk Gold Calculator
/// Mengelola semua business logic dan state untuk kalkulasi emas fisik
class GoldCalculatorViewModel {
  // Input values
  String hargaBeli = '';
  String hargaJual = '';

  // Parameters (default values)
  double modalAwal = 100000000;
  double kursUsdIdr = 18000;
  double konversiTozG = 31.1;

  // Result state
  Map<String, dynamic>? hasil;
  String? errorMessage;
  bool isCalculating = false;

  /// Validasi input values
  bool validateInputs() {
    if (hargaBeli.isEmpty || hargaJual.isEmpty) {
      errorMessage = 'Mohon isi Harga Beli dan Harga Jual';
      return false;
    }

    final hb = double.tryParse(hargaBeli);
    final hj = double.tryParse(hargaJual);

    if (hb == null || hj == null || hb <= 0 || hj <= 0) {
      errorMessage = 'Harga harus berupa angka positif';
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
      final hb = double.parse(hargaBeli);
      final hj = double.parse(hargaJual);

      // Hitungan berdasarkan formula
      final hhb = (hb * kursUsdIdr) / konversiTozG;
      final hhj = (hj * kursUsdIdr) / konversiTozG;
      final selisih = hhj - hhb;
      final gramEmas = modalAwal / hhb;
      final keuntunganBersih = gramEmas * selisih;

      hasil = {
        'hb': hb,
        'hj': hj,
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

  /// Format angka untuk display (Rp X.XXX.XXX,XX)
  String formatCurrency(double value) {
    final intPart = value.toStringAsFixed(0);
    final fracPart = ((value % 1) * 100).toStringAsFixed(0).padLeft(2, '0');

    // Split integer part untuk menambah separator
    final intPartWithSeparator = intPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$intPartWithSeparator,$fracPart';
  }

  /// Format gram
  String formatGram(double value) {
    return '${value.toStringAsFixed(2)} gram';
  }

  /// Reset semua state
  void reset() {
    hargaBeli = '';
    hargaJual = '';
    hasil = null;
    errorMessage = null;
    isCalculating = false;
  }

  /// Update modal awal
  void setModalAwal(double value) {
    modalAwal = value;
  }

  /// Update kurs
  void setKursUsdIdr(double value) {
    kursUsdIdr = value;
  }

  /// Update konversi TOZ
  void setKonversiTozG(double value) {
    konversiTozG = value;
  }
}
