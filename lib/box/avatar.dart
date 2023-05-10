import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'avatar.freezed.dart';

part 'avatar.g.dart';

@freezed
class Avatar with _$Avatar {
  const factory Avatar({
    @UidJsonKey required Uid uid,
    required String fileName,
    required String fileUuid,
    required int lastUpdateTime,
    @Default(false) bool avatarIsEmpty,
    required int createdOn,
  }) = _Avatar;

  factory Avatar.fromJson(Map<String, Object?> json) => _$AvatarFromJson(json);
}
