import 'package:flutter/material.dart';

import '../theme/theme.dart';

// 관심 등록/해제 토스트, 검색 화면과 상세 화면에서 같이 씀
void showFavoriteToast(BuildContext context, {required bool isFavorite}) {
  final AppColors colors = context.colors;
  final AppDimens dimens = context.dimens;

  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar(); // 연속으로 누를 때 토스트가 쌓이지 않게 이전 토스트 제거
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.surfaceOverlay,
      // 기본 margin(하단 10px)이 아니라 하단 네브바에서 12px 위로 오도록 직접 지정
      margin: EdgeInsets.fromLTRB(
        dimens.space4,
        dimens.space1,
        dimens.space4,
        dimens.space3,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 14,
        horizontal: dimens.space4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimens.radiusLg),
        side: BorderSide(
          color: colors.borderSubtle,
          width: dimens.borderHairline,
        ),
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isFavorite ? Icons.star : Icons.star_border,
            size: 18,
            color: isFavorite ? colors.favoriteActive : colors.textSecondary,
          ),
          SizedBox(width: dimens.space2),
          Text(
            isFavorite ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: AppTypography.bold,
              height: 18 / 13,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    ),
  );
}
