// 관심/상세 화면에서 쓰는 시세 모델, 등락액·등락률·시가총액은 API 원본 필드가 아니라
// nv(현재가)/pcv(전일종가)/countOfListedStock(상장주식수)로 여기서 계산해서 채움
class StockQuote {
  const StockQuote({
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.accumulatedVolume,
    required this.marketCap,
  });

  final int currentPrice;
  final int previousClose;
  final int open;
  final int high;
  final int low;
  final int accumulatedVolume;
  final int marketCap;

  int get changeAmount => currentPrice - previousClose;

  double get changeRate => previousClose == 0 ? 0 : changeAmount / previousClose;
}
