// 종목 메타데이터 API(GET .../fchart/domestic/stock/{symbol}) 응답을 그대로 옮긴 DTO
// 존재하지 않는 심볼이면 {"data":"","status":200}처럼 다른 모양으로 오기도 해서
// symbolCode가 비어있으면 유효하지 않은 응답으로 취급함 (stock_metadata_repository.dart에서 처리)
class StockMetadataDto {
  const StockMetadataDto({
    required this.symbolCode,
    required this.stockName,
    required this.stockExchangeNameKor,
  });

  factory StockMetadataDto.fromJson(Map<String, dynamic> json) {
    return StockMetadataDto(
      symbolCode: json['symbolCode'] as String? ?? '',
      stockName: json['stockName'] as String? ?? '',
      stockExchangeNameKor: json['stockExchangeNameKor'] as String? ?? '',
    );
  }

  final String symbolCode;
  final String stockName;
  final String stockExchangeNameKor;
}
