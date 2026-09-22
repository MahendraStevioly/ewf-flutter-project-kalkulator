import 'package:kalkulator_pivot/core/database/database_helper.dart';
import 'package:flutter/foundation.dart';

enum HistoryType { gold, pivot, nest }

class GoldHistoryEntry {
  const GoldHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.hb,
    required this.hj,
    required this.kurs,
    required this.toz,
    required this.modalAwal,
    required this.hhb,
    required this.hhj,
    required this.selisih,
    required this.gramEmas,
    required this.keuntunganBersih,
  });

  final String id;
  final DateTime timestamp;
  final double hb;
  final double hj;
  final double kurs;
  final double toz;
  final double modalAwal;
  final double hhb;
  final double hhj;
  final double selisih;
  final double gramEmas;
  final double keuntunganBersih;
}

class PivotHistoryEntry {
  const PivotHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.high,
    required this.low,
    required this.close,
    required this.openingPrice,
    required this.pp,
    required this.range,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.recommendation,
  });

  final String id;
  final DateTime timestamp;
  final double high;
  final double low;
  final double close;
  final double openingPrice;
  final double pp;
  final double range;
  final double r1;
  final double r2;
  final double r3;
  final double r4;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final String recommendation;
}

class NestHistoryEntry {
  final String id;
  final DateTime timestamp;
  final double close;
  final double openingPrice;
  final String recommendation;

  NestHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.close,
    required this.openingPrice,
    required this.recommendation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'close': close,
      'openingPrice': openingPrice,
      'recommendation': recommendation,
    };
  }
}

class HistoryService {
  HistoryService._();
  static final HistoryService instance = HistoryService._();

  final List<GoldHistoryEntry> _goldHistory = [];
  final List<PivotHistoryEntry> _pivotHistory = [];
  final List<NestHistoryEntry> _nestHistory = []; // 👇 Tambahan List Memory buat Nest

  List<GoldHistoryEntry> get goldHistory => List.unmodifiable(_goldHistory.reversed.toList());
  List<PivotHistoryEntry> get pivotHistory => List.unmodifiable(_pivotHistory.reversed.toList());
  List<NestHistoryEntry> get nestHistory => List.unmodifiable(_nestHistory.reversed.toList()); // 👇 Tambahan Getter

  void addGold(GoldHistoryEntry entry) {
    _goldHistory.add(entry);
  }

  void addPivot(PivotHistoryEntry entry) {
    _pivotHistory.add(entry);
  }

  // 👇 Logika digabung: Simpan ke Memory DAN ke Database
  Future<void> addNest(NestHistoryEntry entry) async {
    _nestHistory.add(entry); // Biar lgsg update di UI Real-time
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('nest_history', entry.toMap());
    } catch (e) {
      if (kDebugMode) print('Gagal menyimpan riwayat Nest: $e');
    }
  }

  void clearAll() {
    _goldHistory.clear();
    _pivotHistory.clear();
    _nestHistory.clear(); // 👇 Bersihin Nest juga
  }

  // Untuk dashboard: gabungan terbaru (3 item)
  List<Map<String, dynamic>> getRecentCombined({int limit = 3}) {
    final combined = <Map<String, dynamic>>[];

    for (final g in _goldHistory) {
      combined.add({'type': HistoryType.gold, 'entry': g, 'timestamp': g.timestamp});
    }
    for (final p in _pivotHistory) {
      combined.add({'type': HistoryType.pivot, 'entry': p, 'timestamp': p.timestamp});
    }
    // 👇 Tambahin Nest ke dalam List Gabungan (biar muncul di Beranda)
    for (final n in _nestHistory) {
      combined.add({'type': HistoryType.nest, 'entry': n, 'timestamp': n.timestamp});
    }

    combined.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    return combined.take(limit).toList();
  }
}