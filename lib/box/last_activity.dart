import 'package:we/shared/constants.dart';
import 'package:hive/hive.dart';

part 'last_activity.g.dart';

@HiveType(typeId: LAST_ACTIVITY_TRACK_ID)
class LastActivity {
  @HiveField(0)
  String uid;

  // DbId
  @HiveField(1)
  int time;

  @HiveField(2)
  int lastUpdate;

  LastActivity({this.uid, this.time, this.lastUpdate});
}
