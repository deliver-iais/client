import 'package:deliver/box/last_activity.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class ChatAvatar extends StatelessWidget {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _serverLessService = GetIt.I.get<ServerLessService>();

  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18N = GetIt.I.get<I18N>();
  final Uid uid;
  final Color? borderColor;

  const ChatAvatar(this.uid, {super.key, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(
          uid,
          CHAT_AVATAR_RADIUS,
          key: ValueKey(uid.asString()),
          isHeroEnabled: false,
          showSavedMessageLogoIfNeeded: true,
        ),
        if (uid.category == Categories.USER && !_authRepo.isCurrentUser(uid))
          Obx(() => _serverLessService.address.keys.contains(uid.asString())
              ? Positioned.directional(
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
                        width: 14.0,
                        height: 14.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: ACTIVE_COLOR,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                )
              : _buildStatus(theme))
      ],
    );
  }

  Widget _buildStatus(ThemeData theme) {
    if (uid.category == Categories.USER && !_authRepo.isCurrentUser(uid)) {
      return StreamBuilder<LastActivity?>(
        stream: _lastActivityRepo.watch(uid.asString()),
        builder: (c, la) {
          if (la.hasData && la.data != null && isOnline(la.data!.time)) {
            return Positioned.directional(
              bottom: 0.0,
              end: 0.0,
              textDirection: _i18N.defaultTextDirection,
              child: Container(
                width: 16.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: borderColor ?? theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 13.0,
                    height: 13.0,
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
      );
    }
    return const SizedBox.shrink();
  }
}
