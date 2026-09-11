import 'package:flutter/material.dart';

import 'theme/theme.dart';
import 'screens/watchlist_screen.dart';

void main() {
  runApp(const EdencrewAssignmentApp());
}

class EdencrewAssignmentApp extends StatelessWidget {
  const EdencrewAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이든크루 평가 과제',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false, // 화면 확인할 때 가리는 우상단 DEBUG 띠 제거
      home: const WatchlistScreen(), // 앱 시작 시 처음 보여줄 화면
    );
  }
}
