import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

class MessageSimpleRepresentative {
  final Uid roomUid;
  final Uid from;
  final String sender;
  final String roomName;
  final MessageType type;
  final String typeDetails;
  final String text;
  final String packetId;
  final bool senderIsAUserOrBot;
  final int? id;
  final bool shouldBeQuiet;

  // Should not notify user
  final bool ignoreNotification;

  MessageSimpleRepresentative({
    required this.sender,
    required this.from,
    required this.roomName,
    required this.type,
    required this.typeDetails,
    required this.roomUid,
    required this.senderIsAUserOrBot,
    required this.text,
    required this.ignoreNotification,
    required this.packetId,
    required this.shouldBeQuiet,
    this.id,
  });

  MessageSimpleRepresentative copyWith({
    Uid? roomUid,
    Uid? from,
    String? sender,
    String? roomName,
    bool? senderIsAUserOrBot,
    MessageType? type,
    String? typeDetails,
    String? text,
    bool? ignoreNotification,
    String? packetId,
    int? id,
    bool? shouldBeQuiet,
  }) =>
      MessageSimpleRepresentative(
        roomUid: roomUid ?? this.roomUid,
        from: from ?? this.from,
        sender: sender ?? this.sender,
        roomName: roomName ?? this.roomName,
        senderIsAUserOrBot: senderIsAUserOrBot ?? this.senderIsAUserOrBot,
        type: type ?? this.type,
        typeDetails: typeDetails ?? this.typeDetails,
        text: text ?? this.text,
        id: id ?? this.id,
        ignoreNotification: ignoreNotification ?? this.ignoreNotification,
        packetId: packetId ?? this.packetId,
        shouldBeQuiet: shouldBeQuiet ?? this.shouldBeQuiet,
      );
}

bool isHiddenPbMessage(message_pb.Message message) {
  final type = getMessageType(message.whichType());
  switch (type) {
    case MessageType.TEXT:
    case MessageType.FILE:
    case MessageType.STICKER:
    case MessageType.LOCATION:
    case MessageType.LIVE_LOCATION:
    case MessageType.POLL:
    case MessageType.BUTTONS:
    case MessageType.SHARE_UID:
    case MessageType.FORM_RESULT:
    case MessageType.SHARE_PRIVATE_DATA_REQUEST:
    case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
    case MessageType.TABLE:
    case MessageType.FORM:
    case MessageType.PAYMENT_INFORMATION:
    case MessageType.CALL_LOG:
      return false;

    case MessageType.PERSISTENT_EVENT:
      switch (message.persistEvent.whichType()) {
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.mucSpecificPersistentEvent:
        case PersistentEvent_Type.botSpecificPersistentEvent:
          return false;

        case PersistentEvent_Type.messageManipulationPersistentEvent:
        case PersistentEvent_Type.notSet:
          return true;
      }

    case MessageType.CALL:
      switch (message.callEvent.callStatus) {
        case CallEvent_CallStatus.BUSY:
        case CallEvent_CallStatus.DECLINED:
        case CallEvent_CallStatus.ENDED:
          return false;

        case CallEvent_CallStatus.CREATED:
        case CallEvent_CallStatus.IS_RINGING:
          return true;
      }
      return true;

    case MessageType.TRANSACTION:
    case MessageType.NOT_SET:
      return true;
  }
}

bool isHiddenMessage(Message message) {
  final type = message.type;
  switch (type) {
    case MessageType.TEXT:
    case MessageType.FILE:
    case MessageType.STICKER:
    case MessageType.LOCATION:
    case MessageType.LIVE_LOCATION:
    case MessageType.POLL:
    case MessageType.BUTTONS:
    case MessageType.SHARE_UID:
    case MessageType.FORM_RESULT:
    case MessageType.SHARE_PRIVATE_DATA_REQUEST:
    case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
    case MessageType.TABLE:
    case MessageType.FORM:
    case MessageType.PAYMENT_INFORMATION:
    case MessageType.CALL_LOG:
      return false;

    case MessageType.PERSISTENT_EVENT:
      switch (message.json.toPersistentEvent().whichType()) {
        case PersistentEvent_Type.adminSpecificPersistentEvent:
        case PersistentEvent_Type.mucSpecificPersistentEvent:
        case PersistentEvent_Type.botSpecificPersistentEvent:
          return false;

        case PersistentEvent_Type.messageManipulationPersistentEvent:
        case PersistentEvent_Type.notSet:
          return true;
      }

    case MessageType.CALL:
      switch (message.json.toCallEvent().callStatus) {
        case CallEvent_CallStatus.BUSY:
        case CallEvent_CallStatus.DECLINED:
        case CallEvent_CallStatus.ENDED:
          return false;

        case CallEvent_CallStatus.CREATED:
        case CallEvent_CallStatus.IS_RINGING:
          return true;
      }
      return true;

    case MessageType.TRANSACTION:
    case MessageType.NOT_SET:
      return true;
  }
}

String messageBodyToJson(message_pb.Message message) {
  final type = getMessageType(message.whichType());
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
      return message.persistEvent.writeToJson();

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

    case MessageType.TABLE:
      return message.table.writeToJson();

    case MessageType.TRANSACTION:
      return message.transaction.writeToJson();

    case MessageType.PAYMENT_INFORMATION:
      return message.paymentInformation.writeToJson();

    case MessageType.CALL_LOG:
      return message.callLog.writeToJson();
    case MessageType.NOT_SET:
      return EMPTY_MESSAGE;
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
    case message_pb.Message_Type.table:
      return MessageType.TABLE;
    case message_pb.Message_Type.transaction:
      return MessageType.TRANSACTION;
    case message_pb.Message_Type.notSet:
      return MessageType.NOT_SET;
    case message_pb.Message_Type.paymentInformation:
      return MessageType.PAYMENT_INFORMATION;
    case message_pb.Message_Type.callLog:
      return MessageType.CALL_LOG;
  }
}

Uid getRoomUid(AuthRepo authRepo, message_pb.Message message) =>
    getRoomUidOf(authRepo, message.from, message.to);

Uid getRoomUidOf(AuthRepo authRepo, Uid from, Uid to) =>
    authRepo.isCurrentUser(from.asString()) ? to : (to.isUser() ? from : to);
