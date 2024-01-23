import 'package:deliver/box/dao/local_network-connection_dao.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/local_network_connections.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatAvatar extends StatelessWidget {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _localNetworkDao = GetIt.I.get<LocalNetworkConnectionDao>();
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
          StreamBuilder<LocalNetworkConnections?>(
            stream: _localNetworkDao.watch(uid),
            builder: (c, la) {
              if (la.hasData && (la.data != null)) {
                return Positioned.directional(
                  bottom: 0.0,
                  end: 0.0,
                  textDirection: _i18N.defaultTextDirection,
                  child: Container(
                    width: 18.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      color: borderColor ?? theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
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
                          CupertinoIcons.antenna_radiowaves_left_right,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                if (settings.inLocalNetwork.value) {
                  return const SizedBox.shrink();
                }
                if (uid.category == Categories.USER &&
                    !_authRepo.isCurrentUser(uid)) {
                  return StreamBuilder<LastActivity?>(
                    stream: _lastActivityRepo.watch(uid.asString()),
                    builder: (c, la) {
                      if (la.hasData &&
                          la.data != null &&
                          isOnline(la.data!.time)) {
                        return Positioned.directional(
                          bottom: 0.0,
                          end: 0.0,
                          textDirection: _i18N.defaultTextDirection,
                          child: Container(
                            width: 17.0,
                            height: 17.0,
                            decoration: BoxDecoration(
                              color:
                                  borderColor ?? theme.scaffoldBackgroundColor,
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
                  );
                }
                return const SizedBox.shrink();
              }
            },
          ),
      ],
    );
  }
}
