import 'package:hive/hive.dart';

part 'last_avatar.g.dart';

@HiveType(typeId: 2)
class LastAvatar {
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

  LastAvatar(
      {this.uid, this.createdOn, this.fileId, this.fileName, this.lastUpdate});
}
