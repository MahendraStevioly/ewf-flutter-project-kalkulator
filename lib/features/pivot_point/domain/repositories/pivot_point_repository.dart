import '../entities/market_data.dart';

abstract class PivotPointRepository {
  const PivotPointRepository();

  Future<MarketData> fetchMarketData(String targetUrl);
}
