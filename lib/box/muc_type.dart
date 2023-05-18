import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'muc_type.g.dart';

@HiveType(typeId: MUC_Type_TRACK_ID)
enum MucType {
  @HiveField(0)
  Private,

  @HiveField(1)
  Public,

}
