import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_info.freezed.dart';

part 'file_info.g.dart';

@freezed
class FileInfo with _$FileInfo {
  const factory FileInfo({
    required String name,
    required String uuid,
    required String sizeType,
    required String path,
  }) = _FileInfo;

  factory FileInfo.fromJson(Map<String, Object?> json) =>
      _$FileInfoFromJson(json);
}
