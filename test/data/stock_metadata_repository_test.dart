import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/data/stock_metadata_repository.dart';

void main() {
  test('symbolCode/stockName/stockExchangeNameKor를 StockSearchResult로 변환한다', () {
    final result = parseStockMetadata(<String, dynamic>{
      'symbolCode': '005930',
      'stockName': '삼성전자',
      'stockExchangeNameKor': '코스피',
    });

    expect(result, isNotNull);
    expect(result!.id, 'domestic:005930');
    expect(result.symbol, '005930');
    expect(result.name, '삼성전자');
    expect(result.market, '코스피');
  });

  test('존재하지 않는 심볼(symbolCode 없음)이면 null을 돌려준다', () {
    final result = parseStockMetadata(<String, dynamic>{'data': '', 'status': 200});

    expect(result, isNull);
  });
}
