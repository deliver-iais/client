import 'package:deliver_flutter/shared/methods/isPersian.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isPersianFuncyion', () {
    test('text is persian', () {
      expect('سلام خداحافظ'.isPersian(), true);
    });
    test('text is english', () {
      expect('hi bye'.isPersian(), false);
    });
    test(
        'text start with persian character but text has some english characters',
        () {
      expect('س a'.isPersian(), true);
    });
    test(
        'text start with english character but text has some english characters',
        () {
      expect('a س'.isPersian(), false);
    });
    test('text start with plus sign and keeps on english character', () {
      expect('+plus'.isPersian(), false);
    });
    test('text start with plus sign and keeps on persian character', () {
      expect('+جمع'.isPersian(), true);
    });
    test('text start with minus sign and keeps on english character', () {
      expect('-minus'.isPersian(), false);
    });
    test('text start with minus sign and keeps on persian character', () {
      expect('-تفریق'.isPersian(), true);
    });
    test('text start with multiply sign and keeps on english character', () {
      expect('*multiply'.isPersian(), false);
    });
    test('text start with multiply sign and keeps on persian character', () {
      expect('*ضرب'.isPersian(), true);
    });
    test('text start with division sign and keeps on english character', () {
      expect('/division'.isPersian(), false);
    });
    test('text start with division sign and keeps on persian character', () {
      expect('/تقسیم'.isPersian(), true);
    });
    test('text start with underline sign and keeps on english character', () {
      expect('_underline'.isPersian(), false);
    });
    test('text start with underline sign and keeps on persian character', () {
      expect('_زیرخط'.isPersian(), true);
    });
    test('text start with english number', () {
      expect('12345'.isPersian(), false);
    });
    // test('text start with persian number', () {
    //   expect(''.isPersian(), true);
    // });
    test('text start with space and keeps on english character', () {
      expect(' space'.isPersian(), false);
    });
    test('text start with space and keeps on persian character', () {
      expect(' اسپیس'.isPersian(), true);
    });
    test('text start with tab and keeps on english character', () {
      expect('\ttab'.isPersian(), false);
    });
    test('text start with tab and keeps on persian character', () {
      expect('\tتب'.isPersian(), true);
    });
    test('text start with newline and keeps on english character', () {
      expect('\nnewline'.isPersian(), false);
    });
    test('text start with newline and keeps on persian character', () {
      expect('\nخط بعد'.isPersian(), true);
    });
    test('empty text', () {
      expect(''.isPersian(), false);
    });
  });
}
