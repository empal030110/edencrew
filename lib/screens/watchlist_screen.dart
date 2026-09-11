import 'package:flutter/material.dart';

import '../theme/theme.dart'; // context.colors, context.dimens 등 토큰을 쓰기 위한 import
import '../widgets/app_bottom_nav_bar.dart';

// 관심 화면
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold( // Scaffold: 화면 한 장의 기본 뼈대(배경, 앱바, 바디 등을 담는 틀)
      body: SafeArea( // SafeArea: 노치/상태바 등 시스템 영역을 피해서 내용을 배치
        child: Column(
          children: <Widget>[
            _WatchlistHeader(),
            // TODO: 관심 종목 목록을 받아오면 분기
            // 목록 없는 상태만 구현
            Expanded(child: _WatchlistEmptyState()),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(),
    );
  }
}

// 언더스코어(_)로 시작하는 클래스는 이 파일 안에서만 쓰는 private 위젯이라는 뜻
class _WatchlistHeader extends StatelessWidget {
  const _WatchlistHeader();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors; // 화면에서 쓸 색상 토큰 묶음
    final AppDimens dimens = context.dimens; // 간격/크기 토큰 묶음

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dimens.space3,
        horizontal: dimens.space4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '관심',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 19,
              fontWeight: AppTypography.bold,
              height: 22 / 19, // line-height 22px ÷ fontSize 19px (Flutter는 배수로 지정)
              letterSpacing: -0.2,
            ),
          ),
          Row(
            children: <Widget>[
              Text(
                '가나다순',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: AppTypography.bold,
                  height: 18 / 13,
                  letterSpacing: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Image.asset(
                  'assets/icons/sort_arrow.png',
                  width: dimens.iconMd,
                  height: dimens.iconMd,
                  color: colors.textSecondary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              SizedBox(width: dimens.space4),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Image.asset(
                  'assets/icons/refresh.png',
                  width: dimens.iconMd,
                  height: dimens.iconMd,
                  color: colors.textSecondary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 관심 종목 없을 때
class _WatchlistEmptyState extends StatelessWidget {
  const _WatchlistEmptyState();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.star_border,
            size: 40, // 재사용되는 값이 아니라 토큰으로 안 빼고 리터럴로 둠
            color: colors.textTertiary,
          ),
          SizedBox(height: dimens.space3),
          Text(
            '관심 종목이 없습니다',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 19,
              fontWeight: AppTypography.bold,
              height: 22 / 19,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: dimens.space3),
          Text(
            '검색 탭에서 종목을 찾아\n별 아이콘을 눌러 추가해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textTertiary,
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
