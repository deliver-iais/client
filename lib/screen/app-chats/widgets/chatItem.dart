import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/unread_message_counter.dart';
import 'package:deliver_flutter/shared/activityStatuse.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'contactPic.dart';
import 'lastMessage.dart';

class ChatItem extends StatefulWidget {
  final Room room;

  final bool isSelected;

  ChatItem({key: Key, this.room, this.isSelected}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  void initState() {
    if (widget.room.uid.getUid().category == Categories.USER)
      _lastActivityRepo.updateLastActivity(widget.room.uid.getUid());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.room.uid.getUid().node);
    AppLocalization _appLocalization = AppLocalization.of(context);
    String messageType =
        widget.room.lastMessage.from.isSameEntity(_accountRepo.currentUserUid)
            ? "send"
            : "receive";

    return FutureBuilder<String>(
        future: _roomRepo.getName(widget.room.uid.getUid()),
        builder: (c, name) {
          if (name.hasData && name.data != null && name.data.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(5),
              color: widget.isSelected
                  ? Theme.of(context).focusColor
                  : Colors.transparent,
              height:
                  widget.room.lastMessage.type == MessageType.PERSISTENT_EVENT
                      ? 74
                      : 66,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: ContactPic(widget.room.uid.getUid()),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: 200,
                                child: widget.room.uid
                                        .getUid()
                                        .toString()
                                        .contains(_accountRepo.currentUserUid
                                            .toString())
                                    ? _showDisplayName(
                                        widget.room.uid.getUid(),
                                        _appLocalization
                                            .getTraslateValue("saved_message"),
                                        context)
                                    : _showDisplayName(widget.room.uid.getUid(),
                                        name.data, context)),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4.0, right: 0),
                              child: Text(
                                dateTimeFormat(
                                    date(widget.room.lastMessage.time)),
                                maxLines: 1,
                                style: TextStyle(
                                  color:
                                      ExtraTheme.of(context).centerPageDetails,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          flex: 90,
                          child: StreamBuilder<Activity>(
                              stream: _roomRepo.activityObject[
                                  widget.room.uid.getUid().node],
                              builder: (c, s) {
                                if (s.hasData &&
                                    s.data != null &&
                                    s.data.typeOfActivity !=
                                        ActivityType.NO_ACTIVITY) {
                                  return ActivityStatuse(
                                    activity: s.data,
                                    roomUid: widget.room.uid.getUid(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ExtraTheme.of(context)
                                          .centerPageDetails,
                                    ),
                                  );
                                } else {
                                  return lastMessageWidget(
                                      messageType, context);
                                }
                              }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else
            return SizedBox(
              height: 66,
              width: MediaQuery.of(context).size.width,
            );
        });
  }

  Widget lastMessageWidget(String messageType, BuildContext context) {
    //  if(widget.roomWithMessage.lastMessage.roomId == '4:father_bot')
    return Row(
      children: <Widget>[
        if (messageType == "send") SeenStatus(widget.room.lastMessage),
        Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 4.0),
            child: LastMessage(message: widget.room.lastMessage)),
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              widget.room.mentioned == true
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 8.0,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            child: Image.asset(
                              "assets/icons/mention.png",
                              width: 20,
                              height: 20,
                            ),
                            // decoration: new BoxDecoration(
                            // //  color: Theme.of(context).primaryColor,
                            //   shape: BoxShape.circle,
                            // ),
                          ),
                        ],
                      ),
                    )
                  : messageType == "receive"
                      ? UnreadMessageCounterWidget(widget.room.lastMessage)
                      : Container()
            ],
          ),
        )
      ],
    );
  }

  _showDisplayName(Uid uid, String name, BuildContext context) {
    return Row(
      children: [
        if (uid.category == Categories.GROUP)
          Icon(
            Icons.group_rounded,
            size: 16,
          ),
        if (uid.category == Categories.CHANNEL)
          Icon(
            Icons.rss_feed_rounded,
            size: 16,
          ),
        if (uid.category == Categories.BOT)
          Icon(
            Icons.smart_toy_rounded,
            size: 16,
          ),
        if (uid.category != Categories.USER) SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(
            color: ExtraTheme.of(context).chatOrContactItemDetails,
            fontSize: 16,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
