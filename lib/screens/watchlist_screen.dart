import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../data/stock_metadata_repository.dart';
import '../data/stock_realtime_quote_repository.dart';
import '../models/stock_quote.dart';
import '../models/stock_search_result.dart';
import '../state/favorites_controller.dart';
import '../theme/theme.dart'; // context.colors, context.dimens 등 토큰을 쓰기 위한 import

// 관심 화면
// 이름/거래소(메타데이터)랑 시세는 관심 목록이 바뀔 때마다 한 번에 조회 -> StatefulWidget으로 관리
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key, required this.favorites});

  final FavoritesController favorites;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final StockMetadataRepository _metadataRepository = StockMetadataRepository();
  final StockRealtimeQuoteRepository _quoteRepository = StockRealtimeQuoteRepository();
  Map<String, StockSearchResult> _metadata = const <String, StockSearchResult>{};
  Map<String, StockQuote> _quotes = const <String, StockQuote>{};
  Set<String> _lastFetchedIds = const <String>{};

  @override
  void initState() {
    super.initState();
    widget.favorites.addListener(_onFavoritesChanged);
    _onFavoritesChanged();
  }

  @override
  void dispose() {
    widget.favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    final Set<String> ids = widget.favorites.ids;
    if (ids.isEmpty) {
      setState(() {
        _metadata = const <String, StockSearchResult>{};
        _quotes = const <String, StockQuote>{};
        _lastFetchedIds = const <String>{};
      });
      return;
    }
    if (setEquals(ids, _lastFetchedIds)) return; // 종목 구성 그대로면 다시 요청 안 함
    _lastFetchedIds = ids;
    final List<String> symbols = ids.map(symbolFromCanonicalId).toList();
    _loadMetadata(symbols);
    _loadQuotes(symbols);
  }

  Future<void> _loadMetadata(List<String> symbols) async {
    final Map<String, StockSearchResult> metadata = await _metadataRepository.fetchAll(symbols);
    if (!mounted) return;
    setState(() => _metadata = metadata);
  }

  Future<void> _loadQuotes(List<String> symbols) async {
    final Map<String, StockQuote> quotes = await _quoteRepository.fetch(symbols);
    if (!mounted) return;
    setState(() => _quotes = quotes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _WatchlistHeader(),
        Expanded(
          // favorites 바뀔 때마다 목록만 다시 그림
          child: ListenableBuilder(
            listenable: widget.favorites,
            builder: (BuildContext context, Widget? _) {
              final List<String> symbols =
                  widget.favorites.ids.map(symbolFromCanonicalId).toList();
              return symbols.isEmpty
                  ? const _WatchlistEmptyState()
                  : _WatchlistList(symbols: symbols, metadata: _metadata, quotes: _quotes);
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
              GestureDetector(
                onTap: () => _showSortSheet(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
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
                  ],
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

void _showSortSheet(BuildContext context) {
  final AppDimens dimens = context.dimens;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.surfaceOverlay,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(dimens.radiusXl),
        topRight: Radius.circular(dimens.radiusXl),
      ),
    ),
    builder: (BuildContext context) => const _SortSheet(),
  );
}

// 정렬 옵션 3개. TODO: 실제로 목록에 적용하는 기능은 나중에
enum _SortOption { byPrice, byChangeRate, byName }

// 정렬 바텀시트. 지금은 UI만 -> 탭하면 체크 표시만 바뀌고 실제 정렬 반영은 안 함
class _SortSheet extends StatefulWidget {
  const _SortSheet();

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  _SortOption _selected = _SortOption.byName; // 기본 정렬

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Padding(
      padding: EdgeInsets.only(bottom: 34), // 토큰에 없는 값
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 21, horizontal: dimens.space6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '정렬',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 19,
                  fontWeight: AppTypography.bold,
                  height: 22 / 19,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          _SortOptionRow(
            label: '현재가순',
            selected: _selected == _SortOption.byPrice,
            onTap: () => setState(() => _selected = _SortOption.byPrice),
          ),
          _SortOptionRow(
            label: '등락률순',
            selected: _selected == _SortOption.byChangeRate,
            onTap: () => setState(() => _selected = _SortOption.byChangeRate),
          ),
          _SortOptionRow(
            label: '가나다순',
            selected: _selected == _SortOption.byName,
            onTap: () => setState(() => _selected = _SortOption.byName),
          ),
        ],
      ),
    );
  }
}

class _SortOptionRow extends StatelessWidget {
  const _SortOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final Color color = selected ? colors.textPrimary : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: dimens.space6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: AppTypography.medium,
                height: 20 / 15,
                letterSpacing: -0.1,
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                size: dimens.space6, // 24px. 기존 space6(24)이랑 값이 같아서 그대로 재사용
                color: colors.textFafafa,
              ),
          ],
        ),
      ),
    );
  }
}

// 관심 종목 목록
class _WatchlistList extends StatelessWidget {
  const _WatchlistList({
    required this.symbols,
    required this.metadata,
    required this.quotes,
  });

  final List<String> symbols;
  final Map<String, StockSearchResult> metadata;
  final Map<String, StockQuote> quotes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: symbols.length,
      itemBuilder: (BuildContext context, int index) {
        final String symbol = symbols[index];
        return _WatchlistRow(
          symbol: symbol,
          metadata: metadata[symbol],
          quote: quotes[symbol],
        );
      },
    );
  }
}

// 관심 종목 한 줄. 왼쪽은 이름/코드, 오른쪽은 시세
// metadata/quote가 null이면 아직 그 API 응답이 안 온 상태
class _WatchlistRow extends StatelessWidget {
  const _WatchlistRow({required this.symbol, required this.metadata, required this.quote});

  final String symbol;
  final StockSearchResult? metadata;
  final StockQuote? quote;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final String name = metadata?.name ?? symbol; // 메타데이터 오기 전엔 심볼로 대신 표시
    final String market = metadata?.market ?? '-';

    final Color changeColor = quote == null
        ? colors.textTertiary
        : quote!.changeAmount > 0
            ? colors.priceUpText
            : quote!.changeAmount < 0
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                quote == null ? '-' : _formatThousands(quote!.currentPrice),
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
                quote == null
                    ? '조회 중'
                    : '${_formatChangeAmount(quote!.changeAmount)} (${_formatChangeRate(quote!.changeRate)})',
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
