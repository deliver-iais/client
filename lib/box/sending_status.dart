import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'sending_status.g.dart';

@HiveType(typeId: SENDING_STATUS_TRACK_ID)
enum SendingStatus {

  @HiveField(2)
  UPLOAD_FILE_COMPLETED,

  @HiveField(3)
  UPLOAD_FILE_FAIL,

  @HiveField(4)
  UPLOAD_FILE_IN_PROGRESS,

  @HiveField(1)
  PENDING
}
