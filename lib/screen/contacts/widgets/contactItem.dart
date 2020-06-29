import 'package:deliver_flutter/screen/contacts/models/contact.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  const ContactItem({this.contact});
  @override
  Widget build(BuildContext context) {
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
                    radius: 19,
                    backgroundColor: ThemeColors.circleAvatarbackground,
                    child: FittedBox(
                      child: Icon(
                        Icons.person,
                        color: ThemeColors.circleAvatarIcon,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: new BoxDecoration(
                        color: contact.isOnline ? Colors.green : ThemeColors.secondColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    top: 28.0,
                    right: 0.0,
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                contact.firstName + " " + contact.lastName,
                style: TextStyle(
                  color: ThemeColors.infoChat,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 16.5,
            backgroundColor: ThemeColors.secondColor,
            child: FittedBox(
              child: Icon(
                Icons.message,
                color: ThemeColors.circleAvatarIcon,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
