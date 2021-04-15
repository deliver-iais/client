import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/payment_transaction.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/poll.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';

extension JsonMapper on String {
  File toFile() {
    return File.fromJson(this);
  }

  // Sticker toSticker() {
  //   return Sticker.fromJson(this);
  // }

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

  FormResult toFormResult(){
    return FormResult.fromJson(this);
  }

  Buttons toButtons (){
    return Buttons.fromJson(this);
  }
  ShareUid toShareUid(){
    return ShareUid.fromJson(this);
  }
  SharePrivateDataAcceptance toSharePrivateDataAcceptance(){
    return SharePrivateDataAcceptance.fromJson(this);
  }
  SharePrivateDataRequest toSharePrivateDataReauest(){
    return SharePrivateDataRequest.fromJson(this);
  }
}
