import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

import '../circleAvatar.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData circleIcon;
  var accountRepo = GetIt.I.get<AccountRepo>();

  ContactWidget({this.contact, this.circleIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CircleAvatarWidget(
                      accountRepo.currentUserUid,
                      contact.firstName.substring(0, 1) +
                          contact.lastName.substring(0, 1),
                      23),
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
                  fontSize: 18,
                ),
              ),
            ],
          ),
          circleIcon != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: ExtraTheme.of(context).secondColor,
                  child: FittedBox(
                    child: Icon(
                      circleIcon,
                      color: ExtraTheme.of(context).circleAvatarIcon,
                      size: 21,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
