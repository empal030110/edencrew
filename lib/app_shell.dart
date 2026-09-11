import 'package:flutter/material.dart';

import 'screens/search_screen.dart';
import 'screens/watchlist_screen.dart';
import 'state/favorites_controller.dart';
import 'widgets/app_bottom_nav_bar.dart';

// 관심/검색 두 화면과 하단 탭바를 묶는 뼈대
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // 0: 관심, 1: 검색
  // 검색/관심 화면이 같은 관심 등록 상태를 봐야 함 -> 하나 만들어서 내려줌
  final FavoritesController _favorites = FavoritesController();

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // 하단 안전영역은 AppBottomNavBar 안에서 따로 처리함
        child: IndexedStack(
          index: _selectedIndex,
          children: <Widget>[
            WatchlistScreen(favorites: _favorites),
            SearchScreen(favorites: _favorites),
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
