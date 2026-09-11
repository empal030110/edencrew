import 'package:flutter_test/flutter_test.dart';

import 'package:edencrew_assignment_starter/state/favorites_controller.dart';

void main() {
  test('toggle하면 등록/해제가 번갈아 일어나고 리스너에 알린다', () {
    final controller = FavoritesController();
    int notifyCount = 0;
    controller.addListener(() => notifyCount++);

    expect(controller.isFavorite('domestic:005930'), isFalse);

    expect(controller.toggle('domestic:005930'), isTrue); // 등록
    expect(controller.isFavorite('domestic:005930'), isTrue);
    expect(controller.ids, <String>{'domestic:005930'});
    expect(notifyCount, 1);

    expect(controller.toggle('domestic:005930'), isFalse); // 해제
    expect(controller.isFavorite('domestic:005930'), isFalse);
    expect(controller.ids, isEmpty);
    expect(notifyCount, 2);
  });
}
