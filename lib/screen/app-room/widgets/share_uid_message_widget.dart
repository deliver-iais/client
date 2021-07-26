import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';

import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/shared/widgets/seen_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';


import 'msgTime.dart';



class ShareUidMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final _mucRepo = GetIt.I.get<MucRepo>();

  final _routingServices = GetIt.I.get<RoutingService>();

  final _messageRepo = GetIt.I.get<MessageRepo>();

  ShareUidMessageWidget({this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    var _shareUid = message.json.toShareUid();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        CircleAvatarWidget(_shareUid.uid, 18,
                            forceText: _shareUid.name),
                        if (_shareUid.uid.category == Categories.GROUP)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.group_rounded,
                              size: 18,
                            ),
                          ),
                        if (_shareUid.uid.category == Categories.CHANNEL)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.rss_feed_rounded,
                              size: 18,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            _shareUid.name +
                                (_shareUid.uid.category != Categories.USER
                                    ? " ${I18N.of(context).get("invite_link")}"
                                    : ""),
                            style: TextStyle(
                              fontSize: 16,
                              color: ExtraTheme.of(context).username,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () async {
                    if ((_shareUid.uid.category == Categories.GROUP ||
                        _shareUid.uid.category == Categories.CHANNEL)) {
                      var muc = await _mucRepo.getMuc(_shareUid.uid.asString());
                      if (muc != null) {
                        _routingServices.openRoom(_shareUid.uid.asString());
                      } else {
                        showFloatingModalBottomSheet(
                          context: context,
                          builder: (context) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircleAvatarWidget(_shareUid.uid, 40,
                                    forceText: _shareUid.name),
                                Text(
                                  _shareUid.name,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MaterialButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(I18N.of(context)
                                            .get("skip"))),
                                    MaterialButton(
                                        onPressed: () async {
                                          // Navigator.of(context).pop();
                                          if ((_shareUid.uid.category ==
                                                  Categories.GROUP ||
                                              _shareUid.uid.category ==
                                                  Categories.CHANNEL)) {
                                            var muc = await _mucRepo.getMuc(
                                                _shareUid.uid.asString());
                                            if (muc == null) {
                                              if (_shareUid.uid.category ==
                                                  Categories.GROUP) {
                                                var res =
                                                    await _mucRepo.joinGroup(
                                                        _shareUid.uid,
                                                        _shareUid.joinToken);
                                                if (res != null) {
                                                  _messageRepo.updateNewMuc(
                                                      _shareUid.uid,res.lastMessageId);
                                                  _routingServices.openRoom(
                                                      _shareUid.uid.asString());
                                                  Navigator.of(context).pop();
                                                }
                                              } else {
                                                var res =
                                                    await _mucRepo.joinChannel(
                                                        _shareUid.uid,
                                                        _shareUid.joinToken);
                                                if (res!= null) {
                                                  _messageRepo.updateNewMuc(
                                                      _shareUid.uid,res.lastMessageId);
                                                  _routingServices.openRoom(
                                                      _shareUid.uid.asString());
                                                  Navigator.of(context).pop();
                                                }
                                              }
                                            } else
                                              _routingServices.openRoom(
                                                _shareUid.uid.asString(),
                                              );
                                          } else {
                                            _routingServices.openRoom(
                                                _shareUid.uid.asString());
                                          }
                                        },
                                        child: Text(I18N.of(context)
                                            .get("join")))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      _routingServices.openRoom(_shareUid.uid.asString());
                    }
                  },
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 5),
                      child: MsgTime(
                        time: date(message.time),
                      ),
                    ),
                    if (isSender)
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0, top: 5),
                        child: SeenStatus(
                          message,
                          isSeen: isSeen,
                        ),
                      ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}
