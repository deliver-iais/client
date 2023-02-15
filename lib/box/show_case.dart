import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'show_case.g.dart';

@HiveType(typeId: SHOW_CASE_TRACK_ID)
class ShowCase {
  // DbId
  @HiveField(0)
  int index;

  @HiveField(1)
  String json;

  ShowCase({
    required this.index,
    required this.json,
  });
}
