import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/models/stock_search_result.dart';
import 'package:edencrew_assignment_starter/state/favorites_controller.dart';

void main() {
  const samsung = StockSearchResult(
    id: 'domestic:005930',
    symbol: '005930',
    name: '삼성전자',
    market: '코스피',
  );

  test('toggle하면 등록/해제가 번갈아 일어나고 리스너에 알린다', () {
    final controller = FavoritesController();
    int notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.isFavorite(samsung.id), isFalse);

    expect(controller.toggle(samsung), isTrue); // 등록
    expect(controller.isFavorite(samsung.id), isTrue);
    expect(controller.items, <StockSearchResult>[samsung]);
    expect(notifyCount, 1);

    expect(controller.toggle(samsung), isFalse); // 해제
    expect(controller.isFavorite(samsung.id), isFalse);
    expect(controller.items, isEmpty);
    expect(notifyCount, 2);
  });
}
