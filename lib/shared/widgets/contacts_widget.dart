import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';

class ContactWidget extends StatelessWidget {
  final Contact contact;
  final IconData? circleIcon;
  final void Function()? onCircleIcon;
  final bool isSelected;
  final bool currentMember;

  const ContactWidget({
    super.key,
    required this.contact,
    this.circleIcon,
    this.isSelected = false,
    this.currentMember = false,
    this.onCircleIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? theme.focusColor : null,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatarWidget(
            contact.uid.asUid(),
            23,
            showSavedMessageLogoIfNeeded: true,
          ),
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
              splashRadius: 40,
              iconSize: 24,
              onPressed: () => onCircleIcon?.call(),
              icon: Icon(
                circleIcon,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
