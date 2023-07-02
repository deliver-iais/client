import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'uid_id_name.g.dart';

part 'uid_id_name.freezed.dart';

@freezed
class UidIdName with _$UidIdName {
  const factory UidIdName({
    @UidJsonKey required Uid uid,
    String? id,
    String? name,
    String? realName,
    @Default(0) int lastUpdateTime,
  }) = _UidIdName;

  factory UidIdName.fromJson(Map<String, Object?> json) =>
      UidIdName.fromJson(json);
}
