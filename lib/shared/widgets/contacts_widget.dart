import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/methods/name.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData circleIcon;
  final Function onCircleIcon;
  final bool isSelected;
  final bool currentMember;
  final _authRepo = GetIt.I.get<AuthRepo>();

  ContactWidget(
      {this.contact,
      this.circleIcon,
      this.isSelected = false,
      this.currentMember = false,
      this.onCircleIcon});

  @override
  Widget build(BuildContext context) {
    var _i18n = I18N.of(context);
    return Container(
      decoration: BoxDecoration(
          color: currentMember
              ? Theme.of(context).accentColor
              : isSelected
                  ? Theme.of(context).focusColor
                  : null,
          borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              _authRepo.isCurrentUser(contact.uid)
                  ? _i18n.get("saved_message")
                  : buildName(contact.firstName, contact.lastName),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: ExtraTheme.of(context).chatOrContactItemDetails,
                fontSize: 18,
              ),
            ),
          ),
          if (circleIcon != null)
            IconButton(
              onPressed: () => onCircleIcon?.call(),
              icon: Icon(
                circleIcon,
                color: ExtraTheme.of(context).circleAvatarIcon,
                size: 21,
              ),
            ),
        ],
      ),
    );
  }
}
