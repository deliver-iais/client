// ignore_for_file: constant_identifier_names

import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'sending_status.g.dart';

@HiveType(typeId: SENDING_STATUS_TRACK_ID)
enum SendingStatus {

  @HiveField(2)
  UPLOAD_FILE_COMPELED,

  @HiveField(3)
  UPLIOD_FILE_FAIL,

  @HiveField(4)
  UPLOAD_FILE_INPROGRSS,

  @HiveField(1)
  PENDING
}
