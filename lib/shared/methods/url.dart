import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

String buildShareUserUrl(String countryCode, String nationalNumber,
        String firstName, String lastName) =>
    "https://$APPLICATION_DOMAIN/ac?cc=$countryCode&nn=$nationalNumber&fn=$firstName&ln=$lastName";

Future<void> handleJoinUri(BuildContext context, String initialLink) async {
  var _mucDao = GetIt.I.get<MucDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var m = initialLink.toString().split("/");

  Uid mucUid;
  if (m[4].toString().contains("GROUP")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.GROUP;
  } else if (m[4].toString().contains("CHANNEL")) {
    mucUid = Uid.create()
      ..node = m[5].toString()
      ..category = Categories.CHANNEL;
  }
  if (mucUid != null) {
    var muc = await _mucDao.get(mucUid.asString());
    if (muc != null) {
      _routingService.openRoom(mucUid.asString());
    } else {
      Future.delayed(Duration.zero, () {
        showFloatingModalBottomSheet(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatarWidget(mucUid, 40, forceText: "un"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
                        color: Colors.blueAccent,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(I18N.of(context).get("skip"))),
                    MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: () async {
                        if (mucUid.category == Categories.GROUP) {
                          Muc muc =
                              await _mucRepo.joinGroup(mucUid, m[6].toString());
                          if (muc != null) {
                            _messageRepo.updateNewMuc(
                                mucUid, muc.lastMessageId);
                            _routingService.openRoom(mucUid.asString());
                            Navigator.of(context).pop();
                          }
                        } else {
                          Muc muc = await _mucRepo.joinChannel(mucUid, m[6]);
                          if (muc != null) {
                            _messageRepo.updateNewMuc(
                                mucUid, muc.lastMessageId);
                            _routingService.openRoom(mucUid.asString());
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Text(I18N.of(context).get("join")),
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
