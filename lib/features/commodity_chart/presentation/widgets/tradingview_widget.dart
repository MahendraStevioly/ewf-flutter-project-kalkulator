import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_theme.dart'; // Sesuaikan path-nya ya

class TradingViewWidget extends StatefulWidget {
  final String symbol;
  final double height;

  const TradingViewWidget({Key? key, required this.symbol, this.height = 400})
      : super(key: key);

  @override
  State<TradingViewWidget> createState() => _TradingViewWidgetState();
}

class _TradingViewWidgetState extends State<TradingViewWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool? _isCurrentlyDark; // Buat nyimpen status tema saat ini

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller HANYA SATU KALI
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent) // <--- TAMBAHIN BARIS INI BROK!
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      );

    // Pemanggilan _loadHtmlForSymbol dihapus dari sini, 
    // karena dipindah ke didChangeDependencies biar bisa baca tema
  }

  // ==============================================================
  // FUNGSI SAKTI: 
  // Kepanggil pas pertama kali build & tiap kali user ganti tema (Dark/Light)
  // ==============================================================
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Cek apakah HP user lagi pakai dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Kalau temanya berubah, reload WebView-nya
    if (_isCurrentlyDark != isDark) {
      _isCurrentlyDark = isDark;
      setState(() => _isLoading = true);
      _loadHtmlForSymbol(widget.symbol, isDark);
    }
  }

  @override
  void didUpdateWidget(covariant TradingViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      setState(() {
        _isLoading = true;
      });
      // Tembak HTML dengan simbol baru dan tema saat ini
      _loadHtmlForSymbol(widget.symbol, _isCurrentlyDark ?? false); 
    }
  }

  // ==============================================================
  // HTML BUILDER YANG UDAH DIBIKIN DINAMIS UNTUK DARK MODE
  // ==============================================================
  void _loadHtmlForSymbol(String symbol, bool isDarkMode) {
    // Siapin warna background dasar biar ga ada flash putih pas loading
    final bgColor = isDarkMode ? '#0F172A' : '#ffffff'; 
    final theme = isDarkMode ? 'dark' : 'light';

    final String htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          /* Background body menyesuaikan tema */
          body { margin: 0; padding: 0; background-color: $bgColor; }
          #tradingview-widget { height: 100vh; width: 100vw; }
        </style>
      </head>
      <body>
        <div class="tradingview-widget-container" id="tradingview-widget"></div>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
        <script type="text/javascript">
          new TradingView.widget({
            "autosize": true,
            "symbol": "$symbol",
            "interval": "D",
            "timezone": "Asia/Jakarta",
            "theme": "$theme", /* TEMA SUDAH DINAMIS BROK! */
            "style": "1",
            "locale": "id",
            "enable_publishing": false,
            "hide_top_toolbar": false,
            "hide_legend": false,
            "save_image": false,
            "container_id": "tradingview-widget"
          });
        </script>
      </body>
      </html>
    ''';

    _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          // Supaya saat loading, background di belakang indikator nggak bolong
          // biar nggak putih pas loading
          Container(color: context.scaffoldBg),
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFF7941D), // Warna indikator oranye khas app lu
              ),
            ),
        ],
      ),
    );
  }
}