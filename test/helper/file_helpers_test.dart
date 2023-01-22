
import 'dart:io';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('check file type detector', () async {
    final filePath =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test_wrong.png";
    final type = detectFileMimeByFileModel(pathToFileModel(filePath));

    expect(type, DEFAULT_FILE_TYPE);

    final filePath2 =
        "${Directory.current.path.replaceAll("\\", "/")}/test/resources/test.jpeg";
    final type2 = detectFileMimeByFileModel(pathToFileModel(filePath2));

    expect(type2, "image/jpeg");
  });
}
