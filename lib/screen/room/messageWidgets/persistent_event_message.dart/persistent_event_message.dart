import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/persistent_event.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class PersistentEventMessage extends StatelessWidget {
  final Message message;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingServices = GetIt.I.get<RoutingService>();

  PersistentEventMessage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PersistentEvent persistentEventMessage = message.json.toPersistentEvent();
    return message.json == "{}"
        ? Container(
            height: 0.0,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.json.toPersistentEvent().whichType() ==
                      PersistentEvent_Type.mucSpecificPersistentEvent &&
                  message.json
                          .toPersistentEvent()
                          .mucSpecificPersistentEvent
                          .issue ==
                      MucSpecificPersistentEvent_Issue.AVATAR_CHANGED)
                FutureBuilder<File>(
                    future: _fileRepo.getFile(
                        "b039a936-9cbc-4636-9df0-8b2f4908901f",
                        "wg2ebsshi26t.jpeg"),
                    builder: (context, fileSnapshot) {
                      if (fileSnapshot.hasData && fileSnapshot.data != null) {
                        return CircleAvatar(
                          backgroundImage:
                              Image.file(File(fileSnapshot.data.path)).image,
                          radius: 35,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.only(
                    top: 5, left: 8.0, right: 8.0, bottom: 4.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FutureBuilder<List<Widget>>(
                  future: getPersistentMessage(
                      persistentEventMessage, message.roomUid.isChannel()),
                  builder: (c, s) {
                    if (s.hasData && s.data != null) {
                      return Directionality(
                          textDirection: _i18n.isPersian
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          child: Row(
                            children: s.data,
                          ));
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          );
  }

  Future<List<Widget>> getPersistentMessage(
    PersistentEvent persistentEventMessage,
    bool isChannel,
  ) async {
    switch (persistentEventMessage.whichType()) {
      case PersistentEvent_Type.mucSpecificPersistentEvent:
        String issuer = await _roomRepo.getSlangName(
            persistentEventMessage.mucSpecificPersistentEvent.issuer);
        var issuerWidget = GestureDetector(
          child: Text(
            issuer,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(fontSize: 14, height: 1, color: Colors.white),
          ),
          onTap: () => _routingServices.openRoom(persistentEventMessage
              .mucSpecificPersistentEvent.issuer
              .asString()),
        );
        Widget assigneeWidget;
        if ({
          MucSpecificPersistentEvent_Issue.ADD_USER,
          MucSpecificPersistentEvent_Issue.MUC_CREATED,
          MucSpecificPersistentEvent_Issue.KICK_USER
        }.contains(persistentEventMessage.mucSpecificPersistentEvent.issue)) {
          String assignee = await _roomRepo.getSlangName(
              persistentEventMessage.mucSpecificPersistentEvent.assignee);
          assigneeWidget = GestureDetector(
            child: Text(
              assignee,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(fontSize: 14, height: 1, color: Colors.white),
            ),
            onTap: () => _routingServices.openRoom(persistentEventMessage
                .mucSpecificPersistentEvent.assignee
                .asString()),
          );
        }

        var s = Text(
          getMucSpecificPersistentEventIssue(persistentEventMessage, isChannel),
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: TextStyle(fontSize: 14, height: 1, color: Colors.white),
        );
        return [
          issuerWidget,
          s,
          SizedBox(
            width: 2,
          ),
          if (assigneeWidget != null) assigneeWidget
        ];

        break;
      case PersistentEvent_Type.messageManipulationPersistentEvent:
        return null;
        break;
      case PersistentEvent_Type.adminSpecificPersistentEvent:
        switch (persistentEventMessage.adminSpecificPersistentEvent.event) {
          case AdminSpecificPersistentEvent_Event.NEW_CONTACT_ADDED:
            return [
              Text("${_i18n.get("joined_to_app")} ${APPLICATION_NAME.trim()}")
            ];
            break;
          default:
            return null;
            break;
        }
        break;
      default:
        return null;
        break;
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

        break;
      case MucSpecificPersistentEvent_Issue.AVATAR_CHANGED:
        return _i18n.verb(
          isChannel
              ? _i18n.verb("change_channel_avatar")
              : "change_group_avatar",
          isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
              .mucSpecificPersistentEvent.issuer
              .asString()),
        );
        break;
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
        break;
      case MucSpecificPersistentEvent_Issue.LEAVE_USER:
        return _i18n.verb("left",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
        break;
      case MucSpecificPersistentEvent_Issue.MUC_CREATED:
        return _i18n.verb("created",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
        break;
      case MucSpecificPersistentEvent_Issue.NAME_CHANGED:
        return _i18n.verb("changed_name",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
        break;
      case MucSpecificPersistentEvent_Issue.PIN_MESSAGE:
        return _i18n.verb("pinned",
            isFirstPerson: _authRepo.isCurrentUser(persistentEventMessage
                .mucSpecificPersistentEvent.issuer
                .asString()));
        break;
    }
  }
}
