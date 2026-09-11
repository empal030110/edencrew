import 'package:flutter/foundation.dart';

// 관심 등록된 종목 id(canonical, domestic:{symbol}) 집합
// 검색 화면과 관심 화면이 같은 상태를 봐야 함 -> AppShell에서 하나만 만들어 두 화면에 내려줌
// 이름/거래소 같은 메타데이터는 여기서 안 들고 있음 -> 관심 화면이 종목 메타데이터 API로 직접 조회
class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = <String>{};

  bool isFavorite(String id) => _ids.contains(id);

  Set<String> get ids => Set<String>.unmodifiable(_ids);

  // 등록/해제를 토글하고, 토글 후 관심 등록 상태인지를 돌려줌
  bool toggle(String id) {
    final bool isNowFavorite = !_ids.contains(id);
    if (isNowFavorite) {
      _ids.add(id);
    } else {
      _ids.remove(id);
    }
    notifyListeners();
    return isNowFavorite;
  }
}
