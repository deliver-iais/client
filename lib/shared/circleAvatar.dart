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

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final bool forceToUpdate;
  String displayName;
  final bool showAsStreamOfAvatar;

  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  CircleAvatarWidget(this.contactUid, this.displayName, this.radius,
      {this.forceToUpdate = false, this.showAsStreamOfAvatar = false}) {
    String name = this.displayName;
    this.displayName = (name == null
            ? ""
            : (name.length >= 2
                ? name.substring(0, 2)
                : (name.isEmpty ? "" : name[0])))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
      child: showAsStreamOfAvatar
          ? StreamBuilder<LastAvatar>(
              stream:
                  _avatarRepo.getLastAvatarStream(contactUid, forceToUpdate),
              builder: this.builder)
          : FutureBuilder<LastAvatar>(
              future: _avatarRepo.getLastAvatar(contactUid, forceToUpdate),
              builder: this.builder),
    );
  }

  Widget builder(BuildContext context, AsyncSnapshot<LastAvatar> snapshot) {
    if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data.fileId != null &&
        snapshot.data.fileName != null) {
      return FutureBuilder(
        future: _fileRepo.getFile(snapshot.data.fileId, snapshot.data.fileName),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (snaps.hasData) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: Image.file(
                snaps.data,
              ).image,
            );
          } else {
            return new Text(displayName,
                style: TextStyle(
                    color: Colors.white, fontSize: radius, height: 2));
          }
        },
      );
    } else {
      return Text(displayName,
          style: TextStyle(color: Colors.white, fontSize: radius, height: 2));
    }
  }
}
