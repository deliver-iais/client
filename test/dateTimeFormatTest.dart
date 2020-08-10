import 'package:flutter_test/flutter_test.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';

void main() {
  group('dateTimeFormatFunction', () {
    test('less than 2 minute ago', () {
      expect(DateTime.now().dateTimeFormat(), 'just now');
    });
    test('more than 2 minute ago and less than a week', () {
      expect(DateTime(2020, 8, 5).dateTimeFormat(), 'Wed');
    });
    test('more than a week', () {
      expect(DateTime(2020, 8, 2).dateTimeFormat(), 'Aug 2');
    });
  });
}
