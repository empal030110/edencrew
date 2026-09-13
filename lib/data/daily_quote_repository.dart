import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/daily_quote.dart';

const int _pageSize = 10; // 한 페이지에 10거래일

class DailyQuoteRepository {
  // symbol별로 페이지 캐시를 따로 둠 -> 이미 받은 페이지는 다시 요청 안 함
  final Map<String, Map<int, List<DailyQuote>>> _pageCache = <String, Map<int, List<DailyQuote>>>{};
  final Map<String, int> _lastPage = <String, int>{};

  // 필요한 거래일 수 만큼 최근 일별 시세를 최신순으로 돌려줌
  // 필요한 페이지만 요청하고, 이미 받은 페이지는 캐시에서 재사용, lastPage 넘는 페이지는 요청 안 함
  Future<List<DailyQuote>> fetchDays(String symbol, int count) async {
    final int neededPages = (count / _pageSize).ceil();
    final List<DailyQuote> result = <DailyQuote>[];

    for (int page = 1; page <= neededPages; page++) {
      final int? knownLastPage = _lastPage[symbol];
      if (knownLastPage != null && page > knownLastPage) break;

      List<DailyQuote>? pageItems = _pageCache[symbol]?[page];
      if (pageItems == null) {
        final DailySisePage fetched = await _fetchPage(symbol, page);
        pageItems = fetched.items;
        _pageCache.putIfAbsent(symbol, () => <int, List<DailyQuote>>{})[page] = pageItems;
        _lastPage[symbol] = fetched.lastPage;
      }
      result.addAll(pageItems);
    }

    return result.length > count ? result.sublist(0, count) : result;
  }

  Future<DailySisePage> _fetchPage(String symbol, int page) async {
    // 1. 요청 - 이 endpoint는 일반적인 User-Agent 없이는 404 에러 페이지를 돌려줌
    final Uri uri = Uri.https('finance.naver.com', '/item/sise_day.naver', <String, String>{
      'code': symbol,
      'page': '$page',
    });
    final http.Response response = await http.get(
      uri,
      headers: <String, String>{'User-Agent': 'Mozilla/5.0'},
    );

    // 2. 파싱 - 응답이 EUC-KR인데, 뽑는 값(날짜/숫자/영문 class명)은 전부 ASCII -> latin1로 디코딩해도 안 깨짐
    final String html = latin1.decode(response.bodyBytes);

    return parseDailySiseHtml(html, requestedPage: page);
  }
}

class DailySisePage {
  const DailySisePage({required this.items, required this.lastPage});

  final List<DailyQuote> items;
  final int lastPage;
}

final RegExp _rowPattern = RegExp(
  r'<tr onMouseOver="mouseOver\(this\)" onMouseOut="mouseOut\(this\)">(.*?)</tr>',
  dotAll: true,
);
final RegExp _datePattern = RegExp(r'class="tah p10 gray03">([\d.]+)<');
final RegExp _numPattern = RegExp(r'class="tah p11[^"]*">\s*([\d,]+)\s*<');
final RegExp _directionPattern = RegExp(r'class="bu_p (bu_pup|bu_pdn|bu_pn)"');
final RegExp _pageLinkPattern = RegExp(r'page=(\d+)');

// 순수 함수 -> 네트워크 없이 테스트 가능 (test/data/daily_quote_repository_test.dart 참고)
DailySisePage parseDailySiseHtml(String html, {required int requestedPage}) {
  final List<DailyQuote> items = <DailyQuote>[];

  for (final RegExpMatch rowMatch in _rowPattern.allMatches(html)) {
    final String row = rowMatch.group(1)!;

    final RegExpMatch? dateMatch = _datePattern.firstMatch(row);
    final List<RegExpMatch> numMatches = _numPattern.allMatches(row).toList();
    if (dateMatch == null || numMatches.length < 6) continue; // 스페이서용 빈 행은 건너뜀

    // 표의 숫자 순서: 종가, 전일비, 시가, 고가, 저가, 거래량
    final int closePrice = _parseInt(numMatches[0].group(1)!);
    final int changeMagnitude = _parseInt(numMatches[1].group(1)!);
    final int openPrice = _parseInt(numMatches[2].group(1)!);
    final int highPrice = _parseInt(numMatches[3].group(1)!);
    final int lowPrice = _parseInt(numMatches[4].group(1)!);
    final int volume = _parseInt(numMatches[5].group(1)!);

    final String direction = _directionPattern.firstMatch(row)?.group(1) ?? 'bu_pn';
    final int changeAmount = direction == 'bu_pup'
        ? changeMagnitude
        : direction == 'bu_pdn'
            ? -changeMagnitude
            : 0;

    items.add(
      DailyQuote(
        date: dateMatch.group(1)!.replaceAll('.', ''), // yyyy.MM.dd -> yyyyMMdd
        closePrice: closePrice,
        changeAmount: changeAmount,
        openPrice: openPrice,
        highPrice: highPrice,
        lowPrice: lowPrice,
        volume: volume,
      ),
    );
  }

  // "맨뒤" 링크의 page 값이 곧 lastPage. 링크가 안 보이면(이미 마지막 페이지 근처면)
  // 페이지 안에 있는 page= 값들 중 가장 큰 걸로 대체
  final Iterable<int> pageNumbers = _pageLinkPattern
      .allMatches(html)
      .map((RegExpMatch m) => int.parse(m.group(1)!));
  final int lastPage = pageNumbers.isEmpty
      ? requestedPage
      : pageNumbers.reduce((int a, int b) => a > b ? a : b);

  return DailySisePage(items: items, lastPage: lastPage);
}

int _parseInt(String value) => int.parse(value.replaceAll(',', ''));
