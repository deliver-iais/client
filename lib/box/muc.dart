import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'muc.freezed.dart';

part 'muc.g.dart';

@freezed
class Muc with _$Muc {
  const factory Muc({
    @UidJsonKey required Uid uid,
    @Default("") String name,
    @Default("") String token,
    @Default("") String id,
    @Default("") String info,
    @Default([]) List<int> pinMessagesIdList,
    @Default(0) int population,
    @Default(0) int lastCanceledPinMessageId,
    @Default(0) int lastUpdateTime,
    @Default(MucType.Public) MucType mucType,
    @Default(MucRole.NONE) MucRole currentUserRole,
    @Default(true) bool synced,
  }) = _Muc;

  factory Muc.fromJson(Map<String, Object?> json) => Muc.fromJson(json);
}
