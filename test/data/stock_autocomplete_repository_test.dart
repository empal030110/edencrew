import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/data/stock_autocomplete_repository.dart';

void main() {
  test('국내 주식·6자리 코드만 남기고 domestic:{symbol} id로 변환한다', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'query': '삼성',
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'code': '005930',
          'name': '삼성전자',
          'typeCode': 'KOSPI',
          'typeName': '코스피',
          'url': '/domestic/stock/005930/total',
          'nationCode': 'KOR',
          'category': 'stock',
        },
        <String, dynamic>{
          // 해외 종목 -> 제외돼야 함
          'code': 'AAPL',
          'name': 'Apple',
          'typeCode': 'NASDAQ',
          'typeName': '나스닥',
          'url': '/worldstock/stock/AAPL.O/total',
          'nationCode': 'USA',
          'category': 'stock',
        },
        <String, dynamic>{
          // 종목이 아니라 지수 -> 제외돼야 함
          'code': 'KOSPI',
          'name': '코스피',
          'typeCode': 'KOSPI',
          'typeName': '코스피',
          'url': '/domestic/index/KOSPI',
          'nationCode': 'KOR',
          'category': 'index',
        },
        <String, dynamic>{
          // 6자리가 아닌 코드 -> 제외돼야 함
          'code': '9593',
          'name': '이상한종목',
          'typeCode': 'KOSPI',
          'typeName': '코스피',
          'url': '/domestic/stock/9593/total',
          'nationCode': 'KOR',
          'category': 'stock',
        },
      ],
    };

    final result = parseAutocompleteResults(json);

    expect(result.length, 1);
    expect(result.first.id, 'domestic:005930');
    expect(result.first.symbol, '005930');
    expect(result.first.name, '삼성전자');
    expect(result.first.market, '코스피');
  });
}
