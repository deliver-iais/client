import 'package:hive/hive.dart';

part 'avatar.g.dart';

@HiveType(typeId: 1)
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
}
