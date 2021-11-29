import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:fixnum/fixnum.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class MessageBrief {
  final Uid? roomUid;
  final String? sender;
  final String? roomName;
  final MessageType? type;
  final String? typeDetails;
  final String? text;
  final bool? senderIsAUserOrBot;

  // Should not notify user
  final bool? ignoreNotification;

  MessageBrief(
      {this.roomUid,
      this.sender,
      this.roomName,
      this.senderIsAUserOrBot,
      this.type,
      this.typeDetails,
      this.text,
      this.ignoreNotification});

  MessageBrief copyWith(
      {Uid? roomUid,
      String? sender,
      String? roomName,
      bool? senderIsAUserOrBot,
      MessageType? type,
      String? typeDetails,
      String? text,
      bool? ignoreNotification}) {
    return MessageBrief(
        roomUid: roomUid ?? this.roomUid,
        sender: sender ?? this.sender,
        roomName: roomName ?? this.roomName,
        senderIsAUserOrBot: senderIsAUserOrBot ?? this.senderIsAUserOrBot,
        type: type ?? this.type,
        typeDetails: typeDetails ?? this.typeDetails,
        text: text ?? this.text,
        ignoreNotification: ignoreNotification ?? this.ignoreNotification);
  }
}

Future<MessageBrief> extractMessageBrief(I18N i18n, RoomRepo roomRepo,
    AuthRepo authRepo, message_pb.Message msg) async {
  Uid roomUid = getRoomUid(authRepo, msg);
  String? roomName = await roomRepo.getSlangName(roomUid);
  String? sender = await roomRepo.getSlangName(msg.from);
  MessageType type = getMessageType(msg.whichType());
  String? typeDetails = "";
  String text = "";
  bool ignoreNotification = authRepo.isCurrentUser(msg.from.asString());

  switch (msg.whichType()) {
    case message_pb.Message_Type.text:
      text = msg.text.text;
      break;
    case message_pb.Message_Type.file:
      var type = msg.file.type.split("/").first;
      if (type == "application") {
        typeDetails = msg.file.name;
      } else {
        typeDetails = i18n.get(type);
      }
      text = msg.file.caption;
      break;
    case message_pb.Message_Type.sticker:
      typeDetails = i18n.get("sticker");
      text = msg.file.caption;
      break;
    case message_pb.Message_Type.liveLocation:
      typeDetails = i18n.get("live_location");
      break;
    case message_pb.Message_Type.location:
      typeDetails = i18n.get("location");
      break;
    case message_pb.Message_Type.poll:
      typeDetails = i18n.get("poll");
      break;
    case message_pb.Message_Type.buttons:
      typeDetails = i18n.get("actions");
      break;
    case message_pb.Message_Type.form:
      typeDetails = i18n.get("form");
      text = msg.form.title;
      break;
    case message_pb.Message_Type.shareUid:
      if (msg.shareUid.uid.isUser()) {
        typeDetails = i18n.get("contact_information");
      } else {
        typeDetails = i18n.get("join_link");
      }
      text = msg.shareUid.name;
      break;
    case message_pb.Message_Type.formResult:
      typeDetails = i18n.get("form_result");
      break;
    case message_pb.Message_Type.sharePrivateDataRequest:
      typeDetails =
          "${i18n.get("spdr")} ${i18n.get(msg.sharePrivateDataRequest.data.name).toLowerCase()}";
      break;
    case message_pb.Message_Type.sharePrivateDataAcceptance:
      typeDetails =
          "${i18n.get("spda")} ${i18n.get(msg.sharePrivateDataRequest.data.name).toLowerCase()}";
      break;
    case message_pb.Message_Type.paymentTransaction:
      typeDetails = i18n.get("payment_transaction");
      text =
          msg.paymentTransaction.description; // TODO needs more details maybe
      break;
    case message_pb.Message_Type.persistEvent:
      typeDetails = await getPersistentEventText(
          i18n, roomRepo, authRepo, msg.persistEvent, msg.to.isChannel());
      if (typeDetails == null) {
        ignoreNotification = true;
      }
      break;
    case message_pb.Message_Type.callEvent:
      typeDetails = i18n.get("call");
      break;
    default:
      ignoreNotification = true;
      if (kDebugMode) {
        text = "____NO_TYPE_OF_MESSAGE_PROVIDED____";
      }
      break;
  }

  return MessageBrief(
    roomUid: roomUid,
    roomName: roomName,
    sender: sender,
    senderIsAUserOrBot: msg.from.isUser() || msg.from.isBot(),
    type: type,
    typeDetails: typeDetails,
    text: text,
    ignoreNotification: ignoreNotification,
  );
}

