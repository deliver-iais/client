import 'package:deliver/box/avatar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:hive/hive.dart';

part 'avatar_hive.g.dart';

@HiveType(typeId: AVATAR_TRACK_ID)
class AvatarHive {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  int createdOn;

  @HiveField(2)
  String fileId;

  @HiveField(3)
  String fileName;

  @HiveField(4)
  int lastUpdate;

  @HiveField(5)
  bool avatarIsEmpty;

  AvatarHive({
    required this.uid,
    required this.createdOn,
    this.fileId = "",
    this.fileName = "",
    this.lastUpdate = 0,
    this.avatarIsEmpty = false,
  });

  AvatarHive copyWith({
    String? uid,
    int? createdOn,
    String? fileId,
    String? fileName,
    int? lastUpdate,
    bool? avatarIsEmpty,
  }) =>
      AvatarHive(
        uid: uid ?? this.uid,
        createdOn: createdOn ?? this.createdOn,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
        lastUpdate: lastUpdate ?? this.lastUpdate,
        avatarIsEmpty: avatarIsEmpty ?? this.avatarIsEmpty,
      );

  Avatar fromHive() => Avatar(
        uid: uid.asUid(),
        fileName: fileName,
        createdOn: createdOn,
        fileUuid: fileId,
        avatarIsEmpty: avatarIsEmpty,
        lastUpdateTime: lastUpdate,
      );
}

extension AvatarHiveMapper on Avatar {
  AvatarHive toHive() => AvatarHive(
        uid: uid.asString(),
        fileName: fileName,
        fileId: fileUuid,
        createdOn: createdOn,
        lastUpdate: lastUpdateTime,
        avatarIsEmpty: avatarIsEmpty,
      );
}
