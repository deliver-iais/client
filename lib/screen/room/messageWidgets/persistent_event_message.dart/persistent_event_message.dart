import 'dart:io';
import 'dart:math';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final Function? onPinMessageClick;
  final PersistentEvent persistentEventMessage;
  final double maxWidth;

  PersistentEventMessage(
      {Key? key,
      required this.message,
      this.onPinMessageClick,
      required this.maxWidth})
      : persistentEventMessage = message.json.toPersistentEvent(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return message.json == EMPTY_MESSAGE
        ? const SizedBox.shrink()
        : persistentEventMessage.whichType() ==
                PersistentEvent_Type.botSpecificPersistentEvent
            ? Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  decoration: const BoxDecoration(borderRadius: mainBorder),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_i18n.get("bot_not_responding"),
                          style: const TextStyle(fontSize: 16)),
                      if (persistentEventMessage
                          .botSpecificPersistentEvent.errorMessage.isNotEmpty)
                        Text(
                            persistentEventMessage
                                .botSpecificPersistentEvent.errorMessage,
                            style: theme.textTheme.headline5),
                    ],
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: theme.chipTheme.backgroundColor,
                          borderRadius: tertiaryBorder,
                          border: Border.fromBorderSide(theme.chipTheme.side!)),
                      padding: const EdgeInsets.only(
                          top: 5, left: 8.0, right: 8.0, bottom: 4.0),
                      child: FutureBuilder<List<Widget>?>(
                        future: getPersistentMessage(persistentEventMessage,
                            message.roomUid.isChannel(), context),
                        builder: (c, s) {
                          if (s.hasData && s.data != null) {
                            return Directionality(
                                textDirection: _i18n.isPersian
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Row(
                                  children: s.data!,
                                ));
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ),
                  if (message.json.toPersistentEvent().whichType() ==
                          PersistentEvent_Type.mucSpecificPersistentEvent &&
                      message.json.toPersistentEvent()
                              .mucSpecificPersistentEvent
                              .issue ==
                          MucSpecificPersistentEvent_Issue.AVATAR_CHANGED)
                    FutureBuilder<String?>(
                        future: _fileRepo.getFile(
                            persistentEventMessage
                                .mucSpecificPersistentEvent.avatar.fileUuid,
                            persistentEventMessage
                                .mucSpecificPersistentEvent.avatar.fileName),
                        builder: (context, fileSnapshot) {
                          if (fileSnapshot.hasData &&
                              fileSnapshot.data != null) {
                            return CircleAvatar(
                              backgroundImage:
                                  Image.file(File(fileSnapshot.data!)).image,
                              radius: 35,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                ],
              );
  }

  Future<List<Widget>?> getPersistentMessage(
      PersistentEvent persistentEventMessage,
      bool isChannel,
      BuildContext context) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        String? issuer = await _roomRepo.getSlangName(
            persistentEventMessage.mucSpecificPersistentEvent.issuer);
        Widget issuerWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                issuer,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                    fontSize: 14, height: 1, fontWeight: FontWeight.bold),
              ),
              onTap: () => _routingServices.openRoom(persistentEventMessage
                  .mucSpecificPersistentEvent.issuer
                  .asString()),
            ));
        Widget? assigneeWidget;
        if ({
          MucSpecificPersistentEvent_Issue.ADD_USER,
          MucSpecificPersistentEvent_Issue.MUC_CREATED,
          MucSpecificPersistentEvent_Issue.KICK_USER
        }.contains(persistentEventMessage.mucSpecificPersistentEvent.issue)) {
          String assignee = await _roomRepo.getSlangName(
              persistentEventMessage.mucSpecificPersistentEvent.assignee);
          assigneeWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                assignee.trim(),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                    fontSize: 14, height: 1, fontWeight: FontWeight.bold),
              ),
              onTap: () => _routingServices.openRoom(persistentEventMessage
                  .mucSpecificPersistentEvent.assignee
                  .asString()),
            ),
          );
        }
        Widget? pinedMessageWidget;
        if (persistentEventMessage.mucSpecificPersistentEvent.issue ==
            MucSpecificPersistentEvent_Issue.PIN_MESSAGE) {
          var content = await getPinnedMessageContent();
          pinedMessageWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                content.substring(0, min(content.length, 15)),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, height: 1),
              ),
              onTap: () => onPinMessageClick!(persistentEventMessage
                  .mucSpecificPersistentEvent.messageId
                  .toInt()),
            ),
          );
        }

        var issueWidget = Text(
          getMucSpecificPersistentEventIssue(persistentEventMessage, isChannel),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 14, height: 1),
        );
        return [
          issuerWidget,
          const SizedBox(width: 3),
          issueWidget,
          const SizedBox(width: 3),
          if (assigneeWidget != null) assigneeWidget,
          if (pinedMessageWidget != null) pinedMessageWidget,
        ];
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        return null;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        switch (persistentEventMessage.adminSpecificPersistentEvent.event) {
          case AdminSpecificPersistentEvent_Event.NEW_CONTACT_ADDED:
            return [
              Text("${_i18n.get("joined_to_app")} ${APPLICATION_NAME.trim()}")
            ];

          default:
            return null;
        }

      default:
        return null;
    }
  }

  String getMucSpecificPersistentEventIssue(
      PersistentEvent persistentEventMessage, bool isChannel) {
    switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
      case MucSpecificPersistentEvent_Issue.ADD_USER:
        return _i18n.verb("added",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));

      case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
        return _i18n.verb(
          isChannel ? "change_channel_avatar" : "change_group_avatar",
          isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
              .mucSpecificPersistentEvent.issuer
              .asString()),
        );

      case MucSpecificPersistentEvent_Issue.JOINED_USER:
        return _i18n.verb("joined",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
      case MucSpecificPersistentEvent_Issue.KICK_USER:
        return _i18n.verb("kicked",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));

      case MucSpecificPersistentEvent_Issue.LEAVE_USER:
        return _i18n.verb("left",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));

      case MucSpecificPersistentEvent_Issue.MUC_CREATED:
        return _i18n.verb("created",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));

      case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
        return _i18n.verb("changed_name",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
      case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
        return _i18n.verb("pinned",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
      default:
        return "";
    }
  }

  Future<String> getPinnedMessageContent() async {
    Message? m = await _messageDao.getMessage(message.roomUid,
        persistentEventMessage.mucSpecificPersistentEvent.messageId.toInt());
    if (m != null) {
      switch (m.type) {
        case MessageType.TEXT:
          return m.json.toText().text;

        case MessageType.FILE:
          return m.json.toFile().caption;

        case MessageType.STICKER:
          // TODO: Handle this case.
          return "";

        case MessageType.LOCATION:
          return _i18n.get("location");

        case MessageType.LIVE_LOCATION:
          return _i18n.get("live_location");

        case MessageType.POLL:
          // TODO: Handle this case.
          return "";

        case MessageType.FORM:
          return _i18n.get("form");

        case MessageType.PERSISTENT_EVENT:
          // TODO: Handle this case.
          return "";

        case MessageType.NOT_SET:
          // TODO: Handle this case.
          return "";

        case MessageType.BUTTONS:
          // TODO: Handle this case.
          return "";

        case MessageType.SHARE_UID:
          // TODO: Handle this case.
          return "";

        case MessageType.FORM_RESULT:
          // TODO: Handle this case.
          return "";

        case MessageType.SHARE_PRIVATE_DATA_REQUEST:
          // TODO: Handle this case.
          return "";

        case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
          // TODO: Handle this case.
          return "";

        default:
          return "";
      }
    }

    return "";
  }
}
