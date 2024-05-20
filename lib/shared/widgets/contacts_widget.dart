import 'package:deliver/models/user.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class ContactWidget extends StatelessWidget {
  final User user;
  final IconData? circleIcon;
  final Color? circleIconColor;
  final void Function()? onCircleIcon;
  final bool isSelected;
  final bool currentMember;

  const ContactWidget({
    super.key,
    required this.user,
    this.circleIcon,
    this.circleIconColor,
    this.isSelected = false,
    this.currentMember = false,
    this.onCircleIcon,
  });

  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _serverLessService = GetIt.I.get<ServerLessService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      duration: AnimationSettings.slow,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        // borderRadius: messageBorder,
        // border: Border.all(color: theme.colorScheme.outline),
        color: currentMember
            ? theme.colorScheme.outline.withOpacity(0.6)
            : isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (user.uid != null)
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatarWidget(
                      user.uid!,
                      28,
                      key: Key(user.uid!.asString()),
                      borderRadius: BorderRadius.circular(50),
                      showSavedMessageLogoIfNeeded: true,
                    ),
                    if (user.uid != null &&
                        user.uid!.category == Categories.USER &&
                        !_authRepo.isCurrentUser(user.uid!))
                      Obx(
                        () => _serverLessService.address.keys
                                .contains(user.uid!.asString())
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 18.0,
                                    height: 18.0,
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                      // borderRadius: BorderRadius.circular()
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 17.0,
                                        height: 17.0,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: ACTIVE_COLOR,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons
                                              .antenna_radiowaves_left_right,
                                          color: Colors.white,
                                          size: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      )
                  ],
                )
              else
                Container(
                  decoration: BoxDecoration(
                    borderRadius: secondaryBorder,
                    color: theme.colorScheme.primary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Icon(
                        CupertinoIcons.person,
                        size: 35,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isLarge(context)
                        ? MediaQuery.of(context).size.width / 2
                        : (circleIcon != null)
                            ? MediaQuery.of(context).size.width / 2.3
                            : MediaQuery.of(context).size.width / 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: user.firstname.isNotEmpty
                            ? TextLoader(
                                text: Text(
                                  buildName(user.firstname, user.lastname),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontSize: 15),
                                ),
                                width: 50,
                              )
                            : FutureBuilder<String>(
                                future: _roomRepo.getName(user.uid!),
                                builder: (c, s) => TextLoader(
                                  text: Text(
                                    s.data ?? user.id ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontSize: 15),
                                  ),
                                  width: 50,
                                ),
                              ),
                      ),
                      if (user.uid != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: TitleStatus(
                              currentRoomUid: user.uid,
                              style: TextStyle(fontSize: 8.7,color: theme.hintColor),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
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
          ),
          if (circleIcon != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 1),
              child: IconButton(
                splashRadius: 30,
                iconSize: 24,
                onPressed: () => onCircleIcon?.call(),
                icon: Icon(
                  circleIcon,
                  color: circleIconColor ?? theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
