import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
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

  final List<Widget> buttons;

  ProfileAvatarCard({this.userUid, this.buttons});

  var _accountRepo = GetIt.I.get<AccountRepo>();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatarWidget(userUid, 80, showAsStreamOfAvatar: true,),
              SizedBox(
                height: 10,
              ),
              FutureBuilder<Account>(
                future: _accountRepo.getAccount(),
                builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
                  if(snapshot.data != null){
                    return Text(
                    "${snapshot.data.firstName}${snapshot.data.lastName??""}",
                      style: Theme.of(context).primaryTextTheme.headline5,
                    );
                  }else{
                    return SizedBox.shrink();
                  }
                },),

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
