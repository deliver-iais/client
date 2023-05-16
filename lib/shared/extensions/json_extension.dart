// import 'package:deliver/box/message_markup.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/markup.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/meta.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/payment.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/poll.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/sticker.pb.dart';

extension JsonMapper on String {
  File toFile() => File.fromJson(this);

  Sticker toSticker() => Sticker.fromJson(this);

  Text toText() => Text.fromJson(this);

  Location toLocation() => Location.fromJson(this);

  Transaction toTransaction() => Transaction.fromJson(this);

  PaymentInformation toPaymentInformation() =>
      PaymentInformation.fromJson(this);

  Poll toPoll() => Poll.fromJson(this);

  Form toForm() => Form.fromJson(this);

  LiveLocation toLiveLocation() => LiveLocation.fromJson(this);

  PersistentEvent toPersistentEvent() => PersistentEvent.fromJson(this);

  FormResult toFormResult() => FormResult.fromJson(this);

  Buttons toButtons() => Buttons.fromJson(this);

  Table toTable() => Table.fromJson(this);

  ShareUid toShareUid() => ShareUid.fromJson(this);

  SharePrivateDataAcceptance toSharePrivateDataAcceptance() =>
      SharePrivateDataAcceptance.fromJson(this);

  SharePrivateDataRequest toSharePrivateDataRequest() =>
      SharePrivateDataRequest.fromJson(this);

  CallEvent toCallEvent() => CallEvent.fromJson(this);

  CallInfo toCallInfo() => CallInfo.fromJson(this);

  MessageMarkup toMessageMarkup() => MessageMarkup.fromJson(this);

  ReplyKeyboardMarkup toReplyKeyboardMarkup() =>
      ReplyKeyboardMarkup.fromJson(this);

  Showcase toShowCase() {
    return Showcase.fromJson(this);
  }

  Link toLink() => Link.fromJson(this);

  CallLog toCallLog() => CallLog.fromJson(this);
}
