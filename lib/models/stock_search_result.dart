// 검색 화면에서 실제로 쓰는 모델. API 응답 필드가 아니라 화면에 필요한 형태로 정리함.
class StockSearchResult {
  const StockSearchResult({
    required this.id,
    required this.symbol,
    required this.name,
    required this.market,
  });

  /// domestic:{symbol} 형태의 canonical id. 나중에 관심종목 저장/조회 키로 씀.
  final String id;

  /// 6자리 종목코드 (예: 005930)
  final String symbol;

  /// 종목명 (예: 삼성전자)
  final String name;

  /// 거래소명 (예: 코스피, 코스닥)
  final String market;

  @override
  String toString() => '$name($symbol, $market)';
}
