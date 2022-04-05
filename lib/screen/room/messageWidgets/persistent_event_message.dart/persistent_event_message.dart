import 'dart:io';
import 'dart:math';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final void Function(int) onPinMessageClick;
  final PersistentEvent persistentEventMessage;
  final double maxWidth;

  PersistentEventMessage({
    Key? key,
    required this.message,
    required this.onPinMessageClick,
    required this.maxWidth,
  })  : persistentEventMessage = message.json.toPersistentEvent(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.isHidden) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return persistentEventMessage.whichType() ==
            PersistentEvent_Type.botSpecificPersistentEvent
        ? Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              padding: const EdgeInsets.only(
                top: 5,
                left: 8.0,
                right: 8.0,
                bottom: 4.0,
              ),
              decoration: BoxDecoration(
                color: theme.chipTheme.backgroundColor,
                borderRadius: secondaryBorder,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_bubble,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _i18n.get("bot_not_responding"),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  if (persistentEventMessage
                      .botSpecificPersistentEvent.errorMessage.isNotEmpty)
                    Text(
                      persistentEventMessage
                          .botSpecificPersistentEvent.errorMessage,
                      style: theme.textTheme.caption,
                    )
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
                    border: Border.fromBorderSide(theme.chipTheme.side!),
                  ),
                  padding: const EdgeInsets.only(
                    top: 5,
                    left: 8.0,
                    right: 8.0,
                    bottom: 4.0,
                  ),
                  child: FutureBuilder<List<Widget>?>(
                    future: getPersistentMessage(
                      persistentEventMessage,
                      context,
                      isChannel: message.roomUid.isChannel(),
                    ),
                    builder: (c, s) {
                      if (s.hasData && s.data != null) {
                        return Directionality(
                          textDirection: _i18n.isPersian
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Row(
                            children: s.data!,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              if (message.json.toPersistentEvent().whichType() ==
                      PersistentEvent_Type.mucSpecificPersistentEvent &&
                  message.json
                          .toPersistentEvent()
                          .mucSpecificPersistentEvent
                          .issue ==
                      MucSpecificPersistentEvent_Issue.AVATAR_CHANGED)
                FutureBuilder<String?>(
                  future: _fileRepo.getFile(
                    persistentEventMessage
                        .mucSpecificPersistentEvent.avatar.fileUuid,
                    persistentEventMessage
                        .mucSpecificPersistentEvent.avatar.fileName,
                  ),
                  builder: (context, fileSnapshot) {
                    if (fileSnapshot.hasData && fileSnapshot.data != null) {
                      return CircleAvatar(
                        backgroundImage:
                            Image.file(File(fileSnapshot.data!)).image,
                        radius: 35,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
            ],
          );
  }

  Future<List<Widget>?> getPersistentMessage(
    PersistentEvent persistentEventMessage,
    BuildContext context, {
    bool isChannel = false,
  }) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        final issuer = await _roomRepo.getSlangName(
          persistentEventMessage.mucSpecificPersistentEvent.issuer,
        );
        final Widget issuerWidget = MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Text(
              issuer,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _routingServices.openRoom(
              persistentEventMessage.mucSpecificPersistentEvent.issuer
                  .asString(),
            ),
          ),
        );
        Widget? assigneeWidget;
        if ({
          MucSpecificPersistentEvent_Issue.ADD_USER,
          MucSpecificPersistentEvent_Issue.MUC_CREATED,
          MucSpecificPersistentEvent_Issue.KICK_USER
        }.contains(persistentEventMessage.mucSpecificPersistentEvent.issue)) {
          final assignee = await _roomRepo.getSlangName(
            persistentEventMessage.mucSpecificPersistentEvent.assignee,
          );
          assigneeWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                assignee.trim(),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _routingServices.openRoom(
                persistentEventMessage.mucSpecificPersistentEvent.assignee
                    .asString(),
              ),
            ),
          );
        }
        Widget? pinedMessageWidget;
        if (persistentEventMessage.mucSpecificPersistentEvent.issue ==
            MucSpecificPersistentEvent_Issue.PIN_MESSAGE) {
          final content = await getPinnedMessageBriefContent();
          pinedMessageWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                content.substring(0, min(content.length, 15)),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              onTap: () => onPinMessageClick(
                persistentEventMessage.mucSpecificPersistentEvent.messageId
                    .toInt(),
              ),
            ),
          );
        }

        final issueWidget = Text(
          getMucSpecificPersistentEventIssue(
            persistentEventMessage,
            isChannel: isChannel,
          ),
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
      case PersistentEvent_Type.botSpecificPersistentEvent:
      case PersistentEvent_Type.notSet:
        return null;
    }
  }

  String getMucSpecificPersistentEventIssue(
    PersistentEvent persistentEventMessage, {
    bool isChannel = false,
  }) {
    switch (persistentEventMessage.mucSpecificPersistentEvent.issue) {
      case MucSpecificPersistentEvent_Issue.ADD_USER:
        return _i18n.verb(
          "added",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
        return _i18n.verb(
          isChannel ? "change_channel_avatar" : "change_group_avatar",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.JOINED_USER:
        return _i18n.verb(
          "joined",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.KICK_USER:
        return _i18n.verb(
          "kicked",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.LEAVE_USER:
        return _i18n.verb(
          "left",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.MUC_CREATED:
        return _i18n.verb(
          "created",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );

      case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
        return _i18n.verb(
          "changed_name",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
        return _i18n.verb(
          "pinned",
          isFirstPerson: _authRepo.isCurrentUser(
            persistentEventMessage.mucSpecificPersistentEvent.issuer.asString(),
          ),
        );
      case MucSpecificPersistentEvent_Issue.DELETED:
        return "";
    }
    return "";
  }

  Future<String> getPinnedMessageBriefContent() async {
    final m = await _messageDao.getMessage(
      message.roomUid,
      persistentEventMessage.mucSpecificPersistentEvent.messageId.toInt(),
    );
    if (m != null) {
      switch (m.type) {
        case MessageType.TEXT:
          return m.json.toText().text;

        case MessageType.FILE:
          return m.json.toFile().caption;

        case MessageType.LOCATION:
          return _i18n.get("location");

        case MessageType.LIVE_LOCATION:
          return _i18n.get("live_location");

        case MessageType.FORM:
          return _i18n.get("form");

        case MessageType.STICKER:
        case MessageType.POLL:
        case MessageType.PERSISTENT_EVENT:
        case MessageType.BUTTONS:
        case MessageType.SHARE_UID:
        case MessageType.FORM_RESULT:
        case MessageType.SHARE_PRIVATE_DATA_REQUEST:
        case MessageType.SHARE_PRIVATE_DATA_ACCEPTANCE:
        case MessageType.CALL:
        case MessageType.Table:
        case MessageType.NOT_SET:
          return "";
      }
    }

    return "";
  }
}
