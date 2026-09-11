import 'package:flutter/material.dart';

import '../models/stock_search_result.dart';
import '../state/favorites_controller.dart';
import '../theme/theme.dart'; // context.colors, context.dimens 등 토큰을 쓰기 위한 import

// 관심 화면, 여기서는 내용물만
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, required this.favorites});

  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _WatchlistHeader(),
        Expanded(
          // favorites 바뀔 때마다 목록만 다시 그림
          child: ListenableBuilder(
            listenable: favorites,
            builder: (BuildContext context, Widget? _) {
              final List<StockSearchResult> items = favorites.items;
              return items.isEmpty
                  ? const _WatchlistEmptyState()
                  : _WatchlistList(items: items);
            },
          ),
        ),
      ],
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

// 관심 종목 목록
class _WatchlistList extends StatelessWidget {
  const _WatchlistList({required this.items});

  final List<StockSearchResult> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _WatchlistRow(result: items[index]);
      },
    );
  }
}

// 관심 종목 한 줄. 왼쪽은 이름/코드, 오른쪽은 시세
class _WatchlistRow extends StatelessWidget {
  const _WatchlistRow({required this.result});

  final StockSearchResult result;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final _MockQuote quote = _mockQuoteFor(result.symbol);

    final Color changeColor = quote.changeAmount > 0
        ? colors.priceUpText
        : quote.changeAmount < 0
            ? colors.priceDownText
            : colors.priceFlatText;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: dimens.space3,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  result.name,
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
                  '${result.symbol} · ${result.market}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                _formatThousands(quote.currentPrice),
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
                '${_formatChangeAmount(quote.changeAmount)} (${_formatChangeRate(quote.changeRate)})',
                style: TextStyle(
                  color: changeColor,
                  fontSize: 11,
                  fontWeight: AppTypography.regular,
                  height: 14 / 11,
                  letterSpacing: 0,
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

// TODO: 실시간 시세 API 연동
// 목데이터로 현재가/등락을 채움, 목록에 없는 심볼은 등락 없음 으로 처리
class _MockQuote {
  const _MockQuote({required this.currentPrice, required this.previousClose});

  final int currentPrice;
  final int previousClose;

  int get changeAmount => currentPrice - previousClose;
  double get changeRate => previousClose == 0 ? 0 : changeAmount / previousClose;
}

const Map<String, _MockQuote> _mockQuotes = <String, _MockQuote>{
  '005930': _MockQuote(currentPrice: 179700, previousClose: 180100), // 삼성전자
  '000660': _MockQuote(currentPrice: 412500, previousClose: 403000), // SK하이닉스
  '035720': _MockQuote(currentPrice: 61300, previousClose: 62100), // 카카오
  '247540': _MockQuote(currentPrice: 195400, previousClose: 195400), // 에코프로비엠
};

_MockQuote _mockQuoteFor(String symbol) {
  return _mockQuotes[symbol] ?? const _MockQuote(currentPrice: 0, previousClose: 0);
}

// 천 단위 콤마만 찍어주는 용도라 intl 패키지 없이 직접 구현
String _formatThousands(int value) {
  final bool isNegative = value < 0;
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return (isNegative ? '-' : '') + buffer.toString();
}

String _formatChangeAmount(int amount) {
  return amount > 0 ? '+${_formatThousands(amount)}' : _formatThousands(amount);
}

String _formatChangeRate(double rate) {
  final double percent = rate * 100;
  final String sign = percent > 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(2)}%';
}
