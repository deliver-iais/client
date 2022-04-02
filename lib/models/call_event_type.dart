// ignore_for_file: constant_identifier_names

import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart'
    as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

enum CallTypes { None, Answer, Event, Offer }

class CallEvents {
  final call_pb.CallEvent? callEvent;
  final call_pb.CallAnswer? callAnswer;
  final call_pb.CallOffer? callOffer;
  final CallTypes callType;
  final Uid? roomUid;
  final String callId;

  static CallEvents none = const CallEvents._none();

  const CallEvents._none()
      : callEvent = null,
        callOffer = null,
        callAnswer = null,
        roomUid = null,
        callId = "-1",
        callType = CallTypes.None;

  const CallEvents.callAnswer(this.callAnswer, {required this.roomUid, required this.callId})
      : callEvent = null,
        callOffer = null,
        callType = CallTypes.Answer;

  const CallEvents.callEvent(this.callEvent, {required this.roomUid, required this.callId})
      : callAnswer = null,
        callOffer = null,
        callType = CallTypes.Event;

  const CallEvents.callOffer(this.callOffer, {required this.roomUid, required this.callId})
      : callEvent = null,
        callAnswer = null,
        callType = CallTypes.Offer;
}
