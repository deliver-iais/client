import 'package:deliver/shared/constants.dart';
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
  String? fileId;

  @HiveField(3)
  String? fileName;

  @HiveField(4)
  int lastUpdate;

  Avatar({
    required this.uid,
    required this.createdOn,
    this.fileId,
    this.fileName,
    required this.lastUpdate,
  });

  Avatar copyWith({
    String? uid,
    int? createdOn,
    String? fileId,
    String? fileName,
    int? lastUpdate,
  }) =>
      Avatar(
        uid: uid ?? this.uid,
        createdOn: createdOn ?? this.createdOn,
        fileId: fileId ?? this.fileId,
        fileName: fileName ?? this.fileName,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}
