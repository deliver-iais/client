import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'avatar.g.dart';

@HiveType(typeId: AVATAR_TRACK_ID)
class Avatar {
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

  Avatar({this.uid, this.createdOn, this.fileId, this.fileName});
}
