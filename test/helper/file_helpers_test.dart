
import 'dart:io';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('check file type detector', () async {
    final filePath =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test_wrong.png";
    final type = detectFileMimeByFilePath(filePath);

    expect(type, DEFAULT_FILE_TYPE);

    final filePath2 =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test.jpeg";
    final type2 = detectFileMimeByFilePath(filePath2);

    expect(type2, "image/jpeg");
  });

  test('check upload file Content match with extension', () async {
    final filePath =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test_wrong.png";
    final isMatch = isFileContentMimeMatchFileExtensionMime(filePath);

    expect(isMatch, false);

    final filePath2 =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test.jpeg";
    final isMatch2 = isFileContentMimeMatchFileExtensionMime(filePath2);

    expect(isMatch2, true);
  });
}
