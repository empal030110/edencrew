import 'package:flutter/material.dart';

import '../data/daily_quote_repository.dart';
import '../data/stock_realtime_quote_repository.dart';
import '../models/daily_quote.dart';
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
  final DailyQuoteRepository _dailyQuoteRepository = DailyQuoteRepository();
  StockQuote? _quote;
  List<DailyQuote> _dailyQuotes = const <DailyQuote>[];
  _Period _period = _Period.oneMonth; // 기본 1개월

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _loadDailyQuotes();
  }

  Future<void> _loadQuote() async {
    final Map<String, StockQuote> quotes = await _quoteRepository.fetch(<String>[widget.symbol]);
    if (!mounted) return;
    setState(() => _quote = quotes[widget.symbol]);
  }

  Future<void> _loadDailyQuotes() async {
    final int days = _periodTradingDays[_period]!;
    final List<DailyQuote> quotes = await _dailyQuoteRepository.fetchDays(widget.symbol, days);
    if (!mounted) return;
    setState(() => _dailyQuotes = quotes);
  }

  void _onPeriodSelected(_Period period) {
    if (period == _period) return;
    setState(() => _period = period);
    _loadDailyQuotes();
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
          // 헤더는 고정, 그 아래만 스크롤
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  if (quote != null)
                    _PriceSection(
                      currentPrice: quote.currentPrice,
                      changeAmount: quote.changeAmount,
                      changeRate: quote.changeRate,
                    ),
                  _PeriodTabs(selected: _period, onSelected: _onPeriodSelected),
                  if (_dailyQuotes.isNotEmpty) _CandleChart(quotes: _dailyQuotes),
                  if (quote != null) _StatsSection(quote: quote),
                  if (_dailyQuotes.isNotEmpty) _DailyQuoteSection(quotes: _dailyQuotes),
                ],
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
        vertical: 10,
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
            child: Image.asset(
              'assets/icons/ico_back.png',
              width: dimens.iconMd,
              height: dimens.iconMd,
              color: colors.textSecondary,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          SizedBox(width: dimens.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
        top: 14,
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

// 캔들 차트, quotes는 최신순으로 옴 -> 오래된 날짜가 왼쪽에 오도록 그림
class _CandleChart extends StatelessWidget {
  const _CandleChart({required this.quotes});

  final List<DailyQuote> quotes;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dimens.space4,
        horizontal: dimens.space4,
      ),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: CustomPaint(
          painter: _CandleChartPainter(
            quotes: quotes.reversed.toList(),
            upColor: colors.chartLineUp,
            downColor: colors.chartLineDown,
            flatColor: colors.chartLineFlat,
          ),
        ),
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  _CandleChartPainter({
    required this.quotes,
    required this.upColor,
    required this.downColor,
    required this.flatColor,
  });

  final List<DailyQuote> quotes;
  final Color upColor;
  final Color downColor;
  final Color flatColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (quotes.isEmpty) return;

    int high = quotes.first.highPrice;
    int low = quotes.first.lowPrice;
    for (final DailyQuote quote in quotes) {
      if (quote.highPrice > high) high = quote.highPrice;
      if (quote.lowPrice < low) low = quote.lowPrice;
    }
    final double range = (high - low).toDouble();
    if (range == 0) return; // 기간 내내 가격 변동이 아예 없으면 그릴 게 없음

    final double slotWidth = size.width / quotes.length;
    final double candleWidth = slotWidth * 0.6; // 캔들 사이 간격

    double yFor(int price) => size.height - (price - low) / range * size.height;

    for (int i = 0; i < quotes.length; i++) {
      final DailyQuote quote = quotes[i];
      final double centerX = slotWidth * i + slotWidth / 2;
      // 그날 시가 대비 종가가 아니라 전일 대비(changeAmount)로 판단해야
      // 일별 시세 표/상단 등락이랑 색이 일치함
      final Color color = quote.changeAmount > 0
          ? upColor
          : quote.changeAmount < 0
              ? downColor
              : flatColor;
      final Paint paint = Paint()..color = color;

      // 꼬리(고가 ~ 저가)
      canvas.drawLine(
        Offset(centerX, yFor(quote.highPrice)),
        Offset(centerX, yFor(quote.lowPrice)),
        paint..strokeWidth = 1,
      );

      // 몸통(시가 ~ 종가), 시가==종가여도 최소 1px은 보이게 clamp
      final double openY = yFor(quote.openPrice);
      final double closeY = yFor(quote.closePrice);
      final double top = openY < closeY ? openY : closeY;
      final double bottom = openY < closeY ? closeY : openY;
      canvas.drawRect(
        Rect.fromLTWH(centerX - candleWidth / 2, top, candleWidth, (bottom - top).clamp(1, double.infinity)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return oldDelegate.quotes != quotes;
  }
}

// 기간 탭. 선택 상태는 상위(_StockDetailScreenState)가 들고 있음 -> 탭이 바뀌면 일별 시세를 그 기간만큼 다시 조회해야 해서
enum _Period { oneMonth, threeMonths, sixMonths, oneYear }

const Map<_Period, String> _periodLabels = <_Period, String>{
  _Period.oneMonth: '1개월',
  _Period.threeMonths: '3개월',
  _Period.sixMonths: '6개월',
  _Period.oneYear: '1년',
};

// 기간별 거래일 수
const Map<_Period, int> _periodTradingDays = <_Period, int>{
  _Period.oneMonth: 20,
  _Period.threeMonths: 60,
  _Period.sixMonths: 120,
  _Period.oneYear: 245,
};

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onSelected});

  final _Period selected;
  final ValueChanged<_Period> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimens.space4),
      child: Row(
        children: <Widget>[
          for (final _Period period in _Period.values) ...<Widget>[
            // 탭 4개가 화면 너비를 똑같이 나눠 가짐 -> 화면이 넓어지면 같이 늘어남
            Expanded(
              child: _PeriodTab(
                label: _periodLabels[period]!,
                selected: period == selected,
                onTap: () => onSelected(period),
              ),
            ),
            if (period != _Period.values.last) SizedBox(width: dimens.space1),
          ],
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  const _PeriodTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.accentBg : null,
          borderRadius: BorderRadius.circular(dimens.radiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.accentDefault : colors.textSecondary,
            fontSize: 13,
            fontWeight: AppTypography.regular,
            height: 18 / 13,
            letterSpacing: 0,
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
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

// date(yyyyMMdd)를 "MM.DD"로 바꿔서 보여줌
String _displayDate(String yyyyMMdd) => '${yyyyMMdd.substring(4, 6)}.${yyyyMMdd.substring(6, 8)}';

// 일별 시세 표
class _DailyQuoteSection extends StatelessWidget {
  const _DailyQuoteSection({required this.quotes});

  final List<DailyQuote> quotes;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dimens.space4,
        dimens.space6,
        dimens.space4,
        22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '일별 시세',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: AppTypography.bold,
              height: 18 / 13,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: dimens.space1),
          const _DailyQuoteHeaderRow(),
          for (final DailyQuote quote in quotes) _DailyQuoteRow(quote: quote),
        ],
      ),
    );
  }
}

