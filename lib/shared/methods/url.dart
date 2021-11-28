import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

String buildShareUserUrl(String countryCode, String nationalNumber,
        String firstName, String lastName) =>
    "https://$APPLICATION_DOMAIN/ac?cc=$countryCode&nn=$nationalNumber&fn=$firstName&ln=$lastName";

//https://deliver-co.ir/text?botId="bdff_bot" & text="/start"

Future<void> handleJoinUri(BuildContext context, String initialLink) async {
  var _mucDao = GetIt.I.get<MucDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var m = initialLink.toString().split("/");

  Uid? roomUid;
  Uri uri = Uri.parse(initialLink);
  List<String?> s =
      uri.pathSegments.where((e) => e != APPLICATION_DOMAIN).toList() ;
  if (s.first == "text") {
    String? botId = uri.queryParameters["botId"];
    if (botId != null) {
      _routingService.openRoom(
        (Uid.create()
              ..node = botId
              ..category = Categories.BOT)
            .asString(),
        context: context,
      );
    }
  } else if (m[4].toString().contains("GROUP")) {
    roomUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.GROUP;
  } else if (m[4].toString().contains("CHANNEL")) {
    roomUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.CHANNEL;
  }
  if (roomUid != null) {
    var muc = await _mucDao.get(roomUid.asString());
    if (muc != null) {
      _routingService.openRoom(roomUid.asString(), context: context);
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
                        child: Text(I18N.of(context)!.get("skip"))),
                    MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: () async {
                        if (roomUid!.category == Categories.GROUP) {
                          Muc? muc = await _mucRepo.joinGroup(
                              roomUid, m[6].toString());
                          if (muc != null) {
                            _messageRepo.updateNewMuc(
                                roomUid, muc.lastMessageId!);
                            _routingService.openRoom(roomUid.asString(),
                                context: context);
                            Navigator.of(context).pop();
                          }
                        } else {
                          Muc? muc = await _mucRepo.joinChannel(roomUid, m[6]);
                          if (muc != null) {
                            _messageRepo.updateNewMuc(
                                roomUid, muc.lastMessageId!);
                            _routingService.openRoom(roomUid.asString(),
                                context: context);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text(I18N.of(context)!.get("join")),
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
