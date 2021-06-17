import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/recievedMsgStatusIcon.dart';
import 'package:deliver_flutter/shared/activityStatuse.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'contactPic.dart';
import 'lastMessage.dart';

class ChatItem extends StatefulWidget {
  final RoomWithMessage roomWithMessage;

  final bool isSelected;

  ChatItem({key: Key, this.roomWithMessage, this.isSelected}) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  var _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  final AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();

  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  void initState() {
    super.initState();
    if (widget.roomWithMessage.room.roomId.getUid().category == Categories.USER)
      _lastActivityRepo
          .updateLastActivity(widget.roomWithMessage.room.roomId.getUid());
  }

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.roomWithMessage.room.roomId.uid.node);
    AppLocalization _appLocalization = AppLocalization.of(context);
    String messageType = widget.roomWithMessage.lastMessage.from
            .isSameEntity(_accountRepo.currentUserUid)
        ? "send"
        : "receive";

    return FutureBuilder<String>(
        future: _roomRepo
            .getRoomDisplayName(widget.roomWithMessage.room.roomId.getUid()),
        builder: (c, name) {
          if (name.hasData && name.data != null && name.data.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(5),
              color: widget.isSelected ? Theme.of(context).focusColor : null,
              height: 66,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child:
                        ContactPic(widget.roomWithMessage.room.roomId.getUid()),
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
                                child: widget.roomWithMessage.room.roomId.uid
                                        .toString()
                                        .contains(_accountRepo.currentUserUid
                                            .toString())
                                    ? _showDisplayName(
                                        widget.roomWithMessage.room.roomId
                                            .getUid(),
                                        _appLocalization
                                            .getTraslateValue("saved_message"),
                                        context)
                                    : _showDisplayName(
                                        widget.roomWithMessage.room.roomId
                                            .getUid(),
                                        name.data,
                                        context)),
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 4.0, right: 0),
                              child: Text(
                                widget.roomWithMessage.lastMessage.time
                                    .dateTimeFormat(),
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
                                  widget.roomWithMessage.room.roomId.uid.node],
                              builder: (c, s) {
                                if (s.hasData &&
                                    s.data != null &&
                                    s.data.typeOfActivity !=
                                        ActivityType.NO_ACTIVITY) {
                                  return ActivityStatuse(
                                    activity: s.data,
                                    roomUid:
                                        widget.roomWithMessage.room.roomId.uid,
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
            return SizedBox.shrink();
        });
  }

  Widget lastMessageWidget(String messageType, BuildContext context) {
    //  if(widget.roomWithMessage.lastMessage.roomId == '4:father_bot')
    return Row(
      children: <Widget>[
        messageType == "send"
            ? SeenStatus(widget.roomWithMessage.lastMessage)
            : Container(),
        Padding(
            padding: const EdgeInsets.only(
              top: 3.0,
            ),
            child: LastMessage(message: widget.roomWithMessage.lastMessage)),
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              widget.roomWithMessage.room.mentioned == true
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
                      ? UnreadMessageCounterWidget(widget.roomWithMessage.lastMessage)
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
          ),
        if (uid.category == Categories.CHANNEL)
          Icon(
            Icons.rss_feed_rounded,
          ),
        if (uid.category == Categories.BOT)
          Icon(
            Icons.smart_toy_rounded,
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
