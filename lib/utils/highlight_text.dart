import 'package:flutter/material.dart';

// text 안에서 query와 일치하는 부분을 찾아 색만 다른 TextSpan으로 쪼갬
// 대소문자는 구분 x, query가 여러 번 나오면 나온 곳마다 전부 강조
List<TextSpan> highlightedSpans({
  required String text,
  required String query,
  required TextStyle baseStyle,
  required Color highlightColor,
}) {
  if (query.isEmpty) {
    return <TextSpan>[TextSpan(text: text, style: baseStyle)];
  }

  final String lowerText = text.toLowerCase();
  final String lowerQuery = query.toLowerCase();
  final TextStyle highlightStyle = baseStyle.copyWith(color: highlightColor);

  final List<TextSpan> spans = <TextSpan>[];
  int start = 0;
  int matchIndex = lowerText.indexOf(lowerQuery, start);

  while (matchIndex != -1) {
    if (matchIndex > start) {
      spans.add(TextSpan(text: text.substring(start, matchIndex), style: baseStyle));
    }
    spans.add(TextSpan(
      text: text.substring(matchIndex, matchIndex + query.length),
      style: highlightStyle,
    ));
    start = matchIndex + query.length;
    matchIndex = lowerText.indexOf(lowerQuery, start);
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start), style: baseStyle));
  }

  return spans;
}
