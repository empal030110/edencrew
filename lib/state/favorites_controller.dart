import 'package:flutter/foundation.dart';

// 관심 등록된 종목 id를 들고 있는 상태 저장소.
// 검색 화면(별 토글)과 관심 화면(목록 표시)이 같은 상태를 봐야 함 -> AppShell에서 하나만 만들어 두 화면에 내려줌
class FavoritesController extends ChangeNotifier {
  final Set<String> _favoriteIds = <String>{};

  bool isFavorite(String id) => _favoriteIds.contains(id);

  // 등록/해제를 토글하고, 토글 후 관심 등록 상태인지를 돌려줌
  bool toggle(String id) {
    final bool isNowFavorite = !_favoriteIds.contains(id);
    if (isNowFavorite) {
      _favoriteIds.add(id);
    } else {
      _favoriteIds.remove(id);
    }
    notifyListeners();
    return isNowFavorite;
  }
}
