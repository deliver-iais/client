import 'package:deliver/box/last_activity.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactPic extends StatelessWidget {
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  final Uid userUid;

  const ContactPic(this.userUid, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(
          userUid,
          24,
          isHeroEnabled: false,
          showSavedMessageLogoIfNeeded: true,
        ),
        if (userUid.category == Categories.USER &&
            !_authRepo.isCurrentUser(userUid.asString()))
          StreamBuilder<LastActivity?>(
            stream: _lastActivityRepo.watch(userUid.asString()),
            builder: (c, la) {
              if (la.hasData && la.data != null) {
                return isOnline(la.data!.time)
                    ? Positioned(
                        top: 32.0,
                        right: 0.0,
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          decoration: BoxDecoration(
                            color: ACTIVE_COLOR,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
      ],
    );
  }
}
