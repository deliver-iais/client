import 'package:collection/collection.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

enum MessageEventAction { EDIT, DELETE, PENDING_EDIT, PENDING_DELETE }

class MessageEvent {
  Uid roomUid;
  int time;
  int id;
  int lnmId;
  MessageEventAction action;

  MessageEvent(this.roomUid, this.time, this.id, this.lnmId, this.action);

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
