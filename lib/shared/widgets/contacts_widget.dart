import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData? circleIcon;
  final Function? onCircleIcon;
  final bool isSelected;
  final bool currentMember;

  const ContactWidget(
      {Key? key,
      required this.contact,
      this.circleIcon,
      this.isSelected = false,
      this.currentMember = false,
      this.onCircleIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: currentMember
            ? theme.colorScheme.secondary
            : isSelected
                ? theme.focusColor
                : null,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatarWidget(contact.uid.asUid(), 23,
              showSavedMessageLogoIfNeeded: true),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Text(
              buildName(contact.firstName, contact.lastName),
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: theme.textTheme.subtitle1,
            ),
          ),
          if (circleIcon != null)
            IconButton(
              onPressed: () => onCircleIcon?.call(),
              icon: Icon(
                circleIcon,
                size: 21,
              ),
            ),
        ],
      ),
    );
  }
}
