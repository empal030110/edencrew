import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/models/stock_quote.dart';
import 'package:edencrew_assignment_starter/models/stock_search_result.dart';
import 'package:edencrew_assignment_starter/utils/watchlist_sort.dart';

void main() {
  const Map<String, StockSearchResult> metadata = <String, StockSearchResult>{
    '005930': StockSearchResult(
      id: 'domestic:005930',
      symbol: '005930',
      name: '삼성전자',
      market: '코스피',
    ),
    '000660': StockSearchResult(
      id: 'domestic:000660',
      symbol: '000660',
      name: 'SK하이닉스',
      market: '코스피',
    ),
    '035720': StockSearchResult(
      id: 'domestic:035720',
      symbol: '035720',
      name: '카카오',
      market: '코스피',
    ),
  };

  const Map<String, StockQuote> quotes = <String, StockQuote>{
    '005930': StockQuote(
      currentPrice: 179700,
      previousClose: 180100, // -0.22%
      open: 0,
      high: 0,
      low: 0,
      accumulatedVolume: 0,
      marketCap: 0,
    ),
    '000660': StockQuote(
      currentPrice: 412500,
      previousClose: 403000, // +2.36%
      open: 0,
      high: 0,
      low: 0,
      accumulatedVolume: 0,
      marketCap: 0,
    ),
    '035720': StockQuote(
      currentPrice: 61300,
      previousClose: 62100, // -1.29%
      open: 0,
      high: 0,
      low: 0,
      accumulatedVolume: 0,
      marketCap: 0,
    ),
  };

  final symbols = <String>['005930', '000660', '035720'];

  test('가나다순은 이름 오름차순으로 정렬한다', () {
    final sorted = sortWatchlistSymbols(
      symbols,
      WatchlistSortOption.byName,
      metadata,
      quotes,
    );
    expect(sorted, <String>['000660', '005930', '035720']); // SK하이닉스, 삼성전자, 카카오
  });

  test('현재가순은 높은 가격이 먼저 온다', () {
    final sorted = sortWatchlistSymbols(
      symbols,
      WatchlistSortOption.byPrice,
      metadata,
      quotes,
    );
    expect(sorted, <String>['000660', '005930', '035720']); // 412,500 > 179,700 > 61,300
  });

  test('등락률순은 상승률이 높은 게 먼저 온다', () {
    final sorted = sortWatchlistSymbols(
      symbols,
      WatchlistSortOption.byChangeRate,
      metadata,
      quotes,
    );
    expect(sorted, <String>['000660', '005930', '035720']); // +2.36% > -0.22% > -1.29%
  });

  test('아직 시세/메타데이터가 안 온 종목은 맨 뒤로 보낸다', () {
    final sorted = sortWatchlistSymbols(
      <String>['005930', '999999', '000660'],
      WatchlistSortOption.byPrice,
      metadata,
      quotes,
    );
    expect(sorted, <String>['000660', '005930', '999999']);
  });
}
