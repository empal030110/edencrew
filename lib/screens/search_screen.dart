import 'package:flutter/material.dart';

import '../theme/theme.dart';

// 검색 화면, 여기서는 내용물만
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        _SearchBar(),
        Expanded(child: _SearchEmptyState()),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // 컨트롤러는 안 쓸 때 직접 정리해줘야 메모리 누수가 안 남
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final TextStyle placeholderStyle = TextStyle(
      color: colors.textTertiary,
      fontSize: 15,
      fontWeight: AppTypography.medium,
      height: 20 / 15,
      letterSpacing: -0.1,
    );

    return Padding(
      padding: EdgeInsets.only(
        top: dimens.space2,
        right: dimens.space4,
        bottom: dimens.space3,
        left: dimens.space4,
      ),
      child: Container(
        // x축 10px은 토큰에 없는 값이라 리터럴
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: dimens.space3),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(dimens.radiusMd),
          border: Border.all(
            color: colors.borderStrong,
            width: dimens.borderHairline,
          ),
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.search,
                size: dimens.iconSm,
                color: colors.textTertiary,
              ),
            ),
            SizedBox(width: dimens.space2),
            Expanded(
              child: TextField(
                controller: _controller,
                style: placeholderStyle.copyWith(color: colors.textPrimary),
                cursorColor: colors.accentDefault,
                decoration: InputDecoration.collapsed(
                  hintText: '종목명 또는 종목코드',
                  hintStyle: placeholderStyle,
                ),
              ),
            ),
            SizedBox(width: dimens.space2),
            GestureDetector(
              onTap: () => setState(_controller.clear),
              child: Icon(
                Icons.close,
                size: dimens.iconSm,
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 검색 전 보여주는 화면
class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.search,
            size: 40, // 재사용되는 값이 아니라 토큰으로 안 빼고 리터럴로 둠
            color: colors.textTertiary,
          ),
          SizedBox(height: dimens.space3),
          Text(
            '종목을 검색해 보세요',
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
            '종목명 또는 종목코드 6자리로\n검색하실 수 있습니다.',
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