class _DailyQuoteHeaderRow extends StatelessWidget {
  const _DailyQuoteHeaderRow();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle style = TextStyle(
      color: colors.textSecondary,
      fontSize: 11,
      fontWeight: AppTypography.regular,
      height: 14 / 11,
      letterSpacing: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Expanded(child: Text('날짜', style: style)),
          Expanded(child: Text('종가', textAlign: TextAlign.right, style: style)),
          Expanded(child: Text('등락', textAlign: TextAlign.right, style: style)),
          Expanded(child: Text('거래량', textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}

class _DailyQuoteRow extends StatelessWidget {
  const _DailyQuoteRow({required this.quote});

  final DailyQuote quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final Color changeColor = quote.changeAmount > 0
        ? colors.priceUpText
        : quote.changeAmount < 0
            ? colors.priceDownText
            : colors.priceFlatText;

    TextStyle cellStyle(Color color) => TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: AppTypography.regular,
          height: 14 / 11,
          letterSpacing: 0,
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderSubtle, width: dimens.borderHairline),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(_displayDate(quote.date), style: cellStyle(colors.textSecondary))),
          Expanded(
            child: Text(
              formatThousands(quote.closePrice),
              textAlign: TextAlign.right,
              style: cellStyle(colors.textPrimary),
            ),
          ),
          Expanded(
            child: Text(
              formatSignedThousands(quote.changeAmount),
              textAlign: TextAlign.right,
              style: cellStyle(changeColor),
            ),
          ),
          Expanded(
            child: Text(
              formatThousands(quote.volume),
              textAlign: TextAlign.right,
              style: cellStyle(colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
