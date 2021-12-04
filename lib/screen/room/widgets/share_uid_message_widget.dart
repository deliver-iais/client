import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/routing_service.dart';

import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class ShareUidMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final _mucRepo = GetIt.I.get<MucRepo>();

  final _routingServices = GetIt.I.get<RoutingService>();

  final _messageRepo = GetIt.I.get<MessageRepo>();

  final _i18n = GetIt.I.get<I18N>();

  ShareUidMessageWidget(
      {Key? key, required this.message, required this.isSender, required this.isSeen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _shareUid = message.json!.toShareUid();
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: StreamBuilder<Object>(
          stream: null,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                    child: Row(
                      children: [
                        CircleAvatarWidget(_shareUid.uid, 18,
                            forceText: _shareUid.name),
                        if (_shareUid.uid.category == Categories.GROUP)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.group_rounded,
                              size: 18,
                            ),
                          ),
                        if (_shareUid.uid.category == Categories.CHANNEL)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
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
                                    ? " ${_i18n.get("invite_link")}"
                                    : ""),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right)
                      ],
                    ),
                  ),
                  onPressed: () async {
                    if ((_shareUid.uid.category == Categories.GROUP ||
                        _shareUid.uid.category == Categories.CHANNEL)) {
                      var muc = await _mucRepo.getMuc(_shareUid.uid.asString());
                      if (muc != null) {
                        _routingServices.openRoom(_shareUid.uid.asString(),
                            context: context);
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
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MaterialButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(_i18n.get("skip"))),
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
                                                      _shareUid.uid,
                                                      res.lastMessageId!);
                                                  _routingServices.openRoom(
                                                      _shareUid.uid.asString(),
                                                      context: context);
                                                  Navigator.of(context).pop();
                                                }
                                              } else {
                                                var res =
                                                    await _mucRepo.joinChannel(
                                                        _shareUid.uid,
                                                        _shareUid.joinToken);
                                                if (res != null) {
                                                  _messageRepo.updateNewMuc(
                                                      _shareUid.uid,
                                                      res.lastMessageId!);
                                                  _routingServices.openRoom(
                                                      _shareUid.uid.asString(),
                                                      context: context);
                                                  Navigator.of(context).pop();
                                                }
                                              }
                                            } else {
                                              _routingServices.openRoom(
                                                  _shareUid.uid.asString(),
                                                  context: context);
                                            }
                                          } else {
                                            _routingServices.openRoom(
                                                _shareUid.uid.asString(),
                                                context: context);
                                          }
                                        },
                                        child: Text(_i18n.get("join")))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      _routingServices.openRoom(_shareUid.uid.asString(),
                          context: context);
                    }
                  },
                ),
                TimeAndSeenStatus(
                  message,
                  isSender,
                  isSeen,
                  needsPositioned: false,
                  needsPadding: false,
                ),
              ],
            );
          }),
    );
  }
}
