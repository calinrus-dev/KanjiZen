import 'package:flutter_test/flutter_test.dart';
import 'package:kz_core/kz_core.dart';

void main() {
  test('KzConstants contains maxHistoryBlob', () {
    expect(KzConstants.maxHistoryBlob, equals(50));
  });
}
