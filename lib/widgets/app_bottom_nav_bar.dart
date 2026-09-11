import 'package:flutter/material.dart';

import '../theme/theme.dart';

// 하단 탭바
class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({super.key});

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  int _selectedIndex = 0; // 0: 관심, 1: 검색

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return SafeArea(
      top: false, // 하단 홈 인디케이터 영역만 피하면 되니 위쪽은 무시
      child: Container(
        padding: EdgeInsets.symmetric(vertical: dimens.space2),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          border: Border(
            top: BorderSide(
              color: colors.borderSubtle,
              width: dimens.borderHairline,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _NavItem(
                icon: _selectedIndex == 0 ? Icons.star : Icons.star_border,
                label: '관심',
                active: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.search,
                label: '검색',
                active: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 탭 하나(아이콘 + 라벨)를 그리는 위젯. 상태가 없어서 StatelessWidget으로 만듦
// (탭 상태 자체는 부모인 _AppBottomNavBarState가 들고 있고, 여기는 받은 값만 그림)
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon, // 그릴 아이콘 (예: Icons.star)
    required this.label, // 아이콘 밑에 쓸 글자 (예: '관심')
    required this.active, // 지금 선택된 탭인지 여부
    required this.onTap, // 탭 눌렀을 때 실행할 콜백 함수
  });

  // 위에서 받은 값들을 저장하는 필드. StatelessWidget은 이 값들이 바뀌지 않음
  // (바뀌려면 부모가 새 _NavItem을 다시 만들어서 넘겨줘야 함)
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final Color color = active ? colors.navActive : colors.navInactive;

    return GestureDetector( // 탭 감지용 위젯
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 아이콘/텍스트 사이 빈 공간을 눌러도 탭이 되도록
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: dimens.iconLg, color: color), // 아이콘 그리기
          SizedBox(height: dimens.space1), // 아이콘과 글자 사이 여백
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: AppTypography.regular,
              height: 14 / 11,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
