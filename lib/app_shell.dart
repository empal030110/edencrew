import 'package:flutter/material.dart';

import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'widgets/app_bottom_nav_bar.dart';

// 관심/검색 두 화면과 하단 탭바를 묶는 뼈대
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // 0: 관심, 1: 검색

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // 하단 안전영역은 AppBottomNavBar 안에서 따로 처리함
        child: IndexedStack(
          index: _selectedIndex,
          children: const <Widget>[
            WatchlistScreen(),
            SearchScreen(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
