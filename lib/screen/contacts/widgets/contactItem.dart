import 'package:deliver_flutter/models/contact.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
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
                    backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
                    child: FittedBox(
                      child: Icon(
                        Icons.person,
                        color: ExtraTheme.of(context).circleAvatarIcon,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: new BoxDecoration(
                        color: contact.isOnline
                            ? Colors.green
                            : ExtraTheme.of(context).secondColor,
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
                  color: ExtraTheme.of(context).infoChat,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 16.5,
            backgroundColor: ExtraTheme.of(context).secondColor,
            child: FittedBox(
              child: Icon(
                Icons.message,
                color: ExtraTheme.of(context).circleAvatarIcon,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
