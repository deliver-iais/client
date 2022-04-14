import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';

class MessageEvent {
  String roomUid;
  int time;
  int id;
  MessageManipulationPersistentEvent_Action action;

  MessageEvent(this.roomUid, this.time, this.id, this.action);
}
