import 'package:flutter/material.dart';

import '../state/favorites_controller.dart';
import '../theme/theme.dart';

// 종목 상세 화면
class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({
    super.key,
    required this.symbol,
    required this.name,
    required this.market,
    required this.favorites,
  });

  final String symbol;
  final String name;
  final String market;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: Column(
        children: <Widget>[
          _DetailHeader(symbol: symbol, name: name, market: market, favorites: favorites),
          Expanded(
            child: Center(
              child: Text(
                '$name 상세 페이지',
                style: TextStyle(color: colors.textPrimary, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.symbol,
    required this.name,
    required this.market,
    required this.favorites,
  });

  final String symbol;
  final String name;
  final String market;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final String id = 'domestic:$symbol';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10, // 토큰에 없는 값
        horizontal: dimens.space4,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.borderSubtle,
            width: dimens.borderHairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.arrow_back,
              size: dimens.iconMd,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(width: dimens.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: AppTypography.medium,
                    height: 20 / 15,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: dimens.space1),
                Text(
                  '$symbol · $market',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: AppTypography.regular,
                    height: 14 / 11,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          // 관심 등록 상태만 반영
          ListenableBuilder(
            listenable: favorites,
            builder: (BuildContext context, Widget? _) {
              final bool isFavorite = favorites.isFavorite(id);
              return Icon(
                isFavorite ? Icons.star : Icons.star_border,
                size: dimens.iconLg,
                color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
              );
            },
          ),
        ],
      ),
    );
  }
}
