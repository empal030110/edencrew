// 천 단위 콤마만 찍어주는 용도라 intl 패키지 없이 직접 구현
String formatThousands(int value) {
  final bool isNegative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return (isNegative ? '-' : '') + buffer.toString();
}

// 양수엔 +, 음수엔 -, 0엔 부호 x
String formatSignedThousands(int value) {
  return value > 0 ? '+${formatThousands(value)}' : formatThousands(value);
}
