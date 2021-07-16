import 'package:deliver_flutter/box/last_activity.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/lastActivityRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ContactPic extends StatelessWidget {
  final Uid userUid;

  ContactPic(this.userUid);

  final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(this.userUid, 24,
            showSavedMessageLogoIfNeeded: true),
        if (userUid.category == Categories.USER &&
            !_authRepo.isCurrentUser(userUid.asString()))
          StreamBuilder<LastActivity>(
              stream: _lastActivityRepo.watch(userUid.asString()),
              builder: (c, la) {
                if (la.hasData && la.data != null && la.data.time != null)
                  return isOnline(la.data.time)
                      ? Positioned(
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: new BoxDecoration(
                              color: Colors.greenAccent.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                          top: 32.0,
                          right: 0.0,
                        )
                      : SizedBox.shrink();
                else {
                  return SizedBox.shrink();
                }
              }),
      ],
    );
  }
}
