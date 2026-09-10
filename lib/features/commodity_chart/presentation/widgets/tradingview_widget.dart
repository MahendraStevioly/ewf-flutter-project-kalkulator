import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller HANYA SATU KALI
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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

    // Muat grafik untuk pertama kali
    _loadHtmlForSymbol(widget.symbol);
  }

  // ==============================================================
  // MAGIC HAPPENS HERE:
  // Fungsi ini dipanggil otomatis oleh Flutter jika parent (Screen)
  // mengirimkan symbol baru (misal user klik tab Minyak)
  // ==============================================================
  @override
  void didUpdateWidget(covariant TradingViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      setState(() {
        _isLoading = true; // Munculkan indikator loading lagi
      });
      _loadHtmlForSymbol(widget.symbol); // Tembak HTML dengan simbol baru!
    }
  }

  // Fungsi pembuat HTML agar bisa dipanggil berulang kali tanpa merusak WebView
  void _loadHtmlForSymbol(String symbol) {
    final String htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; padding: 0; background-color: #ffffff; }
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
            "theme": "light",
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
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
