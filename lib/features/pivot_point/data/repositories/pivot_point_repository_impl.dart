import '../../../../core/services/scraping_service.dart';
import '../../domain/entities/market_data.dart';
import '../../domain/repositories/pivot_point_repository.dart';

class PivotPointRepositoryImpl implements PivotPointRepository {
  PivotPointRepositoryImpl({ScrapingService? scrapingService})
      : _scrapingService = scrapingService ?? ScrapingService();

  final ScrapingService _scrapingService;

  @override
  Future<MarketData> fetchMarketData(String targetUrl) async {
    final data = await _scrapingService.fetchHistoricalPrices(targetUrl);

    return MarketData(
      date: data['date'] as String,
      open: data['open'] as double,
      high: data['high'] as double,
      low: data['low'] as double,
      close: data['close'] as double,
    );
  }
}
