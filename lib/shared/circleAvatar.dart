import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/fileRepoExtension.dart';

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final String displayName;
  final bool forceToUpdate;

  final avatarRepo = GetIt.I.get<AvatarRepo>();
  final contactDao = GetIt.I.get<ContactDao>();
  final fileRepo = GetIt.I.get<FileRepo>();
  final accountRepo = GetIt.I.get<AccountRepo>();

  CircleAvatarWidget(this.contactUid, this.displayName, this.radius,
      {this.forceToUpdate = false});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
      child: FutureBuilder<LastAvatar>(
          future:
              avatarRepo.getLastAvatar(contactUid, this.forceToUpdate),
          builder: (BuildContext context, AsyncSnapshot<LastAvatar> snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data.fileId != null &&
                snapshot.data.fileName != null) {
              return FutureBuilder(
                future: fileRepo.getFile(
                    snapshot.data.fileId, snapshot.data.fileName),
                builder: (BuildContext c, AsyncSnapshot snaps) {
                  if (snaps.hasData) {
                    return CircleAvatar(
                      radius: radius,
                      backgroundImage: Image.file(
                        snaps.data,
                      ).image,
                    );
                  } else {
                    return new Text("JD",
                        style: TextStyle(
                            color: Colors.white, fontSize: radius, height: 2));
                  }
                },
              );
            } else {
              return new Text("JD",
                  style: TextStyle(
                      color: Colors.white, fontSize: radius, height: 2));
            }
          }),
    );
  }
}
