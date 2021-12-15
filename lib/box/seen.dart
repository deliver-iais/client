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
  int? messageId;

  @HiveField(2)
  int? hiddenMessageCount;

  Seen({required this.uid, this.messageId, this.hiddenMessageCount});

  Seen copy(Seen seen) => Seen(
      uid: seen.uid,
      messageId: seen.messageId ?? messageId,
      hiddenMessageCount: seen.hiddenMessageCount ?? hiddenMessageCount);
}
