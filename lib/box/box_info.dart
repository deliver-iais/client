import 'package:deliver/shared/constants.dart';
import 'package:hive_flutter/adapters.dart';

part 'box_info.g.dart';

@HiveType(typeId: BOX_INFO_TRACK_ID)
class BoxInfo {
  @HiveField(0)
  String name;

  @HiveField(1)
  int version;

  @HiveField(2)
  String dbKey;

  BoxInfo({required this.name, required this.version, required this.dbKey});
}
