import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'message_type.g.dart';

@HiveType(typeId: MESSAGE_TYPE_TRACK_ID)
enum MessageType {
  @HiveField(0)
  TEXT,

  @HiveField(1)
  FILE,

  @HiveField(2)
  STICKER,

  @HiveField(3)
  LOCATION,

  @HiveField(4)
  LIVE_LOCATION,

  @HiveField(5)
  POLL,

  @HiveField(6)
  FORM,

  @HiveField(7)
  PERSISTENT_EVENT,

  @HiveField(8)
  NOT_SET,

  @HiveField(9)
  BUTTONS,

  @HiveField(10)
  SHARE_UID,

  @HiveField(11)
  FORM_RESULT,

  @HiveField(12)
  SHARE_PRIVATE_DATA_REQUEST,

  @HiveField(13)
  SHARE_PRIVATE_DATA_ACCEPTANCE,

  @HiveField(14)
  CALL,

  @HiveField(15)
  TABLE,

  @HiveField(16)
  TRANSACTION,

  @HiveField(17)
  PAYMENT_INFORMATION,

  @HiveField(18)
  CALL_LOG,
}
