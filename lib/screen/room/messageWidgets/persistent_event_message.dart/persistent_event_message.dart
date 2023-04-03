import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/persistent_event_handler_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  static final _persistentEventHandlerService =
      GetIt.I.get<PersistentEventHandlerService>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  final void Function(int, int) onPinMessageClick;
  final PersistentEvent persistentEventMessage;
  final double maxWidth;

  PersistentEventMessage({
    super.key,
    required this.message,
    required this.onPinMessageClick,
    required this.maxWidth,
  }) : persistentEventMessage = message.json.toPersistentEvent();

  @override
  Widget build(BuildContext context) {
    if (message.isHidden) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return persistentEventMessage.whichType() ==
            PersistentEvent_Type.botSpecificPersistentEvent
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: 1),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              padding: const EdgeInsetsDirectional.only(
                top: 5,
                end: 8.0,
                start: 8.0,
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
                      style: theme.textTheme.bodySmall,
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
                  ),
                  padding: const EdgeInsetsDirectional.only(
                    top: 6.0,
                    end: 8.0,
                    start: 8.0,
                    bottom: 2.0,
                  ),
                  child: FutureBuilder<List<Widget>?>(
                    future: getPersistentMessage(
                      persistentEventMessage,
                      context,
                      isChannel: message.roomUid.isChannel(),
                    ),
                    builder: (c, s) {
                      if (s.hasData && s.data != null) {
                        return Row(children: s.data!);
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
                        backgroundImage: fileSnapshot.data!.imageProvider(),
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
        final tuple = await _persistentEventHandlerService
            .getIssuerNameFromMucSpecificPersistentEvent(
          persistentEventMessage.mucSpecificPersistentEvent,
          message.roomUid,
          isChannel: isChannel,
        );
        final issuer = tuple.item1;
        final Widget issuerWidget = MouseRegion(
          cursor: tuple.item2 ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            child: Text(
              issuer,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              if (tuple.item2) {
                _routingServices.openRoom(
                  persistentEventMessage.mucSpecificPersistentEvent.issuer
                      .asString(),
                );
              }
            },
          ),
        );
        Widget? assigneeWidget;
        if ({
          MucSpecificPersistentEvent_Issue.ADD_USER,
          MucSpecificPersistentEvent_Issue.MUC_CREATED,
          MucSpecificPersistentEvent_Issue.KICK_USER
        }.contains(persistentEventMessage.mucSpecificPersistentEvent.issue)) {
          final assignee = await _persistentEventHandlerService
              .getAssignerNameFromMucSpecificPersistentEvent(
            persistentEventMessage.mucSpecificPersistentEvent,
          );
          assigneeWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                assignee!.trim(),
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
          final content =
              await _persistentEventHandlerService.getPinnedMessageBriefContent(
            message.roomUid,
            persistentEventMessage.mucSpecificPersistentEvent.messageId.toInt(),
          );
          pinedMessageWidget = MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Text(
                content,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                textDirection: _i18n.getDirection(content),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              onTap: () => onPinMessageClick(
                persistentEventMessage.mucSpecificPersistentEvent.messageId
                    .toInt(),
                message.id ?? 0,
              ),
            ),
          );
        }

        final issueWidget = Text(
          _persistentEventHandlerService.getMucSpecificPersistentEventIssue(
                persistentEventMessage,
                isChannel: isChannel,
              ) +
              (persistentEventMessage.mucSpecificPersistentEvent.issue ==
                      MucSpecificPersistentEvent_Issue.NAME_CHANGED
                  ? " \"${persistentEventMessage.mucSpecificPersistentEvent.name}\""
                  : ""),
          textDirection: _i18n.defaultTextDirection,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: const TextStyle(fontSize: 14, height: 1),
        );
        return [
          issuerWidget,
          const SizedBox(width: 3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                issueWidget,
                const SizedBox(width: 3),
                if (assigneeWidget != null) assigneeWidget,
                if (pinedMessageWidget != null) pinedMessageWidget,
              ],
            ),
          ),
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
}
