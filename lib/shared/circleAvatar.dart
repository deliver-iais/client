import 'dart:math';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/methods/colors.dart';
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

  Color colorFor(String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    print(finalHash * 0.01);
    var r = new Random(finalHash);
    return RandomColor(r).randomColor(
        colorHue: ColorHue.multiple(colorHues: [
          ColorHue.blue,
          ColorHue.yellow,
          ColorHue.red,
          ColorHue.orange
        ], random: r),
        colorBrightness: ColorBrightness.light,
        colorSaturation: ColorSaturation.highSaturation);
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorFor(contactUid.getString()),
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
