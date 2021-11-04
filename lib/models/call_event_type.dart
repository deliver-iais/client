import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart'
    as CallProto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

enum CallTypes {Answer , Event, Offer}

class CallEvents{

  CallEvents(this._callAnswer, this._callEvent, this._callOffer, this._callTypes, {this.roomUid});

  CallProto.CallAnswer _callAnswer;
  CallProto.CallEvent _callEvent;
  CallProto.CallOffer _callOffer;

  Uid roomUid;

  CallTypes _callTypes;

  get callTypes{
    return _callTypes;
  }

  get callAnswer{
    return _callAnswer;
  }

  get callEvent{
    return _callEvent;
  }

  get callOffer{
    return _callOffer;
  }

}