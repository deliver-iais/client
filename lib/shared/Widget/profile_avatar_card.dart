import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileAvatarCard extends StatelessWidget {
  final Uid userUid;
  var lastAvatar;
  final List<Widget> buttons;
  var _routingServices = GetIt.I.get<RoutingService>();

  ProfileAvatarCard({this.userUid, this.buttons});

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _avatarRepo = GetIt.I.get<AvatarRepo>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                child: Hero(
                  tag: "avatar",
                  child: CircleAvatarWidget(
                    userUid,
                    80,
                    showAsStreamOfAvatar: true,
                  ),
                ),
                onTap: () async {
                  var lastAvatar = await _avatarRepo.getLastAvatar(
                      _accountRepo.currentUserUid, false);
                  if (lastAvatar.createdOn != null) {
                    _routingServices.openShowAllAvatars(
                        uid: userUid,
                        hasPermissionToDeleteAvatar: true,
                        heroTag: "avatar");
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              FutureBuilder<Account>(
                future: _accountRepo.getAccount(),
                builder:
                    (BuildContext context, AsyncSnapshot<Account> snapshot) {
                  if (snapshot.data != null) {
                    return Text(
                      "${snapshot.data.firstName}${snapshot.data.lastName ?? ""}",
                      style: Theme.of(context).primaryTextTheme.headline5,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons,
              )
            ],
          ),
          color: Theme.of(context).accentColor.withAlpha(50),
        ));
  }
}
