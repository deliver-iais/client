import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

String buildShareUserUrl(String countryCode, String nationalNumber,
        String firstName, String lastName) =>
    "https://$APPLICATION_DOMAIN/ac?cc=$countryCode&nn=$nationalNumber&fn=$firstName&ln=$lastName";

//https://deliver-co.ir/text?botId="bdff_bot" & text="/start"

Future<void> handleJoinUri(BuildContext context, String initialLink) async {
  final _mucDao = GetIt.I.get<MucDao>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();

  Uid? roomUid;
  final uri = Uri.parse(initialLink);
  final List<String?> segments =
      uri.pathSegments.where((e) => e != APPLICATION_DOMAIN).toList();
  if (segments.first == "text") {
    final botId = uri.queryParameters["botId"];
    if (botId != null) {
      _routingService.openRoom((Uid.create()
            ..node = botId
            ..category = Categories.BOT)
          .asString());
    }
  } else if (segments.first == JOIN) {
    if (segments[1] == "GROUP") {
      roomUid = Uid.create()
        ..node = segments[2].toString()
        ..category = Categories.GROUP;
    } else if (segments[1] == "CHANNEL") {
      roomUid = Uid.create()
        ..node = segments[2].toString()
        ..category = Categories.CHANNEL;
    }

    if (roomUid != null) {
      final muc = await _mucDao.get(roomUid.asString());
      if (muc != null) {
        _routingService.openRoom(roomUid.asString());
      } else {
        Future.delayed(Duration.zero, () {
          showFloatingModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircleAvatarWidget(roomUid!, 40, forceText: "un"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                          color: Colors.blueAccent,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(_i18n.get("skip"))),
                      MaterialButton(
                        color: Colors.blueAccent,
                        onPressed: () async {
                          final navigatorState = Navigator.of(context);
                          if (roomUid!.category == Categories.GROUP) {
                            final muc = await _mucRepo.joinGroup(
                                roomUid, segments[3].toString());
                            if (muc != null) {
                              navigatorState.pop();
                              _messageRepo.updateNewMuc(
                                  roomUid, muc.lastMessageId!);

                              _routingService.openRoom(roomUid.asString());
                            }
                          } else {
                            final muc = await _mucRepo.joinChannel(
                                roomUid, segments[3].toString());
                            if (muc != null) {
                              navigatorState.pop();
                              _messageRepo.updateNewMuc(
                                  roomUid, muc.lastMessageId!);
                              _routingService.openRoom(roomUid.asString());
                            }
                          }
                        },
                        child: Text(_i18n.get("join")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      }
    }
  }
}
