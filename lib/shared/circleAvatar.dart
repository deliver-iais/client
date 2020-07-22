

import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatelessWidget{
  String contactUid;
  double radius;
  double fontSize;
  var avatarDao = GetIt.I.get<AvatarDao>();
  var contactDao = GetIt.I.get<ContactDao>();
 // var fileRepo = GetIt.I.get<FileRepo>();
  var accountRepo = GetIt.I.get<AccountRepo>();

  CircleAvatarWidget(String contactUid,double radius , double fontSize){
    this.radius = radius;
    this.fontSize = fontSize;
    this.contactUid = contactUid;
  }

  @override
  Widget build(BuildContext context) {
    File file;
    return  CircleAvatar(
        radius: radius ,
        backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
        child: file == null
            ? new Text(contactUid ,style: TextStyle(color: Colors.white, fontSize: 48,))
            : Text("fjbhdj")
//              new Image.file(
//                      fileRepo.getAvatarFile(accountRepo.avatar.fileId),
//                    )
    );

  }


}