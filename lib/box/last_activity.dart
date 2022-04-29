import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
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

  LastActivity(
      {required this.uid, required this.time, required this.lastUpdate});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is LastActivity &&
          const DeepCollectionEquality().equals(other.uid, uid) &&
          const DeepCollectionEquality().equals(other.time, time) &&
          const DeepCollectionEquality().equals(other.lastUpdate, lastUpdate));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(uid),
        const DeepCollectionEquality().hash(time),
        const DeepCollectionEquality().hash(lastUpdate),
      );
}
