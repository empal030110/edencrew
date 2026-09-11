import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock_search_result.dart';
import 'dto/stock_metadata_dto.dart';

class StockMetadataRepository {
  // 경로에 심볼 하나만 들어가는 API라 여러 종목이면 병렬로 각각 요청함
  Future<Map<String, StockSearchResult>> fetchAll(List<String> symbols) async {
    if (symbols.isEmpty) return const <String, StockSearchResult>{};

    final List<StockSearchResult?> results = await Future.wait(symbols.map(_fetchOne));

    return <String, StockSearchResult>{
      for (final StockSearchResult result in results.whereType<StockSearchResult>())
        result.symbol: result,
    };
  }

  Future<StockSearchResult?> _fetchOne(String symbol) async {
    // 1. 요청
    final Uri uri = Uri.https(
      'stock.naver.com',
      '/api/securityFe/api/fchart/domestic/stock/$symbol',
    );
    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) return null;

    // 2. 파싱
    final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
    return parseStockMetadata(json);
  }
}

// 파싱(DTO 변환) + 모델 변환을 네트워크 호출과 분리한 순수 함수
// -> 네트워크 없이 테스트 가능 (test/data/stock_metadata_repository_test.dart 참고)
StockSearchResult? parseStockMetadata(Map<String, dynamic> json) {
  // 3. DTO 작성
  final StockMetadataDto dto = StockMetadataDto.fromJson(json);
  if (dto.symbolCode.isEmpty) return null; // 존재하지 않는 심볼

  // 4. 모델 연결: 검색 결과랑 같은 모델(StockSearchResult)로 맞춰서 관심/상세 화면에서 그대로 씀
  return StockSearchResult(
    id: 'domestic:${dto.symbolCode}',
    symbol: dto.symbolCode,
    name: dto.stockName,
    market: dto.stockExchangeNameKor,
  );
}
