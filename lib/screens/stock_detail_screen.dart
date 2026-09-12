import 'package:flutter/material.dart';

import '../theme/theme.dart';

// 종목 상세 화면, 일단 진입점만
class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key, required this.symbol, required this.name});

  final String symbol;
  final String name;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      appBar: AppBar(
        backgroundColor: colors.surfaceBase,
        foregroundColor: colors.textPrimary,
      ),
      body: Center(
        child: Text(
          '$name 상세 페이지',
          style: TextStyle(color: colors.textPrimary, fontSize: 15),
        ),
      ),
    );
  }
}
