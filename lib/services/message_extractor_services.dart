import 'dart:convert';

import 'package:deliver/box/inline_keyboard_button.dart';
import 'package:deliver/box/inline_keyboard_markup.dart';
import 'package:deliver/box/inline_keyboard_row.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/box/message_markup.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/reply_keyboard_button.dart';
import 'package:deliver/box/reply_keyboard_markup.dart';
import 'package:deliver/box/reply_keyboard_row.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/markup.pb.dart'
    as markup_pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class MessageExtractorServices {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  MessageBrief extractMessageBrief(Message msg) {
    var text = "";

    switch (msg.type) {
      case MessageType.TEXT:
        text = msg.json.toText().text;
        break;
      case MessageType.FILE:
        text = msg.json.toFile().caption;
        break;
      case MessageType.STICKER:
        if (msg.json.toSticker().emojis.isNotEmpty) {
          text = msg.json.toSticker().emojis.first;
        }
        break;
      case MessageType.FORM:
        text = msg.json.toForm().title;
        break;
      case MessageType.TRANSACTION:
        text = msg.json.toTransaction().description;
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
      case MessageType.CALL:
      case MessageType.FORM_RESULT:
      case MessageType.TABLE:
      case MessageType.LOCATION:
      case MessageType.LIVE_LOCATION:
      case MessageType.POLL:
      case MessageType.PERSISTENT_EVENT:
      case MessageType.NOT_SET:
      case MessageType.BUTTONS:
      case MessageType.SHARE_UID:
        break;
    }

    return MessageBrief(
      roomUid: msg.roomUid,
      packetId: msg.packetId,
      id: msg.id ?? 0,
      time: msg.time,
      from: msg.from,
      to: msg.to,
      text: text,
      type: msg.type,
    );
  }

  Future<MessageSimpleRepresentative>
      extractMessageSimpleRepresentativeFromMessageBrief(
    MessageBrief mrb,
  ) async {
    final roomUid = getRoomUidOf(_authRepo, mrb.from.asUid(), mrb.to.asUid());
    final from = mrb.from.asUid();
    final roomName = await _roomRepo.getSlangName(roomUid);
    final sender = await _roomRepo.getSlangName(mrb.from.asUid());
    final type = mrb.type;
    const typeDetails = "";
    final text = mrb.text;
    const ignoreNotification = false;
    const shouldBeQuiet = false;

    return MessageSimpleRepresentative(
      roomUid: roomUid,
      from: from,
      roomName: roomName,
      sender: sender,
      senderIsAUserOrBot: mrb.from.asUid().isUser() || mrb.to.asUid().isBot(),
      type: type,
      id: mrb.id,
      packetId: mrb.packetId,
      typeDetails: typeDetails,
      text: text,
      ignoreNotification: ignoreNotification,
      shouldBeQuiet: shouldBeQuiet,
    );
  }

  Future<MessageSimpleRepresentative> extractMessageSimpleRepresentative(
    message_pb.Message msg,
  ) async {
    final roomUid = getRoomUid(_authRepo, msg);
    final from = msg.from;
    final roomName = await _roomRepo.getSlangName(roomUid);
    final sender = await _roomRepo.getSlangName(msg.from);
    final type = getMessageType(msg.whichType());

    var typeDetails = "";
    var text = "";
    var ignoreNotification = _authRepo.isCurrentUser(msg.from.asString());

    switch (msg.whichType()) {
      case message_pb.Message_Type.text:
        text = msg.text.text;
        break;
      case message_pb.Message_Type.file:
        final type = msg.file.type.split("/").first;
        if (type == "application") {
          typeDetails = msg.file.name;
        } else {
          typeDetails = _i18n.get(type);
        }
        text = msg.file.caption;
        break;
      case message_pb.Message_Type.sticker:
        typeDetails = _i18n.get("sticker");
        if (msg.sticker.emojis.isNotEmpty) {
          text = msg.sticker.emojis.first;
        }
        break;
      case message_pb.Message_Type.liveLocation:
        typeDetails = _i18n.get("live_location");
        break;
      case message_pb.Message_Type.location:
        typeDetails = _i18n.get("location");
        break;
      case message_pb.Message_Type.poll:
        typeDetails = _i18n.get("poll");
        break;
      case message_pb.Message_Type.buttons:
        typeDetails = _i18n.get("actions");
        break;
      case message_pb.Message_Type.form:
        typeDetails = _i18n.get("form");
        text = msg.form.title;
        break;
      case message_pb.Message_Type.shareUid:
        if (msg.shareUid.uid.isUser()) {
          typeDetails = _i18n.get("contact_information");
        } else {
          typeDetails = _i18n.get("join_link");
        }
        text = msg.shareUid.name;
        break;
      case message_pb.Message_Type.formResult:
        typeDetails = _i18n.get("form_result");
        break;
      case message_pb.Message_Type.sharePrivateDataRequest:
        typeDetails =
            "${_i18n.get("spdr")} ${_i18n.get(msg.sharePrivateDataRequest.data.name).toLowerCase()}";
        break;
      case message_pb.Message_Type.sharePrivateDataAcceptance:
        typeDetails =
            "${_i18n.get("spda")} ${_i18n.get(msg.sharePrivateDataRequest.data.name).toLowerCase()}";
        break;
      case message_pb.Message_Type.transaction:
        typeDetails = _i18n.get("payment_transaction");
        text = msg.transaction.description;
        break;
      case message_pb.Message_Type.persistEvent:
        typeDetails = await getPersistentEventText(
          msg.persistEvent,
          isChannel: msg.to.isChannel(),
        );
        if (typeDetails.trim().isEmpty) {
          ignoreNotification = true;
        }
        break;
      case message_pb.Message_Type.callEvent:
        ignoreNotification = true;
        final callStatus = msg.callEvent.newStatus;
        final time = msg.callEvent.callDuration.toInt();
        final fromCurrentUser = _authRepo.isCurrentUserUid(msg.from);
        typeDetails = getCallText(
              callStatus,
              time,
              fromCurrentUser: fromCurrentUser,
            ) ??
            "";
        break;

      case message_pb.Message_Type.table:
        typeDetails = _i18n.get("table");
        break;
      case message_pb.Message_Type.notSet:
        ignoreNotification = true;
        if (kDebugMode) {
          text = "____NO_TYPE_OF_MESSAGE_PROVIDED____";
        }
        break;
    }

    return MessageSimpleRepresentative(
      roomUid: roomUid,
      from: from,
      roomName: roomName,
      sender: sender,
      senderIsAUserOrBot: msg.from.isUser() || msg.from.isBot(),
      type: type,
      id: msg.id.toInt(),
      packetId: msg.packetId,
      typeDetails: typeDetails,
      text: text,
      ignoreNotification: ignoreNotification,
      shouldBeQuiet: msg.shouldBeQuiet,
    );
  }

  String? getCallText(
    CallEvent_CallStatus callStatus,
    int time, {
    bool fromCurrentUser = false,
  }) {
    if (callStatus == CallEvent_CallStatus.ENDED &&
        fromCurrentUser &&
        time == 0) {
      return _i18n.get("canceled_call");
    } else if (callStatus == CallEvent_CallStatus.DECLINED && time == 0) {
      return _i18n.get("declined_call");
    } else if (callStatus == CallEvent_CallStatus.BUSY && time == 0) {
      return _i18n.get("busy");
    } else if (callStatus == CallEvent_CallStatus.ENDED && time == 0) {
      return _i18n.get("missed_call");
    } else if (callStatus == CallEvent_CallStatus.ENDED &&
        fromCurrentUser &&
        time != 0) {
      return _i18n.get("outgoing_call");
    } else if (callStatus == CallEvent_CallStatus.ENDED && time != 0) {
      return _i18n.get("incoming_call");
    } else {
      return null;
    }
  }

  Future<String> getPersistentEventText(
    PersistentEvent pe, {
    bool isChannel = false,
  }) async {
    switch (pe.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        final issuer =
            await _roomRepo.getSlangName(pe.mucSpecificPersistentEvent.issuer);
        final assignee = await _roomRepo
            .getSlangName(pe.mucSpecificPersistentEvent.assignee);
        switch (pe.mucSpecificPersistentEvent.issue) {
          case MucSpecificPersistentEvent_Issue.ADD_USER:
            return [
              issuer,
              _i18n.verb(
                "added",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
            return [
              issuer,
              _i18n.verb(
                isChannel ? "change_channel_avatar" : "change_group_avatar",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              // assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.JOINED_USER:
            return [
              issuer,
              _i18n.verb(
                "joined",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              // assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.KICK_USER:
            return [
              issuer,
              _i18n.verb(
                "kicked",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.LEAVE_USER:
            return [
              issuer,
              _i18n.verb(
                "left",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              // assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.MUC_CREATED:
            return [
              issuer,
              _i18n.verb(
                "created",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
            return [
              issuer,
              _i18n.verb(
                "changed_name",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              assignee
            ].join(" ").trim();

          case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
            return [
              issuer,
              _i18n.verb(
                "pinned",
                isFirstPerson: _authRepo.isCurrentUser(
                  pe.mucSpecificPersistentEvent.issuer.asString(),
                ),
              ),
              assignee
            ].join(" ").trim();
          case MucSpecificPersistentEvent_Issue.DELETED:
            break;
        }
        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        return "";
      case PersistentEvent_Type.botSpecificPersistentEvent:
        return pe.botSpecificPersistentEvent.errorMessage.isNotEmpty
            ? pe.botSpecificPersistentEvent.errorMessage
            : _i18n.get("bot_not_responding");

      case PersistentEvent_Type.adminSpecificPersistentEvent:
        switch (pe.adminSpecificPersistentEvent.event) {
          case AdminSpecificPersistentEvent_Event.NEW_CONTACT_ADDED:
            return [_i18n.get("joined_to_app"), APPLICATION_NAME]
                .join(" ")
                .trim();

          default:
            return "";
        }
      case PersistentEvent_Type.notSet:
        return "";
    }
    return "";
  }

  message_pb.Message extractProtocolBufferMessage(Message message) {
    final msg = message_pb.Message()
      ..id = Int64(message.id ?? 0)
      ..packetId = message.packetId
      ..from = message.from.asUid()
      ..to = message.to.asUid()
      ..time = Int64(message.time)
      ..replyToId = Int64(message.replyToId)
      ..edited = message.edited
      ..encrypted = message.encrypted;

    if (message.forwardedFrom != null) {
      msg.forwardFrom = message.forwardedFrom!.asUid();
    }

    switch (message.type) {
      case MessageType.TEXT:
        msg.text = message.json.toText();
        break;
      case MessageType.FILE:
        msg.file = message.json.toFile();
        break;
      case MessageType.STICKER:
        msg.sticker = message.json.toSticker();
        break;
      case MessageType.LOCATION:
        msg.location = message.json.toLocation();
        break;
      case MessageType.LIVE_LOCATION:
        msg.liveLocation = message.json.toLiveLocation();
        break;
      case MessageType.POLL:
        msg.poll = message.json.toPoll();
        break;
      case MessageType.FORM:
        msg.form = message.json.toForm();
        break;
      case MessageType.PERSISTENT_EVENT:
        msg.persistEvent = message.json.toPersistentEvent();
        break;
      case MessageType.BUTTONS:
        msg.buttons = message.json.toButtons();
        break;
      case MessageType.SHARE_UID:
        msg.shareUid = message.json.toShareUid();
        break;
      case MessageType.FORM_RESULT:
        msg.formResult = message.json.toFormResult();
        break;
      case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        msg.sharePrivateDataRequest = message.json.toSharePrivateDataRequest();
        break;
      case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        msg.sharePrivateDataAcceptance =
            message.json.toSharePrivateDataAcceptance();
        break;
      case MessageType.CALL:
        msg.callEvent = message.json.toCallEvent();
        break;
      case MessageType.TABLE:
        msg.table = message.json.toTable();
        break;
      case MessageType.TRANSACTION:
        msg.transaction = message.json.toTransaction();
        break;
      case MessageType.NOT_SET:
        break;
    }

    return msg;
  }

  Message extractMessage(message_pb.Message message) {
    var body = EMPTY_MESSAGE;
    var isHidden = false;

    try {
      body = messageBodyToJson(message);
      isHidden = isHiddenPbMessage(message);
    } catch (_) {}
    //for testing remove later
    message.messageMarkup = markup_pb.MessageMarkup(
      //removeReplyKeyboardMarkup: true,
      replyKeyboardMarkup: markup_pb.ReplyKeyboardMarkup(
        inputFieldPlaceholder: "hi",
        inputSuggestions: ["hello", "hi"],
        oneTimeKeyboard: true,
        rows: [
          markup_pb.ReplyKeyboardRow(
            buttons: [
              markup_pb.ReplyKeyboardButton(
                text: "پردانلود ترین",
                sendOnClick: true,
              ),
            ],
          ),
          markup_pb.ReplyKeyboardRow(
            buttons: [
              markup_pb.ReplyKeyboardButton(
                text: "جدیدترین",
                sendOnClick: true,
              ),
            ],
          ),
          markup_pb.ReplyKeyboardRow(
            buttons: [
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پیشنهادی",
                sendOnClick: true,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "پلی لیست",
                sendOnClick: false,
              )
            ],
          ),
          markup_pb.ReplyKeyboardRow(
            buttons: [
              markup_pb.ReplyKeyboardButton(
                text: "فالو شده ها",
                sendOnClick: false,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "دانلود شده ها",
                sendOnClick: false,
              ),
              markup_pb.ReplyKeyboardButton(
                text: "آموزش ها",
                sendOnClick: false,
              )
            ],
          )
        ],
      ),
      inlineKeyboardMarkup: markup_pb.InlineKeyboardMarkup(
        rows: [
          markup_pb.InlineKeyboardRow(
            buttons: [
              markup_pb.InlineKeyboardButton(
                text: "test",
                url: markup_pb.InlineKeyboardButtonUrl(
                  url: "https://google.com",
                ),
              ),
            ],
          ),
          markup_pb.InlineKeyboardRow(
            buttons: [
              markup_pb.InlineKeyboardButton(
                text: "test",
                callback:
                    markup_pb.InlineKeyboardButtonCallback(data: "hello test"),
              ),
              markup_pb.InlineKeyboardButton(
                text: "lets buy it",
                url: markup_pb.InlineKeyboardButtonUrl(
                  url: "https://google.com",
                ),
              )
            ],
          )
        ],
      ),
    );
    return Message(
      id: message.id.toInt(),
      roomUid: getRoomUid(_authRepo, message).asString(),
      packetId: message.packetId,
      time: message.time.toInt(),
      to: message.to.asString(),
      from: message.from.asString(),
      replyToId: message.replyToId.toInt(),
      forwardedFrom: message.forwardFrom.asString(),
      json: body,
      edited: message.edited,
      encrypted: message.encrypted,
      type: getMessageType(message.whichType()),
      isHidden: isHidden,
      markup: extractMessageMarkup(message),
    );
  }

  MessageMarkup? extractMessageMarkup(message_pb.Message message) {
    return message.hasMessageMarkup()
        ? MessageMarkup(
            inlineKeyboardMarkup: extractInlineKeyboardMarkup(
              message.messageMarkup.inlineKeyboardMarkup,
            ),
            replyKeyboardMarkup: extractReplyKeyboardMarkup(
              message.messageMarkup.replyKeyboardMarkup,
            ),
            removeReplyKeyboard:
                message.messageMarkup.removeReplyKeyboardMarkup,
          )
        : null;
  }

  String findInlineKeyboardButtonJson(markup_pb.InlineKeyboardButton button) {
    var json = Object();
    if (button.hasUrl()) {
      json = {"url": button.url.url};
    } else if (button.hasCallback()) {
      json = {
        "data": button.callback.data,
      };
    }
    return jsonEncode(json);
  }

  InlineKeyboardMarkup extractInlineKeyboardMarkup(
    markup_pb.InlineKeyboardMarkup inlineKeyboardMarkup,
  ) {
    return InlineKeyboardMarkup(
      rows: inlineKeyboardMarkup.rows
          .map(
            (e) => InlineKeyboardRow(
              buttons: e.buttons
                  .map(
                    (button) => InlineKeyboardButton(
                      text: button.text,
                      json: findInlineKeyboardButtonJson(button),
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  ReplyKeyboardMarkup extractReplyKeyboardMarkup(
    markup_pb.ReplyKeyboardMarkup replyKeyboardMarkup,
  ) {
    return ReplyKeyboardMarkup(
      rows: replyKeyboardMarkup.rows
          .map(
            (e) => ReplyKeyboardRow(
              buttons: e.buttons
                  .map(
                    (button) => ReplyKeyboardButton(
                      text: button.text,
                      sendOnClick: button.sendOnClick,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
      inputFieldPlaceHolder: replyKeyboardMarkup.inputFieldPlaceholder,
      inputSuggestions: replyKeyboardMarkup.inputSuggestions,
      oneTimeKeyboard: replyKeyboardMarkup.oneTimeKeyboard,
    );
  }
}
