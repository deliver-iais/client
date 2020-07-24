import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/fileRepoExtension.dart';

class CircleAvatarWidget extends StatelessWidget {
  String contactUid;
  double radius;
  var avatarDao = GetIt.I.get<AvatarDao>();
  var contactDao = GetIt.I.get<ContactDao>();
  var fileRepo = GetIt.I.get<FileRepo>();
  var accountRepo = GetIt.I.get<AccountRepo>();

  CircleAvatarWidget(String contactUid, double radius) {
    this.radius = radius;
    this.contactUid = contactUid;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
      child: FutureBuilder<dynamic>(
          future: fileRepo.getAvatarFile(accountRepo.avatar),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return new Image.file(
                snapshot.data,
              );
            } else {
              return new Text(contactUid,
                  style: TextStyle(
                      color: Colors.white, fontSize: radius, height: 2));
            }
          }),
    );
  }
}
