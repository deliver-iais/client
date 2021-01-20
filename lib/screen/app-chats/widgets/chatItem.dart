import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/recievedMsgStatusIcon.dart';
import 'package:deliver_flutter/shared/activityStatuse.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'contactPic.dart';
import 'lastMessage.dart';

class ChatItem extends StatelessWidget {
  final RoomWithMessage roomWithMessage;

  final bool isSelected;

  final AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();

  final _roomRepo = GetIt.I.get<RoomRepo>();

  ChatItem({key: Key, this.roomWithMessage, this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _roomRepo.initActivity(roomWithMessage.room.roomId.uid.node);
    AppLocalization _appLocalization = AppLocalization.of(context);
    String messageType = roomWithMessage.lastMessage.from
            .isSameEntity(_accountRepo.currentUserUid)
        ? "send"
        : "receive";

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).focusColor : null,
          border: isSelected
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
      height: 66,
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: ContactPic(true, roomWithMessage.room.roomId.uid),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
              flex: 90,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: 200,
                        child: roomWithMessage.room.roomId.uid
                                .toString()
                                .contains(
                                    _accountRepo.currentUserUid.toString())
                            ? _showDisplayName(
                                _appLocalization
                                    .getTraslateValue("saved_message"),
                                context)
                            : FutureBuilder<String>(
                                future: _roomRepo.getRoomDisplayName(
                                    roomWithMessage.room.roomId.uid),
                                builder: (BuildContext c,
                                    AsyncSnapshot<String> snaps) {
                                  if (snaps.hasData && snaps.data.isNotEmpty) {
                                    return _showDisplayName(
                                        snaps.data, context);
                                  } else {
                                    return _showDisplayName("Unknown", context);
                                  }
                                })),
                    StreamBuilder<Activity>(
                        stream: _roomRepo
                            .activityObject[roomWithMessage.room.roomId.uid.node],
                        builder: (c, s) {
                          if (s.hasData &&
                              s.data != null &&
                              s.data.typeOfActivity !=
                                  ActivityType.NO_ACTIVITY) {
                            return ActivityStatuse(
                              activity: s.data,
                              roomUid: roomWithMessage.room.roomId.uid,
                              style: TextStyle(
                                fontSize: 16,
                                color: ExtraTheme.of(context).details,
                              ),
                            );
                          } else {
                            return lastMessageWidget(messageType, context);
                          }
                        }),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget lastMessageWidget(String messageType, BuildContext context) {
    return Row(
      children: <Widget>[
        messageType == "send"
            ? SeenStatus(roomWithMessage.lastMessage)
            : Container(),
        Padding(
            padding: const EdgeInsets.only(
              top: 3.0,
            ),
            child: LastMessage(message: roomWithMessage.lastMessage)),
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4.0,
                ),
                child: Text(
                  roomWithMessage.lastMessage.time.dateTimeFormat(),
                  maxLines: 1,
                  style: TextStyle(
                    color: ExtraTheme.of(context).details,
                    fontSize: 11,
                  ),
                ),
              ),
              roomWithMessage.room.mentioned == true
                  ? Padding(
                      padding: const EdgeInsets.only(
                        right: 3.0,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 15,
                            height: 15,
                            decoration: new BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            top: 2.25,
                            right: 2.25,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: new BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : messageType == "receive"
                      ? ReceivedMsgIcon(roomWithMessage.lastMessage)
                      : Container()
            ],
          ),
        )
      ],
    );
  }

  _showDisplayName(name, context) {
    return Text(
      name,
      style: TextStyle(
        color: ExtraTheme.of(context).infoChat,
        fontSize: 16,
      ),
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
}
