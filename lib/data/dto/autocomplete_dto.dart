// 검색 자동완성 API(GET https://ac.stock.naver.com/ac) 응답을 그대로 옮긴 DTO
// 필드명도 API 응답 그대로 써서, 실제 값이랑 코드를 나란히 비교
// 화면에서 쓰는 모델(StockSearchResult)로 바꾸는 건 여기서 안 하고 리포지토리에서 함

class AutocompleteResponseDto {
  const AutocompleteResponseDto({required this.items});

  factory AutocompleteResponseDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems = json['items'] as List<dynamic>? ?? <dynamic>[];
    return AutocompleteResponseDto(
      items: rawItems
          .map((dynamic item) => AutocompleteItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<AutocompleteItemDto> items;
}

class AutocompleteItemDto {
  const AutocompleteItemDto({
    required this.code,
    required this.name,
    required this.typeCode,
    required this.typeName,
    required this.url,
    required this.nationCode,
    required this.category,
  });

  factory AutocompleteItemDto.fromJson(Map<String, dynamic> json) {
    return AutocompleteItemDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      typeCode: json['typeCode'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
      url: json['url'] as String? ?? '',
      nationCode: json['nationCode'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  final String code;
  final String name;
  final String typeCode;
  final String typeName;
  final String url;
  final String nationCode;
  final String category;
}
