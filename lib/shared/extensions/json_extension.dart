import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/poll.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/transaction.pb.dart';

extension JsonMapper on String {
  File toFile() {
    return File.fromJson(this);
  }

  File toSticker() {
    return File.fromJson(this);
  }

  Text toText() {
    return Text.fromJson(this);
  }

  Location toLocation() {
    return Location.fromJson(this);
  }

  PaymentTransaction toPaymentTransaction() {
    return PaymentTransaction.fromJson(this);
  }

  Poll toPoll() {
    return Poll.fromJson(this);
  }

  Form toForm() {
    return Form.fromJson(this);
  }

  LiveLocation toLiveLocation() {
    return LiveLocation.fromJson(this);
  }

  PersistentEvent toPersistentEvent() {
    return PersistentEvent.fromJson(this);
  }

  FormResult toFormResult() {
    return FormResult.fromJson(this);
  }

  Buttons toButtons() {
    return Buttons.fromJson(this);
  }

  ShareUid toShareUid() {
    return ShareUid.fromJson(this);
  }

  SharePrivateDataAcceptance toSharePrivateDataAcceptance() {
    return SharePrivateDataAcceptance.fromJson(this);
  }

  SharePrivateDataRequest toSharePrivateDataRequest() {
    return SharePrivateDataRequest.fromJson(this);
  }
  CallEvent toCallEvent(){
    return CallEvent.fromJson(this);
  }

  bool isDeletedMessage() {
    return this == "{}";
  }

  bool chatIsDeleted() {
    return this == "{DELETED}";
  }
  int toCallDuration(){
    return CallEvent.fromJson(this).callDuration.toInt();
  }

}