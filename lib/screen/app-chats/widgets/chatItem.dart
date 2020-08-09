import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/recievedMsgStatusIcon.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

import 'contactPic.dart';
import 'lastMessage.dart';

class ChatItem extends StatelessWidget {
  final RoomWithMessage roomWithMessage;
  const ChatItem({this.roomWithMessage});
  @override
  Widget build(BuildContext context) {
    var routeData = RouteData.of(context);
    String loggedInUserId = routeData.pathParams['id'].value;
    var messageType =
        roomWithMessage.lastMessage.from == loggedInUserId ? "send" : "recieve";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              ContactPic(true,
                  'https://brandyourself.com/blog/wp-content/uploads/linkedin-profile-picture-too-close.png'),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    // contact.firstName + " " + contact.lastName,
                    'Judi',
                    style: TextStyle(
                      color: ExtraTheme.of(context).infoChat,
                      fontSize: 17,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      messageType == "send"
                          ? SeenStatus(
                              (roomWithMessage.lastMessage.seen) ? 1 : 0)
                          : Container(),
                      Padding(
                          padding: const EdgeInsets.only(
                            top: 3.0,
                          ),
                          child: LastMessage(
                              message: roomWithMessage.lastMessage)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4.0,
                ),
                child: Text(
                  findSendingTime(roomWithMessage.lastMessage.time),
                  maxLines: 1,
                  style: TextStyle(
                    color: ExtraTheme.of(context).details,
                    fontSize: 11,
                  ),
                ),
              ),
              roomWithMessage.room.mentioned != null
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
                  : messageType == "recieve" &&
                          !roomWithMessage.lastMessage.seen
                      ? ReceivedMsgIcon(roomWithMessage.lastMessage.seen)
                      : Container()
            ],
          )
        ],
      ),
    );
  }
}
