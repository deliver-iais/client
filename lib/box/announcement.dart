import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'announcement.g.dart';

@HiveType(typeId: ANNOUNCMENT_TRACK_ID)
class Announcements {
  // DbId
  @HiveField(0)
   int index;

  @HiveField(1)
   String json;

  Announcements({
    required this.index,
    required this.json,
  });

  @override
  String toString() {
    return 'Announcements{index: $index, json: $json}';
  }
}