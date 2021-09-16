import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'seen.g.dart';

@HiveType(typeId: SEEN_TRACK_ID)
class Seen {
  // Table ID
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  int messageId;

  Seen({this.uid, this.messageId});
}
