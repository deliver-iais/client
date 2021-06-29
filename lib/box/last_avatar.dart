import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'last_avatar.g.dart';

@HiveType(typeId: LAST_AVATAR_TRACK_ID)
class LastAvatar {
  // DbId
  @HiveField(0)
  String uid;

  @HiveField(1)
  int createdOn;

  @HiveField(2)
  String fileId;

  @HiveField(3)
  String fileName;

  @HiveField(4)
  int lastUpdate;

  LastAvatar(
      {this.uid, this.createdOn, this.fileId, this.fileName, this.lastUpdate});
}
