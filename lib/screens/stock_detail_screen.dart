import 'package:flutter/material.dart';

import '../state/favorites_controller.dart';
import '../theme/theme.dart';
import '../utils/favorite_toast.dart';
import '../utils/number_format.dart';

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
          // TODO: 하드코딩 -> 실시간 시세 API 연동하기
          const _PriceSection(currentPrice: 179700, changeAmount: -400, changeRate: -0.0022),
          Expanded(
            child: Center(
              child: Text(
                '$name 상세 페이지 (차트는 나중에)',
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
          ListenableBuilder(
            listenable: favorites,
            builder: (BuildContext context, Widget? _) {
              final bool isFavorite = favorites.isFavorite(id);
              return GestureDetector(
                onTap: () {
                  final bool isNowFavorite = favorites.toggle(id);
                  showFavoriteToast(context, isFavorite: isNowFavorite);
                },
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  size: dimens.iconLg,
                  color: isFavorite ? colors.favoriteActive : colors.favoriteInactive,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 현재가 + 등락. changeRate는 (nv-pcv)/pcv 형태의 소수(예: -0.0022 = -0.22%)
class _PriceSection extends StatelessWidget {
  const _PriceSection({
    required this.currentPrice,
    required this.changeAmount,
    required this.changeRate,
  });

  final int currentPrice;
  final int changeAmount;
  final double changeRate;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    final Color changeColor = changeAmount > 0
        ? colors.priceUpText
        : changeAmount < 0
            ? colors.priceDownText
            : colors.priceFlatText;

    // 등락률 부호
    final String arrow = changeAmount > 0 ? '▲ ' : changeAmount < 0 ? '▼ ' : '';
    final double percent = changeRate * 100;
    final String percentSign = percent > 0 ? '+' : '';
    final String changeText = '$arrow${formatThousands(changeAmount.abs())} ($percentSign${percent.toStringAsFixed(2)}%)';

    return Padding(
      padding: EdgeInsets.only(
        top: 14, // 토큰에 없는 값
        left: dimens.space4,
        right: dimens.space4,
        bottom: dimens.space4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            formatThousands(currentPrice),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 30,
              fontWeight: AppTypography.bold,
              height: 36 / 30,
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(width: dimens.space2),
          Text(
            changeText,
            style: TextStyle(
              color: changeColor,
              fontSize: 15,
              fontWeight: AppTypography.medium,
              height: 20 / 15,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
