import 'dart:async';

import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedBannerItem extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final Uid uid;
  static String _roomName = "";

  const GroupedBannerItem({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: p8),
      child: GestureDetector(
        onTap: () => _routingService.openRoom(uid.asString()),
        child: Column(
          children: [
            const SizedBox(height: p4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatarWidget(
                  uid,
                  20,
                ),
                const SizedBox(width: 8),
                if (uid.category == Categories.GROUP)
                  const SizedBox(
                    width: 16,
                    child: Icon(
                      CupertinoIcons.person_2_fill,
                      size: 16,
                    ),
                  ),
                if (uid.category == Categories.CHANNEL)
                  const SizedBox(
                    width: 16,
                    child: Icon(
                      CupertinoIcons.news_solid,
                      size: 16,
                    ),
                  ),
                if (uid.category == Categories.BOT)
                  const SizedBox(
                    width: 16,
                    child: Icon(
                      Icons.smart_toy,
                      size: 16,
                    ),
                  ),
                if (uid.category == Categories.GROUP ||
                    uid.category == Categories.CHANNEL ||
                    uid.category == Categories.BOT)
                  const SizedBox(width: 6),
                Expanded(
                  child: FutureBuilder<String>(
                    initialData: _roomRepo.fastForwardName(
                      uid,
                    ),
                    future: _roomRepo.getName(uid),
                    builder: (context, snapshot) {
                      _roomName = snapshot.data ?? _i18n.get("loading");
                      return RoomName(
                        uid: uid,
                        name: _roomName,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: p4),
            SizedBox(
              width: double.infinity,
              child: FutureBuilder<Room?>(
                future: _roomRepo.getRoom(uid),
                builder: (context, snapshot) {
                  if (snapshot.data != null && !snapshot.data!.deleted) {
                    return OutlinedButton(
                      onPressed: () {
                        _routingService.openRoom(uid.asString());
                      },
                      child: Text(_i18n.get("open")),
                    );
                  }
                  return OutlinedButton(
                    onPressed: () async {
                      if (uid.category == Categories.GROUP) {
                        final res = await _mucRepo.joinGroup(
                          uid,
                          "",
                        );
                        if (res != null) {
                          _routingService.openRoom(uid.asString());
                        }
                      } else if (uid.category == Categories.CHANNEL) {
                        final res = await _mucRepo.joinChannel(
                          uid,
                          "",
                        );
                        if (res != null) {
                          _routingService.openRoom(uid.asString());
                        }
                      } else if (uid.category == Categories.BOT) {
                        unawaited(_messageRepo.sendTextMessage(uid, "/start"));
                        _routingService.openRoom(uid.asString());
                      }
                    },
                    child: uid.category == Categories.BOT
                        ? Text(_i18n.get("start"))
                        : Text(_i18n.get("join")),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
