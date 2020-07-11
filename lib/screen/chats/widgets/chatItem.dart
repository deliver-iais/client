import 'package:deliver_flutter/models/message.dart';
import 'package:deliver_flutter/screen/chats/widgets/recievedMsgStatusIcon.dart';
import 'package:deliver_flutter/screen/chats/widgets/sendedMsgStatusIcon.dart';
import 'package:deliver_flutter/models/contact.dart';
import 'package:deliver_flutter/models/conversation.dart';
import 'package:deliver_flutter/screen/contacts/contactsData.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/profilePic.dart';

class ChatItem extends StatelessWidget {
  final Conversation conversation;
  const ChatItem({this.conversation});
  @override
  Widget build(BuildContext context) {
    var messageType =
        conversation.lastMessage is SendedMessage ? "send" : "recieve";
    Contact contact = contactsList[conversation.contactId];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              ProfilePic(contact.isOnline, contact.photoName),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    contact.firstName + " " + contact.lastName,
                    style: TextStyle(
                      color: ThemeColors.infoChat,
                      fontSize: 17,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      messageType == "send"
                          ? SendedMsgIcon(
                              (conversation.lastMessage as SendedMessage)
                                  .status)
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3.0,
                        ),
                        child: Text(
                          conversation.lastMessage.text,
                          maxLines: 1,
                          style: TextStyle(
                            color: ThemeColors.infoChat,
                            fontSize: 13,
                          ),
                        ),
                      ),
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
                  findSendingTime(conversation.lastMessage.sendingTime),
                  maxLines: 1,
                  style: TextStyle(
                    color: ThemeColors.details,
                    fontSize: 11,
                  ),
                ),
              ),
              conversation.mentioned
                  ? (Padding(
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
                    ))
                  : messageType == "recieve"
                      ? RecievedMsgIcon(
                          (conversation.lastMessage as RecievedMessage).status)
                      : Container()
            ],
          )
        ],
      ),
    );
  }

  String findSendingTime(DateTime sendingTime) {
    var now = DateTime.now();
    var difference = now.difference(sendingTime);
    if (difference.inMinutes <= 2) {
      return "just now";
    } else if (difference.inDays < 1 && sendingTime.day == now.day) {
      var min = sendingTime.minute.toString();
      if (sendingTime.minute < 10) min = "0" + min;
      if (sendingTime.hour >= 12) {
        return (sendingTime.hour - 12).toString() + ":" + min + " pm.";
      } else {
        return sendingTime.hour.toString() + ":" + min + " am.";
      }
    } else if (difference.inDays <= 7) {
      switch (sendingTime.weekday) {
        case 1:
          return "Mon.";
        case 2:
          return "Tues.";
        case 3:
          return "Wed.";
        case 4:
          return "Thurs.";
        case 5:
          return "Fri.";
        case 6:
          return "Sat.";
        case 7:
          return "Sun.";
      }
    } else {
      switch (sendingTime.month) {
        case 1:
          return sendingTime.day.toString() + " Jan.";
        case 2:
          return sendingTime.day.toString() + " Feb.";
        case 3:
          return sendingTime.day.toString() + " Mar.";
        case 4:
          return sendingTime.day.toString() + " Apr.";
        case 5:
          return sendingTime.day.toString() + " May";
        case 6:
          return sendingTime.day.toString() + " Jun.";
        case 7:
          return sendingTime.day.toString() + " Jul.";
        case 8:
          return sendingTime.day.toString() + " Aug.";
        case 9:
          return sendingTime.day.toString() + " Sept.";
        case 10:
          return sendingTime.day.toString() + " Oct.";
        case 11:
          return sendingTime.day.toString() + " Nov.";
        case 12:
          return sendingTime.day.toString() + " Dec.";
      }
    }
    return "";
  }
}
