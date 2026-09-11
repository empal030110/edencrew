import 'dart:async';

import 'package:flutter/material.dart';

import '../data/stock_autocomplete_repository.dart';
import '../models/stock_search_result.dart';
import '../theme/theme.dart';

// 검색 화면, 검색어가 바뀔 때마다 결과 목록을 들고 있어야 함 -> 서치바와 결과 리스트가 같은 상태를 공유
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<StockSearchResult> _results = const <StockSearchResult>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SearchBar(
          onResultsChanged: (List<StockSearchResult> results) {
            setState(() => _results = results);
          },
        ),
        Expanded(
          // 검색 전이면 안내 문구, 결과 있으면 목록
          // TODO: 검색했는데 결과가 0건인 경우 개발 필요 -> 일단은 검색 전이랑 동일하게
          child: _results.isEmpty
              ? const _SearchEmptyState()
              : _SearchResultList(results: _results),
        ),
      ],
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onResultsChanged});

  final ValueChanged<List<StockSearchResult>> onResultsChanged;

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
      widget.onResultsChanged(results);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onResultsChanged(const <StockSearchResult>[]);
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
  const _SearchResultList({required this.results});

  final List<StockSearchResult> results;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultRow(result: results[index]);
      },
    );
  }
}

// 검색 목록
class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.result});

  final StockSearchResult result;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

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
          Icon(
            Icons.star_border,
            size: dimens.iconLg,
            color: colors.favoriteInactive,
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
