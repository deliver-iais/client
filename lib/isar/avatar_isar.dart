import 'package:deliver/box/avatar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:isar/isar.dart';

part 'avatar_isar.g.dart';

@collection
class AvatarIsar {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  final String uid;

  final String fileName;

  final String fileUuid;

  final int createdOn;

  final bool avatarIsEmpty;

  final int lastUpdateTime;

  AvatarIsar({
    required this.uid,
    required this.fileName,
    required this.fileUuid,
    required this.createdOn,
    required this.avatarIsEmpty,
    required this.lastUpdateTime,
  });

  Avatar fromIsar() => Avatar(
        uid: uid.asUid(),
        fileName: fileName,
        createdOn: createdOn,
        fileUuid: fileUuid,
        avatarIsEmpty: avatarIsEmpty,
        lastUpdateTime: lastUpdateTime,
      );
}

extension AvatarIsarMapper on Avatar {
  AvatarIsar toIsar() => AvatarIsar(
        uid: uid.asString(),
        fileName: fileName,
        fileUuid: fileUuid,
        avatarIsEmpty: avatarIsEmpty,
        createdOn: createdOn,
        lastUpdateTime: lastUpdateTime,
      );
}
