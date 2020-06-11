import 'package:deliver_flutter/screen/contacts/models/contact.dart';
import 'package:deliver_flutter/screen/chats/models/conversation.dart';
import 'package:deliver_flutter/screen/contacts/contactsData.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  final Conversation conversation;
  const ChatItem({this.conversation});
  @override
  Widget build(BuildContext context) {
    Contact contact = contactsList[conversation.contactId];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: ThemeColors.circleAvatarbackground,
                    child: FittedBox(
                      child: Icon(
                        Icons.person,
                        color: ThemeColors.circleAvatarIcon,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: new BoxDecoration(
                        color: contact.online ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    top: 35.0,
                    right: 0.0,
                  ),
                ],
              ),
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
                      Text(
                        conversation.lastMessage.text,
                        maxLines: 1,
                        style: TextStyle(
                          color: ThemeColors.infoChat,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "  . " +
                            (DateTime.now().minute -
                                    conversation.lastMessage.sendingTime.minute)
                                .toString() +
                            " m",
                        // ". " + conversation.lastMessage.sendingTime.difference(DateTime.now()).toString() + " m",
                        maxLines: 1,
                        style: TextStyle(
                          color: ThemeColors.details,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Stack(
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
                top: 3.0,
                left: 1.75,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: new BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
