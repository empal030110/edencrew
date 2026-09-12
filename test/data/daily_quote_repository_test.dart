import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/data/daily_quote_repository.dart';

// 실제 https://finance.naver.com/item/sise_day.naver 응답 구조를 축약한 조각.
// 스페이서용 빈 <tr>과 down/flat 두 케이스를 포함시켜서 파싱이 걸러내는지 확인함
const String _sampleHtml = '''
<table cellspacing="0" class="type2">
<tr>
<th>날짜</th><th>종가</th><th>전일비</th><th>시가</th><th>고가</th><th>저가</th><th>거래량</th>
</tr>
<tr>
<td colspan="7" height="8"></td>
</tr>
<tr onMouseOver="mouseOver(this)" onMouseOut="mouseOut(this)">
<td align="center"><span class="tah p10 gray03">2026.09.11</span></td>
<td class="num"><span class="tah p11">259,500</span></td>
<td class="num">
<em class="bu_p bu_pdn"><span class="blind">하락</span></em><span class="tah p11 nv01">
9,500
</span>
</td>
<td class="num"><span class="tah p11">258,000</span></td>
<td class="num"><span class="tah p11">261,500</span></td>
<td class="num"><span class="tah p11">256,500</span></td>
<td class="num"><span class="tah p11">13,938,673</span></td>
</tr>
<tr onMouseOver="mouseOver(this)" onMouseOut="mouseOut(this)">
<td align="center"><span class="tah p10 gray03">2026.09.09</span></td>
<td class="num"><span class="tah p11">269,500</span></td>
<td class="num">
<em class="bu_p bu_pn"><span class="blind">보합</span></em><span class="tah p11">0</span>
</td>
<td class="num"><span class="tah p11">269,500</span></td>
<td class="num"><span class="tah p11">275,000</span></td>
<td class="num"><span class="tah p11">267,500</span></td>
<td class="num"><span class="tah p11">16,370,962</span></td>
</tr>
</table>
<table summary="페이지 네비게이션 리스트" class="Nnavi">
<tr>
<td class="on"><a href="/item/sise_day.naver?code=005930&amp;page=1">1</a></td>
<td class="pgRR"><a href="/item/sise_day.naver?code=005930&amp;page=5">맨뒤</a></td>
</tr>
</table>
''';

void main() {
  test('행 파싱 - 스페이서 행은 건너뛰고 종가/등락/시가/고가/저가/거래량을 뽑는다', () {
    final result = parseDailySiseHtml(_sampleHtml, requestedPage: 1);

    expect(result.items.length, 2);

    final first = result.items[0];
    expect(first.date, '20260911'); // yyyy.MM.dd -> yyyyMMdd
    expect(first.closePrice, 259500);
    expect(first.changeAmount, -9500); // 하락(bu_pdn) -> 음수
    expect(first.openPrice, 258000);
    expect(first.highPrice, 261500);
    expect(first.lowPrice, 256500);
    expect(first.volume, 13938673);

    final second = result.items[1];
    expect(second.date, '20260909');
    expect(second.changeAmount, 0); // 보합(bu_pn) -> 0
  });

  test('맨뒤 링크의 page 값을 lastPage로 뽑는다', () {
    final result = parseDailySiseHtml(_sampleHtml, requestedPage: 1);
    expect(result.lastPage, 5);
  });

  test('페이지 네비게이션이 없으면 요청한 페이지를 lastPage로 둔다', () {
    final result = parseDailySiseHtml('<table></table>', requestedPage: 3);
    expect(result.lastPage, 3);
    expect(result.items, isEmpty);
  });
}
