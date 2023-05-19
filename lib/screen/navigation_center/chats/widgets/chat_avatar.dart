import 'package:deliver/box/last_activity.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatAvatar extends StatelessWidget {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18N = GetIt.I.get<I18N>();
  final Uid userUid;
  final Color? borderColor;

  const ChatAvatar(this.userUid, {super.key, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(
          userUid,
          CHAT_AVATAR_RADIUS,
          isHeroEnabled: false,
          showSavedMessageLogoIfNeeded: true,
        ),
        if (userUid.category == Categories.USER &&
            !_authRepo.isCurrentUser(userUid))
          StreamBuilder<LastActivity?>(
            stream: _lastActivityRepo.watch(userUid.asString()),
            builder: (c, la) {
              if (la.hasData && la.data != null && isOnline(la.data!.time)) {
                return Positioned.directional(
                  bottom: 0.0,
                  end: 0.0,
                  textDirection: _i18N.defaultTextDirection,
                  child: Container(
                    width: 17.0,
                    height: 17.0,
                    decoration: BoxDecoration(
                      color: borderColor ?? theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: ACTIVE_COLOR,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
      ],
    );
  }
}
