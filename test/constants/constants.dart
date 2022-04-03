import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:geolocator/geolocator.dart';

Position testPosition = Position(
  altitude: 0,
  accuracy: 0,
  heading: 0,
  latitude: 0,
  longitude: 0,
  speed: 0,
  speedAccuracy: 0,
  timestamp: DateTime(2000),
);
Uid testUid = "0:3049987b-e15d-4288-97cd-42dbc6d73abd".asUid();
Message testMessage = Message(
  to: testUid.asString(),
  from: testUid.asString(),
  packetId: testUid.asString(),
  roomUid: testUid.asString(),
  time: 0,
  json: '',
);
PendingMessage testPendingMessage = PendingMessage(
  roomUid: testUid.asString(),
  packetId: "946672200000000",
  msg: testMessage.copyWith(
    time: 946672200000,
    packetId: "946672200000000",
  ),
  status: SendingStatus.PENDING,
);
Activity testActivity = Activity(
  to: testUid,
  from: testUid,
  typeOfActivity: ActivityType.CHOOSING_STICKER,
);
Seen testSeen = Seen(uid: testUid.asString(), messageId: 0);

Room testRoom = Room(uid: testUid.asString());
Uid botUid = Uid(category: Categories.BOT, node: "father_bot", sessionId: "*");
Uid systemUid = Uid(
  category: Categories.SYSTEM,
  node: "Notification Service",
  sessionId: "*",
);
Uid emptyUid = Uid(category: Categories.USER, node: "", sessionId: "*");
Uid groupUid = Uid(category: Categories.GROUP, node: "", sessionId: "*");
