import 'dart:async';

import 'package:flutter/material.dart';

import '../data/stock_autocomplete_repository.dart';
import '../models/stock_search_result.dart';
import '../state/favorites_controller.dart';
import '../theme/theme.dart';
import '../utils/favorite_toast.dart';
import '../utils/highlight_text.dart';
import 'stock_detail_screen.dart';

// 검색 화면, 검색어가 바뀔 때마다 결과 목록을 들고 있어야 함 -> 서치바와 결과 리스트가 같은 상태를 공유
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.favorites});

  final FavoritesController favorites;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  List<StockSearchResult> _results = const <StockSearchResult>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(
          onResultsChanged: (String query, List<StockSearchResult> results) {
            setState(() {
              _query = query;
              _results = results;
            });
          },
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // 검색 전 / 결과 있음 / 검색했는데 결과 없음, 세 가지로 나뉨
  Widget _buildBody() {
    if (_query.trim().isEmpty) return const _SearchEmptyState();
    if (_results.isEmpty) return _SearchNoResultsState(query: _query);
    return _SearchResultList(
      query: _query,
      results: _results,
      favorites: widget.favorites,
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onResultsChanged});

  final void Function(String query, List<StockSearchResult> results) onResultsChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();
  final StockAutocompleteRepository _repository = StockAutocompleteRepository();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose(); // 컨트롤러는 안 쓸 때 직접 정리해줘야 메모리 누수가 안 남
    super.dispose();
  }

  // 300ms debounce
  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final List<StockSearchResult> results = await _repository.search(query);
      if (!mounted) return;
      widget.onResultsChanged(query, results);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onResultsChanged('', const <StockSearchResult>[]);
    setState(() {}); // x 누른 직후 바로 반영
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
                onChanged: _onQueryChanged,
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
              onTap: _clear,
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

// 검색 결과 목록
class _SearchResultList extends StatelessWidget {
  const _SearchResultList({
    required this.query,
    required this.results,
    required this.favorites,
  });

  final String query;
  final List<StockSearchResult> results;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultRow(
          query: query,
          result: results[index],
          favorites: favorites,
        );
      },
    );
  }
}

// 검색 목록
class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({
    required this.query,
    required this.result,
    required this.favorites,
  });

  final String query;
  final StockSearchResult result;
  final FavoritesController favorites;

  void _toggleFavorite(BuildContext context) {
    final bool isNowFavorite = favorites.toggle(result.id);
    showFavoriteToast(context, isFavorite: isNowFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;
    final TextStyle nameStyle = TextStyle(
      color: colors.textPrimary,
      fontSize: 15,
      fontWeight: AppTypography.medium,
      height: 20 / 15,
      letterSpacing: -0.1,
    );

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                StockDetailScreen(symbol: result.symbol, name: result.name, market: result.market, favorites: favorites),
        ),
      ),
      child: Container(
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
                  Text.rich(
                    TextSpan(
                      children: highlightedSpans(
                        text: result.name,
                        query: query,
                        baseStyle: nameStyle,
                        highlightColor: colors.searchHighlight,
                      ),
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
            // favorites가 바뀔 때마다 별 색만 다시 그리면 됨 —> 여기만 ListenableBuilder로 감쌈
            ListenableBuilder(
              listenable: favorites,
              builder: (BuildContext context, Widget? _) {
                final bool isFavorite = favorites.isFavorite(result.id);
                return GestureDetector(
                  onTap: () => _toggleFavorite(context),
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
      ),
    );
  }
}

// 검색했는데 결과가 하나도 없을 때
class _SearchNoResultsState extends StatelessWidget {
  const _SearchNoResultsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'assets/icons/ico_search_empty.png',
            width: 40,
            height: 40,
            color: colors.textTertiary,
            colorBlendMode: BlendMode.srcIn,
          ),
          SizedBox(height: dimens.space3),
          Text(
            '검색 결과가 없습니다',
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
            "'$query'와\n일치하는 검색 결과를 찾지 못했습니다.",
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
            size: 40,
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
