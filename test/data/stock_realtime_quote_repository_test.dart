import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/data/stock_realtime_quote_repository.dart';

void main() {
  test('symbol별 Map으로 정리하고 등락액/등락률/시가총액을 계산한다', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'result': <String, dynamic>{
        'areas': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'SERVICE_ITEM',
            'datas': <Map<String, dynamic>>[
              <String, dynamic>{
                'cd': '005930',
                'nv': 179700,
                'pcv': 180100,
                'ov': 180000,
                'hv': 181000,
                'lv': 179000,
                'aq': 12345678,
                'countOfListedStock': 5969783,
              },
            ],
          },
        ],
      },
    };

    final quotes = parseRealtimeQuotes(json);

    expect(quotes.length, 1);
    final quote = quotes['005930']!;
    expect(quote.currentPrice, 179700);
    expect(quote.previousClose, 180100);
    expect(quote.changeAmount, -400); // nv - pcv
    expect(quote.changeRate, closeTo(-400 / 180100, 0.0001)); // (nv - pcv) / pcv
    expect(quote.marketCap, 179700 * 5969783); // nv * countOfListedStock
  });
}
