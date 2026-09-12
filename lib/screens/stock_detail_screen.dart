import 'package:flutter/material.dart';

import '../data/stock_realtime_quote_repository.dart';
import '../models/stock_quote.dart';
import '../state/favorites_controller.dart';
import '../theme/theme.dart';
import '../utils/favorite_toast.dart';
import '../utils/number_format.dart';

// 종목 상세 화면
class StockDetailScreen extends StatefulWidget {
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
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final StockRealtimeQuoteRepository _quoteRepository = StockRealtimeQuoteRepository();
  StockQuote? _quote;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    final Map<String, StockQuote> quotes = await _quoteRepository.fetch(<String>[widget.symbol]);
    if (!mounted) return;
    setState(() => _quote = quotes[widget.symbol]);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final StockQuote? quote = _quote;

    return Scaffold(
      backgroundColor: colors.surfaceBase,
      body: Column(
        children: <Widget>[
          _DetailHeader(
            symbol: widget.symbol,
            name: widget.name,
            market: widget.market,
            favorites: widget.favorites,
          ),
          if (quote != null)
            _PriceSection(
              currentPrice: quote.currentPrice,
              changeAmount: quote.changeAmount,
              changeRate: quote.changeRate,
            ),
          Expanded(
            child: Center(
              child: Text(
                '${widget.name} 상세 페이지 (차트는 나중에)',
                style: TextStyle(color: colors.textPrimary, fontSize: 15),
              ),
            ),
          ),
          if (quote != null) _StatsSection(quote: quote),
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

// 시가/고가/저가 + 거래량/시가총액
class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.quote});

  final StockQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.all(dimens.space4),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: _StatCard(title: '시가', value: formatThousands(quote.open))),
              SizedBox(width: dimens.space2),
              Expanded(child: _StatCard(title: '고가', value: formatThousands(quote.high))),
              SizedBox(width: dimens.space2),
              Expanded(child: _StatCard(title: '저가', value: formatThousands(quote.low))),
            ],
          ),
          SizedBox(height: dimens.space2),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  title: '거래량',
                  value: _formatThousandUnit(quote.accumulatedVolume),
                ),
              ),
              SizedBox(width: dimens.space2),
              Expanded(
                child: _StatCard(
                  title: '시가총액',
                  value: _formatTrillionUnit(quote.marketCap),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10), // 토큰에 없는 값
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: BorderRadius.circular(dimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 11,
              fontWeight: AppTypography.regular,
              height: 14 / 11,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: dimens.space1),
          Text(
            value,
            style: TextStyle(
              color: colors.textPrimary,
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

// 거래량은 "29,113천" 형태
String _formatThousandUnit(int value) => '${formatThousands((value / 1000).round())}천';

// 시가총액은 "1,063조" 형태
String _formatTrillionUnit(int value) => '${formatThousands((value / 1000000000000).round())}조';
