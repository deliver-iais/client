import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

import '../circleAvatar.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData circleIcon;
  final bool isSelected;
  final bool currentMember;
  final _accountRepo = GetIt.I.get<AccountRepo>();

  ContactWidget(
      {this.contact,
      this.circleIcon,
      this.isSelected = false,
      this.currentMember = false});


  @override
  Widget build(BuildContext context) {
    var _appLocalization = AppLocalization.of(context);
    return Container(
      decoration: BoxDecoration(
          color: currentMember
              ? Theme.of(context).accentColor
              : isSelected
                  ? Theme.of(context).focusColor
                  : null,
          borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
      padding: const EdgeInsets.all(MAIN_PADDING / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  contact.uid != null
                      ? CircleAvatarWidget(contact.uid.asUid(), 23,
                          showSavedMessageLogoIfNeeded: true)
                      : CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            contact.lastName.length > 2
                                ? contact.lastName.substring(0, 2)
                                : contact.lastName,
                            style: TextStyle(color: Colors.white),
                          ),
                          radius: 23,
                        ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                _accountRepo.isCurrentUser(contact.uid)
                    ? _appLocalization.getTraslateValue("saved_message")
                    : buildName(contact.firstName, contact.lastName),
                overflow: TextOverflow.clip,
                style: TextStyle(
                  color: ExtraTheme.of(context).chatOrContactItemDetails,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (circleIcon != null)
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).accentColor.withAlpha(200),
              child: FittedBox(
                child: Icon(
                  circleIcon,
                  color: ExtraTheme.of(context).circleAvatarIcon,
                  size: 21,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
