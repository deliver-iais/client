
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'is_verified.g.dart';
part 'is_verified.freezed.dart';


@freezed
class IsVerified with _$IsVerified {
  const factory IsVerified({
    @UidJsonKey required Uid uid,
    required int lastUpdate,
    required int expireTime,
  }) = _IsVerified;

  factory IsVerified.fromJson(Map<String, Object?> json) => _$IsVerifiedFromJson(json);
}


