import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
// 1. Ubah referensi ke file scraping_service.dart
import 'services/scraping_service.dart'; 

// 2. Ubah main() menjadi asinkron (async)
void main() async {
  // 3. Wajib ditambahkan karena kita menjalankan proses penarikan data sebelum UI dirender
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Memanggil fungsi untuk menguji ScrapingService
  await testScrapingData(); 

  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => const MyApp(),
    ),
  );
}

// 5. Fungsi khusus untuk mengetes hasil scraping
Future<void> testScrapingData() async {
  final scraper = ScrapingService();
  print('⏳ Mengambil data historis dari tabel web...');
  
  try {
    // PENTING: Ganti URL di bawah ini dengan tautan (link) halaman spesifik di Newsmaker
    const String targetUrl = 'https://www.newsmaker.id/id/tools/historical-data'; 
    
    final result = await scraper.fetchHistoricalPrices(targetUrl);
    
    print('✅ Data berhasil ditarik!');
    print('-------------------------');
    print('Tanggal       : ${result['date']}');
    print('Buka (Open)   : ${result['open']}');
    print('Tinggi (High) : ${result['high']}');
    print('Rendah (Low)  : ${result['low']}');
    print('Tutup (Close) : ${result['close']}');
    print('-------------------------');
  } catch (e) {
    print('❌ Terjadi Kesalahan Scraping: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Kalkulator Komoditas', // Judul aplikasi diperbarui
      theme: ThemeData(
        // Perbaikan sintaks ColorScheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          // Perbaikan sintaks MainAxisAlignment
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}