import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock_search_result.dart';
import 'dto/autocomplete_dto.dart';

// 종목코드는 반드시 숫자 6자리여야 함
final RegExp _sixDigitStockCode = RegExp(r'^\d{6}$');

class StockAutocompleteRepository {
  Future<List<StockSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return const <StockSearchResult>[];

    // 1. 요청
    final Uri uri = Uri.https('ac.stock.naver.com', '/ac', <String, String>{
      'q': query,
      'target': 'stock,ipo,index,marketindicator',
    });
    final http.Response response = await http.get(uri);

    // 2. 파싱
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;

    return parseAutocompleteResults(json);
  }
}

// 파싱 + 필터링 + 모델 변환을 네트워크 호출과 분리한 순수 함수
// -> 네트워크 없이 테스트 가능 (test/data/stock_autocomplete_repository_test.dart 참고)
List<StockSearchResult> parseAutocompleteResults(Map<String, dynamic> json) {
  // 3. DTO 작성 - API 응답 그대로 옮기는 단계는 autocomplete_dto.dart에 분리해둠
  final AutocompleteResponseDto dto = AutocompleteResponseDto.fromJson(json);

  // 4. 모델 연결: 국내 주식만 남기고, 6자리 종목코드만 통과시킨 뒤 화면용 모델로 변환
  return dto.items.where(_isDomesticStock).map(_toSearchResult).toList();
}

bool _isDomesticStock(AutocompleteItemDto item) {
  return item.nationCode == 'KOR' &&
      item.category == 'stock' &&
      _sixDigitStockCode.hasMatch(item.code);
}

StockSearchResult _toSearchResult(AutocompleteItemDto item) {
  return StockSearchResult(
    id: 'domestic:${item.code}',
    symbol: item.code,
    name: item.name,
    market: item.typeName,
  );
}
