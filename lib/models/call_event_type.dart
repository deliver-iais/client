// ignore_for_file: constant_identifier_names

import 'package:collection/collection.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

enum CallTypes { None, Answer, Event, Offer }

class CallEvents {
  final call_pb.CallEvent? callEvent;
  final call_pb.CallAnswer? callAnswer;
  final call_pb.CallOffer? callOffer;
  final CallTypes callType;
  final Uid? roomUid;
  final String callId;
  final int time;

  static CallEvents none = const CallEvents._none();

  const CallEvents._none()
      : callEvent = null,
        callOffer = null,
        callAnswer = null,
        roomUid = null,
        callId = "-1",
        time = 0,
        callType = CallTypes.None;

  const CallEvents.callAnswer(
    this.callAnswer, {
    required this.roomUid,
    required this.callId,
  })  : callEvent = null,
        callOffer = null,
        time = 0,
        callType = CallTypes.Answer;

  const CallEvents.callEvent(
    this.callEvent, {
    required this.roomUid,
    required this.callId,
    required this.time,
  })  : callAnswer = null,
        callOffer = null,
        callType = CallTypes.Event;

  const CallEvents.callOffer(
    this.callOffer, {
    required this.roomUid,
    required this.callId,
  })  : callEvent = null,
        callAnswer = null,
        time = 0,
        callType = CallTypes.Offer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is CallEvents &&
          const DeepCollectionEquality().equals(other.callEvent, callEvent) &&
          const DeepCollectionEquality().equals(other.callAnswer, callAnswer) &&
          const DeepCollectionEquality().equals(other.callType, callType) &&
          const DeepCollectionEquality().equals(other.roomUid, roomUid) &&
          const DeepCollectionEquality().equals(other.callId, callId) &&
          const DeepCollectionEquality().equals(other.callOffer, callOffer));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(callEvent),
        const DeepCollectionEquality().hash(callAnswer),
        const DeepCollectionEquality().hash(callType),
        const DeepCollectionEquality().hash(roomUid),
        const DeepCollectionEquality().hash(callId),
        const DeepCollectionEquality().hash(callOffer),
      );
}
