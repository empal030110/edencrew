import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';

// 정렬 기준, API 호출 없이 이미 받아온 metadata/quote로 클라이언트에서 계산해서 정렬함
enum WatchlistSortOption { byPrice, byChangeRate, byName }

// symbols를 정렬 기준에 맞춰 새 리스트로 정렬해서 돌려줌 -> 원본은 안 건드림
// 시세/메타데이터 아직 안 온 종목은 정렬 기준과 무관하게 맨 뒤로 보냄
List<String> sortWatchlistSymbols(
  List<String> symbols,
  WatchlistSortOption option,
  Map<String, StockSearchResult> metadata,
  Map<String, StockQuote> quotes,
) {
  final List<String> sorted = List<String>.of(symbols);
  switch (option) {
    case WatchlistSortOption.byName:
      sorted.sort((String a, String b) {
        final String? nameA = metadata[a]?.name;
        final String? nameB = metadata[b]?.name;
        if (nameA == null && nameB == null) return 0;
        if (nameA == null) return 1;
        if (nameB == null) return -1;
        return nameA.compareTo(nameB);
      });
    case WatchlistSortOption.byPrice:
      sorted.sort((String a, String b) {
        final int? priceA = quotes[a]?.currentPrice;
        final int? priceB = quotes[b]?.currentPrice;
        if (priceA == null && priceB == null) return 0;
        if (priceA == null) return 1;
        if (priceB == null) return -1;
        return priceB.compareTo(priceA); // 높은 가격 먼저
      });
    case WatchlistSortOption.byChangeRate:
      sorted.sort((String a, String b) {
        final double? rateA = quotes[a]?.changeRate;
        final double? rateB = quotes[b]?.changeRate;
        if (rateA == null && rateB == null) return 0;
        if (rateA == null) return 1;
        if (rateB == null) return -1;
        return rateB.compareTo(rateA); // 상승률 높은 게 먼저
      });
  }
  return sorted;
}
