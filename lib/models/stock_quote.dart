// 관심/상세 화면에서 쓰는 시세 모델
// marketCap은 API 원본 필드가 아니라 repository에서 currentPrice*상장주식수로 미리 계산해서 넣어줌
// 등락액·등락률은 API에 없어서 currentPrice/previousClose로 여기서 매번 계산
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
