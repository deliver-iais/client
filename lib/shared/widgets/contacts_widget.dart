import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/constants.dart';
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
    return AnimatedContainer(
      duration: SLOW_ANIMATION_DURATION,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: messageBorder,
        border: Border.all(color: theme.colorScheme.outline),
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
      ),
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: [
              CircleAvatarWidget(
                contact.uid.asUid(),
                37,
                borderRadius: secondaryBorder,
                showSavedMessageLogoIfNeeded: true,
              ),
              AnimatedOpacity(
                duration: ANIMATION_DURATION,
                opacity: isSelected ? 1 : 0,
                child: AnimatedScale(
                  duration: ANIMATION_DURATION,
                  scale: isSelected ? 1 : 0.8,
                  child: Container(
                    height: 74,
                    width: 74,
                    decoration: BoxDecoration(
                      borderRadius: secondaryBorder,
                      color: theme.colorScheme.primary.withOpacity(0.6),
                    ),
                    child: Icon(
                      Icons.check_box_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 40,
                    ),
                  ),
                ),
              )
            ],
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                splashRadius: 40,
                iconSize: 24,
                onPressed: () => onCircleIcon?.call(),
                icon: Icon(
                  circleIcon,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
