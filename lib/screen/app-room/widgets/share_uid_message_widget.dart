import 'dart:math';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'msgTime.dart';

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const FloatingModal({Key key, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: Container(
        width: min(MediaQuery.of(context).size.width, 400),
        // height: 100,
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20)),
          child: child,
        ),
      ),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  BuildContext context,
  WidgetBuilder builder,
  Color backgroundColor,
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      containerWidget: (_, animation, child) => FloatingModal(
            child: child,
          ),
      expand: false);

  return result;
}

class ShareUidMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  var _mucRepo = GetIt.I.get<MucRepo>();

  ShareUidMessageWidget({this.message, this.isSender, this.isSeen});

  var _routingServices = GetIt.I.get<RoutingService>();
  var _mucDao = GetIt.I.get<MucDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();

  proto.ShareUid _shareUid;

  @override
  Widget build(BuildContext context) {
    _shareUid = message.json.toShareUid();
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
                                    ? " ${AppLocalization.of(context).getTraslateValue("inviteLink")}"
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
                      var muc = await _mucDao.get(_shareUid.uid.asString());
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
                                        child: Text(AppLocalization.of(context)
                                            .getTraslateValue("skip"))),
                                    MaterialButton(
                                        onPressed: () async {
                                          // Navigator.of(context).pop();
                                          if ((_shareUid.uid.category ==
                                                  Categories.GROUP ||
                                              _shareUid.uid.category ==
                                                  Categories.CHANNEL)) {
                                            var muc = await _mucDao
                                                .get(_shareUid.uid.asString());
                                            if (muc == null) {
                                              if (_shareUid.uid.category ==
                                                  Categories.GROUP) {
                                                var res =
                                                    await _mucRepo.joinGroup(
                                                        _shareUid.uid,
                                                        _shareUid.joinToken);
                                                if (res) {
                                                  _routingServices.openRoom(
                                                      _shareUid.uid.asString());
                                                  Navigator.of(context).pop();
                                                }
                                              } else {
                                                var res =
                                                    await _mucRepo.joinChannel(
                                                        _shareUid.uid,
                                                        _shareUid.joinToken);
                                                if (res) {
                                                  _messageRepo.updateNewChannel(
                                                      _shareUid.uid);
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
                                        child: Text(AppLocalization.of(context)
                                            .getTraslateValue("join")))
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
