import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/poll.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/payment.pb.dart';

extension JsonMapper on String {
  File toFile() => File.fromJson(this);

  File toSticker() => File.fromJson(this);

  Text toText() => Text.fromJson(this);

  Location toLocation() => Location.fromJson(this);

  Transaction toPaymentTransaction() => Transaction.fromJson(this);

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

  bool isEmptyMessage() => this == EMPTY_MESSAGE;

  bool chatIsDeleted() => this == DELETED_ROOM_MESSAGE;

  int toCallDuration() => CallEvent.fromJson(this).callDuration.toInt();
}
