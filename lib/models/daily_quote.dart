// 일별 시세 한 줄. date는 yyyyMMdd로 정규화해서 씀
class DailyQuote {
  const DailyQuote({
    required this.date,
    required this.closePrice,
    required this.changeAmount,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
  });

  final String date;
  final int closePrice;
  final int changeAmount;
  final int openPrice;
  final int highPrice;
  final int lowPrice;
  final int volume;
}
