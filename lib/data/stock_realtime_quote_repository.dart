import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock_quote.dart';
import 'dto/realtime_quote_dto.dart';

class StockRealtimeQuoteRepository {
  Future<Map<String, StockQuote>> fetch(List<String> symbols) async {
    if (symbols.isEmpty) return const <String, StockQuote>{};

    // 1. 요청 - 관심종목 전부 한 번에
    final Uri uri = Uri.https(
      'polling.finance.naver.com',
      '/api/realtime',
      <String, String>{'query': 'SERVICE_ITEM:${symbols.join(',')}'},
    );
    final http.Response response = await http.get(uri);

    // 2. 파싱
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;

    return parseRealtimeQuotes(json);
  }
}

// 파싱(DTO 변환) + 모델 변환을 네트워크 호출과 분리한 순수 함수
// -> 네트워크 없이 테스트 가능 (test/data/stock_realtime_quote_repository_test.dart 참고)
// symbol 기준으로 바로 찾을 수 있게 Map으로 정리해서 돌려줌
Map<String, StockQuote> parseRealtimeQuotes(Map<String, dynamic> json) {
  // 3. DTO 작성 (API 응답 그대로 옮기는 단계는 realtime_quote_dto.dart에 분리해둠)
  final RealtimeQuoteResponseDto dto = RealtimeQuoteResponseDto.fromJson(json);

  // 4. 모델 연결
  return <String, StockQuote>{
    for (final RealtimeQuoteItemDto item in dto.items)
      item.symbol: StockQuote(
        currentPrice: item.currentPrice,
        previousClose: item.previousClose,
        open: item.open,
        high: item.high,
        low: item.low,
        accumulatedVolume: item.accumulatedVolume,
        marketCap: item.currentPrice * item.listedStockCount,
      ),
  };
}
