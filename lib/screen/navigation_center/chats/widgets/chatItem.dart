import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/activity_status.dart';
import 'package:deliver/shared/widgets/drag_dropWidget.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
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
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    if (widget.room.uid.asUid().category == Categories.USER)
      _lastActivityRepo.updateLastActivity(widget.room.uid.asUid());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(widget.room.uid.asUid().node);
    I18N _i18n = I18N.of(context);

    return FutureBuilder<String>(
        future: _roomRepo.getName(widget.room.uid.asUid()),
        builder: (c, name) {
          if (name.hasData && name.data != null && name.data.isNotEmpty) {
            return DragDropWidget(
                roomUid: widget.room.uid,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: widget.isSelected
                      ? Theme.of(context).focusColor
                      : Colors.transparent,
                  height: 70,
                  child: Row(
                    children: <Widget>[
                      ContactPic(widget.room.uid.asUid()),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              children: [
                                if (widget.room.uid.asUid().category ==
                                    Categories.GROUP)
                                  Flexible(
                                    child: Icon(
                                      Icons.group_rounded,
                                      size: 16,
                                    ),
                                  ),
                                if (widget.room.uid.asUid().category ==
                                    Categories.CHANNEL)
                                  Flexible(
                                    child: Icon(
                                      Icons.rss_feed_rounded,
                                      size: 16,
                                    ),
                                  ),
                                if (widget.room.uid.asUid().category ==
                                    Categories.BOT)
                                  Flexible(
                                    child: Icon(
                                      Icons.smart_toy_rounded,
                                      size: 16,
                                    ),
                                  ),
                                Expanded(
                                    flex: 50,
                                    child: Padding(
                                        padding: (widget.room.uid
                                                        .asUid()
                                                        .category ==
                                                    Categories.GROUP) ||
                                                (widget.room.uid
                                                        .asUid()
                                                        .category ==
                                                    Categories.CHANNEL) ||
                                                (widget.room.uid
                                                        .asUid()
                                                        .category ==
                                                    Categories.BOT)
                                            ? const EdgeInsets.only(left: 16.0)
                                            : EdgeInsets.zero,
                                        child: _authRepo
                                                .isCurrentUser(widget.room.uid)
                                            ? _showDisplayName(
                                                widget.room.uid.asUid(),
                                                _i18n.get("saved_message"),
                                                context)
                                            : _showDisplayName(
                                                widget.room.uid.asUid(),
                                                name.data,
                                                context))),
                                Text(
                                  dateTimeFormat(
                                      date(widget.room.lastUpdateTime)),
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: ExtraTheme.of(context)
                                        .centerPageDetails,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            StreamBuilder<Activity>(
                                stream: _roomRepo.activityObject[
                                    widget.room.uid.asUid().node],
                                builder: (c, s) {
                                  if (s.hasData &&
                                      s.data != null &&
                                      s.data.typeOfActivity !=
                                          ActivityType.NO_ACTIVITY) {
                                    return Row(
                                      children: [
                                        ActivityStatus(
                                          activity: s.data,
                                          roomUid: widget.room.uid.asUid(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: ExtraTheme.of(context)
                                                .centerPageDetails,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return widget.room.draft != null &&
                                            widget.room.draft.isNotEmpty
                                        ? buildDraftMessageWidget(
                                            _i18n, context)
                                        : widget.room.lastMessage != null
                                            ? buildLastMessage(
                                                widget.room.lastMessage)
                                            : FutureBuilder<Message>(
                                                future: _messageRepo
                                                    .fetchLastMessages(
                                                        widget.room.uid.asUid(),
                                                        widget
                                                            .room.lastMessageId,
                                                        widget.room
                                                            .firstMessageId,
                                                        widget.room
                                                            .lastUpdateTime,
                                                        widget.room),
                                                builder: (c, lastMessage) {
                                                  if (lastMessage.hasData &&
                                                      lastMessage.data != null)
                                                    return buildLastMessage(
                                                        lastMessage.data);
                                                  else
                                                    return SizedBox.shrink();
                                                });
                                  }
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          } else
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 11.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[800],
                        shape: BoxShape.circle),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[800],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 200,
                        height: 13,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[800],
                      ),
                    ],
                  ),
                ],
              ),
            );
        });
  }

  LastMessage buildLastMessage(Message message) {
    return LastMessage(
      message: message,
      lastMessageId: widget.room.lastMessageId,
      hasMentioned: widget.room.mentioned == true,
      showSender:
          widget.room.uid.isMuc() || _authRepo.isCurrentUser(message.from),
      pinned: widget.room.pinned ?? false,
    );
  }

  Widget buildDraftMessageWidget(I18N _i18n, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RichText(
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "${_i18n.get("draft")}: ",
                      style: Theme.of(context).primaryTextTheme.bodyText2),
                  TextSpan(
                      text: widget.room.draft,
                      style: Theme.of(context).textTheme.bodyText2)
                ],
              )),
        ),
      ],
    );
  }

  _showDisplayName(Uid uid, String name, BuildContext context) {
    return Text(
      name.trim(),
      style: Theme.of(context).textTheme.subtitle2,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}
