import 'package:collection/collection.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';

class MessageEvent {
  String roomUid;
  int time;
  int id;
  MessageManipulationPersistentEvent_Action action;

  MessageEvent(this.roomUid, this.time, this.id, this.action);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is MessageEvent &&
          const DeepCollectionEquality().equals(other.roomUid, roomUid) &&
          const DeepCollectionEquality().equals(other.time, time) &&
          const DeepCollectionEquality().equals(other.id, id));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(roomUid),
        const DeepCollectionEquality().hash(time),
        const DeepCollectionEquality().hash(id),
      );
}