Future<String?> getPersistentEventText(I18N i18n, RoomRepo roomRepo,
    AuthRepo authRepo, PersistentEvent pe, bool isChannel) async {
  switch (pe.whichType()) {
    case PersistentEvent_Type.mucSpecificPersistentEvent:
      String? issuer =
          await roomRepo.getSlangName(pe.mucSpecificPersistentEvent.issuer);
      String? assignee =
          await roomRepo.getSlangName(pe.mucSpecificPersistentEvent.assignee);
      switch (pe.mucSpecificPersistentEvent.issue) {
        case MucSpecificPersistentEvent_Issue.ADD_USER:
          return [
            issuer,
            i18n.verb("added",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
          return [
            issuer,
            i18n.verb(
                isChannel
                    ? i18n.verb("change_channel_avatar")
                    : "change_group_avatar",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            // assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.JOINED_USER:
          return [
            issuer,
            i18n.verb("joined",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            // assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.KICK_USER:
          return [
            issuer,
            i18n.verb("kicked",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.LEAVE_USER:
          return [
            issuer,
            i18n.verb("left",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            // assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.MUC_CREATED:
          return [
            issuer,
            i18n.verb("created",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
          return [
            issuer,
            i18n.verb("changed_name",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            assignee
          ].join(" ").trim();

        case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
          return [
            issuer,
            i18n.verb("pinned",
                isFirstPerson: authRepo.isCurrentUser(
                    pe.mucSpecificPersistentEvent.issuer.asString())),
            assignee
          ].join(" ").trim();
        case MucSpecificPersistentEvent_Issue.DELETED:
          // TODO: Handle this case.
          break;
      }
      break;
    case PersistentEvent_Type.messageManipulationPersistentEvent:
      return null;

    case PersistentEvent_Type.adminSpecificPersistentEvent:
      switch (pe.adminSpecificPersistentEvent.event) {
        case AdminSpecificPersistentEvent_Event.NEW_CONTACT_ADDED:
          return [i18n.get("joined_to_app"), APPLICATION_NAME].join(" ").trim();

        default:
          return null;
      }

    default:
      return null;
  }
  return null;
}

message_pb.Message extractProtocolBufferMessage(Message message) {
  final msg = message_pb.Message()
    ..id = Int64(message.id ?? 0)
    ..packetId = message.packetId
    ..from = message.from.asUid()
    ..to = message.to.asUid()
    ..time = Int64(message.time)
    ..replyToId = Int64(message.replyToId ?? 0)
    ..edited = message.edited ?? false
    ..encrypted = message.encrypted ?? false;

  if (message.forwardedFrom != null) {
    msg.forwardFrom = message.forwardedFrom!.asUid();
  }

  switch (message.type) {
    case MessageType.TEXT:
      msg.text = message.json!.toText();
      break;
    case MessageType.FILE:
      msg.file = message.json!.toFile();
      break;
    case MessageType.STICKER:
      msg.sticker = message.json!.toSticker();
      break;
    case MessageType.LOCATION:
      msg.location = message.json!.toLocation();
      break;
    case MessageType.LIVE_LOCATION:
      msg.liveLocation = message.json!.toLiveLocation();
      break;
    case MessageType.POLL:
      msg.poll = message.json!.toPoll();
      break;
    case MessageType.FORM:
      msg.form = message.json!.toForm();
      break;
    case MessageType.PERSISTENT_EVENT:
      msg.persistEvent = message.json!.toPersistentEvent();
      break;
    case MessageType.BUTTONS:
      msg.buttons = message.json!.toButtons();
      break;
    case MessageType.SHARE_UID:
      msg.shareUid = message.json!.toShareUid();
      break;
    case MessageType.FORM_RESULT:
      msg.formResult = message.json!.toFormResult();
      break;
    case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      msg.sharePrivateDataRequest = message.json!.toSharePrivateDataRequest();
      break;
    case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      msg.sharePrivateDataAcceptance =
          message.json!.toSharePrivateDataAcceptance();
      break;
    case MessageType.CALL:
      msg.callEvent = message.json!.toCallEvent();
      break;
    case MessageType.NOT_SET:
      break;
    default:
      break;
  }

  return msg;
}

Message extractMessage(AuthRepo authRepo, message_pb.Message message) {
  var body = "{}";

  try {
    body = messageBodyToJson(message);
  } catch (_) {}

  return Message(
      id: message.id.toInt(),
      roomUid: getRoomUid(authRepo, message).asString(),
      packetId: message.packetId,
      time: message.time.toInt(),
      to: message.to.asString(),
      from: message.from.asString(),
      replyToId: message.replyToId.toInt(),
      forwardedFrom: message.forwardFrom.asString(),
      json: body,
      edited: message.edited,
      encrypted: message.encrypted,
      type: getMessageType(message.whichType()));
}

String messageBodyToJson(message_pb.Message message) {
  var type = getMessageType(message.whichType());
  switch (type) {
    case MessageType.TEXT:
      return message.text.writeToJson();

    case MessageType.FILE:
      return message.file.writeToJson();

    case MessageType.STICKER:
      return message.sticker.writeToJson();

    case MessageType.LOCATION:
      return message.location.writeToJson();

    case MessageType.LIVE_LOCATION:
      return message.liveLocation.writeToJson();

    case MessageType.POLL:
      return message.poll.writeToJson();

    case MessageType.FORM:
      return message.form.writeToJson();

    case MessageType.PERSISTENT_EVENT:
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.mucSpecificPersistentEvent:
          return message.persistEvent.writeToJson();

        case PersistentEvent_Type.messageManipulationPersistentEvent:
          return "{}";

        case PersistentEvent_Type.notSet:
          return "{}";
        default:
          return "{}";
      }

    case MessageType.BUTTONS:
      return message.buttons.writeToJson();

    case MessageType.SHARE_UID:
      return message.shareUid.writeToJson();

    case MessageType.FORM_RESULT:
      return message.formResult.writeToJson();

    case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      return message.sharePrivateDataRequest.writeToJson();

    case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      return message.sharePrivateDataAcceptance.writeToJson();
    case MessageType.CALL:
      return message.callEvent.writeToJson();
    case MessageType.NOT_SET:
      return "{}";
  }
}

MessageType getMessageType(message_pb.Message_Type messageType) {
  switch (messageType) {
    case message_pb.Message_Type.text:
      return MessageType.TEXT;
    case message_pb.Message_Type.file:
      return MessageType.FILE;
    case message_pb.Message_Type.sticker:
      return MessageType.STICKER;
    case message_pb.Message_Type.location:
      return MessageType.LOCATION;
    case message_pb.Message_Type.liveLocation:
      return MessageType.LIVE_LOCATION;
    case message_pb.Message_Type.poll:
      return MessageType.POLL;
    case message_pb.Message_Type.form:
      return MessageType.FORM;
    case message_pb.Message_Type.persistEvent:
      return MessageType.PERSISTENT_EVENT;
    case message_pb.Message_Type.formResult:
      return MessageType.FORM_RESULT;
    case message_pb.Message_Type.buttons:
      return MessageType.BUTTONS;
    case message_pb.Message_Type.shareUid:
      return MessageType.SHARE_UID;
    case message_pb.Message_Type.sharePrivateDataRequest:
      return MessageType.SHARE_PRIVATE_DATA_REQUEST;
    case message_pb.Message_Type.sharePrivateDataAcceptance:
      return MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE;
    case message_pb.Message_Type.callEvent:
      return MessageType.CALL;
    default:
      return MessageType.NOT_SET;
  }
}

Uid getRoomUid(AuthRepo authRepo, message_pb.Message message) {
  return getRoomUidOf(authRepo, message.from, message.to);
}

Uid getRoomUidOf(AuthRepo authRepo, Uid from, Uid to) {
  return authRepo.isCurrentUser(from.asString())
      ? to
      : (to.isUser() ? from : to);
}
