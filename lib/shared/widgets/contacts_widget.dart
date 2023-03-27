import 'package:deliver/box/contact.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
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
    return Transform.scale(
      scale: currentMember ? 0.98 : 1,
      child: Opacity(
        opacity: currentMember ? 0.7 : 1,
        child: AnimatedContainer(
          duration: AnimationSettings.slow,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: messageBorder,
            border: Border.all(color: theme.colorScheme.outline),
            color: currentMember
                ? theme.colorScheme.outline.withOpacity(0.6)
                : isSelected
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surface,
          ),
          margin: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: [
                  if (contact.uid != null)
                    CircleAvatarWidget(
                      contact.uid!.asUid(),
                      37,
                      borderRadius: secondaryBorder,
                      showSavedMessageLogoIfNeeded: true,
                    ),
                  AnimatedOpacity(
                    duration: AnimationSettings.normal,
                    opacity: isSelected ? 1 : 0,
                    child: AnimatedScale(
                      duration: AnimationSettings.normal,
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
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (currentMember)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_i18n.get("member")),
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
        ),
      ),
    );
  }
}
