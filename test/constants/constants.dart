import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/room_metadata.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:geolocator/geolocator.dart' as location;

const int roomMetaDataLastUpdateTime = 1671431635717;

final testPosition = location.Position(
  altitude: 0,
  accuracy: 0,
  heading: 0,
  latitude: 0,
  longitude: 0,
  speed: 0,
  speedAccuracy: 0,
  timestamp: DateTime(2000),
);
final testUid = "0:3049987b-e15d-4288-97cd-42dbc6d73abd".asUid();

final testGroupUid = "2:3049987b-e45g-4288-97cd-42dbc6d73abd".asUid();
final testMessage = Message(
  to: testUid.asString(),
  from: testUid.asString(),
  packetId: testUid.asString(),
  roomUid: testUid.asString(),
  time: 0,
  json: '',
  isHidden: false,
);
final testCallInfo = CallInfo(
  from: testUid,
  time: Int64(),
  to: testUid,
  callEventOld: CallEvent(
    callDuration: Int64(),
    callId: "test",
    callStatus: CallEvent_CallStatus.CREATED,
    callType: CallEvent_CallType.AUDIO,
  ),
);
final testFile = File()
  ..uuid = "94667220000013418"
  ..caption = "test"
  ..width = 0
  ..height = 0
  ..type = "audio/mp4"
  ..size = Int64()
  ..name = "test"
  ..duration = 0;
final testMetaData = MetaCount(
  mediasCount: 1,
  callsCount: 0,
  filesCount: 0,
  lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
  linkCount: 0,
  musicsCount: 0,
  roomId: testUid.asString(),
  voicesCount: 0,
  allCallDeletedCount: 0,
  allFilesDeletedCount: 0,
  allLinksDeletedCount: 0,
  allMediaDeletedCount: 0,
  allMusicsDeletedCount: 0,
  allVoicesDeletedCount: 0,
);

final roomMetadata = RoomMetadata(
  roomUid: testUid,
  lastMessageId: Int64(10),
  lastSeenId: Int64(8),
  lastCurrentUserSentMessageId: Int64(9),
);

final testLastMessage = Message(
  to: testUid.asString(),
  from: testUid.asString(),
  packetId: "",
  roomUid: testUid.asString(),
  forwardedFrom: testUid.asString(),
  type: MessageType.TEXT,
  time: 0,
  id: 1,
  json: '{}',
  isHidden: false,
);

final testPendingMessage = PendingMessage(
  roomUid: testUid.asString(),
  packetId: "946672200000-0-13418",
  msg: testMessage.copyWith(
    time: 946672200000,
    packetId: "946672200000-0-13418",
  ),
  status: SendingStatus.PENDING,
);
final filePendingMessage = testPendingMessage.copyWith(
  msg: testPendingMessage.msg.copyWith(
    type: MessageType.FILE,
    json:
        "{\"1\":\"946672200000000\",\"2\":\"4096\",\"3\":\"application/octet-stream\",\"4\":\"test\",\"5\":\"test\",\"6\":0,\"7\":0,\"8\":0.0}",
  ),
  status: SendingStatus.UPLOAD_FILE_FAIL,
);
final testActivity = Activity(
  to: testUid,
  from: testUid,
  typeOfActivity: ActivityType.CHOOSING_STICKER,
);
final testSeen = Seen(
  uid: testUid.asString(),
  messageId: 0,
  hiddenMessageCount: 0,
);

final testRoom = Room(uid: testUid.asString());
final botUid =
    Uid(category: Categories.BOT, node: "father_bot", sessionId: "*");
final systemUid = Uid(
  category: Categories.SYSTEM,
  node: "Notification Service",
  sessionId: "*",
);
final emptyUid = Uid(category: Categories.USER, node: "", sessionId: "*");
final groupUid = Uid(category: Categories.GROUP, node: "", sessionId: "*");
