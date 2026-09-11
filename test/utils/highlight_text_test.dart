import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/utils/highlight_text.dart';

void main() {
  const TextStyle base = TextStyle(color: Colors.white);
  const Color highlight = Colors.purple;

  test('일치하는 부분마다 색이 다른 TextSpan으로 쪼갠다', () {
    final spans = highlightedSpans(
      text: '삼성전자우',
      query: '삼성',
      baseStyle: base,
      highlightColor: highlight,
    );

    expect(spans.map((s) => s.text).toList(), <String>['삼성', '전자우']);
    expect(spans[0].style!.color, highlight);
    expect(spans[1].style!.color, base.color);
  });

  test('여러 번 나오면 전부 강조한다', () {
    final spans = highlightedSpans(
      text: '가삼다삼나',
      query: '삼',
      baseStyle: base,
      highlightColor: highlight,
    );

    expect(spans.map((s) => s.text).toList(), <String>['가', '삼', '다', '삼', '나']);
  });

  test('검색어가 없으면 원문 그대로 반환한다', () {
    final spans = highlightedSpans(
      text: '삼성전자',
      query: '',
      baseStyle: base,
      highlightColor: highlight,
    );

    expect(spans.length, 1);
    expect(spans.first.text, '삼성전자');
    expect(spans.first.style!.color, base.color);
  });
}
