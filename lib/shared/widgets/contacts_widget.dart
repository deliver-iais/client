import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/methods/name.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData circleIcon;
  final Function onCircleIcon;
  final bool isSelected;
  final bool currentMember;

  ContactWidget(
      {this.contact,
      this.circleIcon,
      this.isSelected = false,
      this.currentMember = false,
      this.onCircleIcon});

  @override
  Widget build(BuildContext context) {
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
          CircleAvatarWidget(contact.uid.asUid(), 23,
              showSavedMessageLogoIfNeeded: true),
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              buildName(contact.firstName, contact.lastName),
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
