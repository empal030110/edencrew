// 실시간 시세 API 응답을 그대로 옮긴 DTO
// 응답 구조: result.areas[].datas[] 안에 종목별 시세가 들어있음

class RealtimeQuoteResponseDto {
  const RealtimeQuoteResponseDto({required this.items});

  factory RealtimeQuoteResponseDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> result = json['result'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> areas = result['areas'] as List<dynamic>? ?? <dynamic>[];

    final List<RealtimeQuoteItemDto> items = <RealtimeQuoteItemDto>[];
    for (final dynamic area in areas) {
      final List<dynamic> datas = (area as Map<String, dynamic>)['datas'] as List<dynamic>? ?? <dynamic>[];
      items.addAll(
        datas.map(
          (dynamic data) => RealtimeQuoteItemDto.fromJson(data as Map<String, dynamic>),
        ),
      );
    }

    return RealtimeQuoteResponseDto(items: items);
  }

  final List<RealtimeQuoteItemDto> items;
}

class RealtimeQuoteItemDto {
  const RealtimeQuoteItemDto({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.open,
    required this.high,
    required this.low,
    required this.accumulatedVolume,
    required this.listedStockCount,
  });

  factory RealtimeQuoteItemDto.fromJson(Map<String, dynamic> json) {
    return RealtimeQuoteItemDto(
      symbol: json['cd'] as String? ?? '',
      currentPrice: (json['nv'] as num?)?.toInt() ?? 0,
      previousClose: (json['pcv'] as num?)?.toInt() ?? 0,
      open: (json['ov'] as num?)?.toInt() ?? 0,
      high: (json['hv'] as num?)?.toInt() ?? 0,
      low: (json['lv'] as num?)?.toInt() ?? 0,
      accumulatedVolume: (json['aq'] as num?)?.toInt() ?? 0,
      listedStockCount: (json['countOfListedStock'] as num?)?.toInt() ?? 0,
    );
  }

  final String symbol;
  final int currentPrice;
  final int previousClose;
  final int open;
  final int high;
  final int low;
  final int accumulatedVolume;
  final int listedStockCount;
}
