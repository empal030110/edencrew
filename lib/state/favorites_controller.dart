import 'package:flutter/foundation.dart';

import '../models/stock_search_result.dart';

// 관심 등록된 종목을 id 기준으로 들고 있는 상태 저장소
// 검색 화면과 관심 화면이 같은 상태를 봐야 함 -> AppShell에서 하나만 만들어 두 화면에 내려줌
// 이름/코드/거래소까지 같이 저장하는 이유: 관심 화면에서 목록 렌더링할 때 다시 조회 안 해도 되게
class FavoritesController extends ChangeNotifier {
  final Map<String, StockSearchResult> _favorites = <String, StockSearchResult>{};

  bool isFavorite(String id) => _favorites.containsKey(id);

  List<StockSearchResult> get items => _favorites.values.toList();

  // 등록/해제를 토글하고, 토글 후 관심 등록 상태인지를 돌려줌
  bool toggle(StockSearchResult result) {
    final bool isNowFavorite = !_favorites.containsKey(result.id);
    if (isNowFavorite) {
      _favorites[result.id] = result;
    } else {
      _favorites.remove(result.id);
    }
    notifyListeners();
    return isNowFavorite;
  }
}
