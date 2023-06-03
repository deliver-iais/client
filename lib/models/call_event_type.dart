import 'package:collection/collection.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;

class CallEvents {
  final call_pb.CallEventV2? callEvent;

  static const CallEvents none = CallEvents._none();

  const CallEvents._none() : callEvent = null;

  const CallEvents.callEvent(
    this.callEvent,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is CallEvents &&
          const DeepCollectionEquality().equals(other.callEvent, callEvent));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(callEvent),
      );
}
