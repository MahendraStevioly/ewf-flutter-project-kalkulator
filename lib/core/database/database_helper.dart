import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Kelas Singleton untuk mengelola koneksi SQLite secara efisien
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pivot_kalkulator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Mengeksekusi DDL (Data Definition Language) untuk membuat tabel
  Future _createDB(Database db, int version) async {
    // 1. Tabel Riwayat Pivot Point (Data Personal)
    await db.execute('''
      CREATE TABLE pivot_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        close REAL NOT NULL,
        openingPrice REAL NOT NULL,
        pp REAL NOT NULL,
        range REAL NOT NULL,
        r1 REAL NOT NULL,
        r2 REAL NOT NULL,
        r3 REAL NOT NULL,
        r4 REAL NOT NULL,
        s1 REAL NOT NULL,
        s2 REAL NOT NULL,
        s3 REAL NOT NULL,
        s4 REAL NOT NULL,
        recommendation TEXT NOT NULL
      )
    ''');

    // 2. Tabel Market Data Newsmaker (Cache Offline untuk Emas Digital, Hang Seng, Nikkei)
    await db.execute('''
      CREATE TABLE market_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        date TEXT NOT NULL,
        open REAL NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        close REAL NOT NULL
      )
    ''');

    // 3. Tabel Riwayat Emas Fisik (Baru!)
    await db.execute('''
      CREATE TABLE physical_gold_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        gold_type TEXT NOT NULL,    -- Contoh: Antam, UBS, Perhiasan
        weight REAL NOT NULL,       -- Berat dalam gram
        purity REAL NOT NULL,       -- Kadar/Karat (misal: 24, 22, atau 99.9)
        price_per_gram REAL NOT NULL,
        total_price REAL NOT NULL
      )
    ''');

    // 4. Tabel Pengaturan Aplikasi (Tema Gelap/Terang, dll)
    await db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');

    // Menyuntikkan nilai default Tema Terang saat database pertama kali dibuat
    await db.insert('app_settings', {
      'setting_key': 'theme_mode',
      'setting_value': 'light'
    });

    // 5. Tabel Riwayat Nest (High dan Low dihapus)
    await db.execute('''
      CREATE TABLE nest_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        close REAL NOT NULL,
        openingPrice REAL NOT NULL,
        recommendation TEXT NOT NULL
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}