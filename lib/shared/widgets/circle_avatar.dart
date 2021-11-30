import 'dart:io';
import 'dart:math';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final String forceText;
  final bool forceToUpdate;
  final bool showAsStreamOfAvatar;
  final bool showSavedMessageLogoIfNeeded;

  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  CircleAvatarWidget(this.contactUid, this.radius,
      {Key? key, this.forceToUpdate = false,
      this.forceText = "",
      this.showAsStreamOfAvatar = false,
      this.showSavedMessageLogoIfNeeded = false}) : super(key: key);

  Color colorFor(BuildContext context, String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    var r = Random(finalHash);
    return RandomColor(r).randomColor(
        colorHue: ColorHue.multiple(colorHues: [
          ColorHue.blue,
          ColorHue.yellow,
          ColorHue.red,
          ColorHue.orange
        ], random: r),
        colorBrightness: Theme.of(context).brightness == Brightness.dark
            ? ColorBrightness.light
            : ColorBrightness.dark,
        colorSaturation: ColorSaturation.highSaturation);
  }

  bool isSavedMessage() =>
      showSavedMessageLogoIfNeeded &&
      _authRepo.isCurrentUser(contactUid.asString());

  bool isSystem() => contactUid.category == Categories.SYSTEM;

  @override
  Widget build(BuildContext context) {
    var color = colorFor(context, contactUid.asString());

    if (isSavedMessage()) color = Colors.blue;
    if (isSystem()) color = Colors.blue;

    var textColor =
        changeColor(color, saturation: 0.8, lightness: 0.5).computeLuminance() >
                0.5
            ? Colors.black
            : Colors.white;

    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [
            changeColor(color, saturation: 0.8, lightness: 0.4),
            changeColor(color, saturation: 0.8, lightness: 0.5),
            changeColor(color, saturation: 0.8, lightness: 0.7),
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: contactUid.category == Categories.SYSTEM
            ? const Image(
                image: AssetImage(
                    'assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png'),
              )
            : isSavedMessage()
                ? Icon(
                    Icons.bookmark,
                    size: radius,
                    color: Colors.white,
                  )
                : showAsStreamOfAvatar
                    ? StreamBuilder<Avatar>(
                        stream: _avatarRepo.getLastAvatarStream(
                            contactUid, forceToUpdate),
                        builder: (context, snapshot) =>
                            builder(context, snapshot, textColor))
                    : FutureBuilder<Avatar?>(
                        future: _avatarRepo.getLastAvatar(
                            contactUid, forceToUpdate),
                        builder: (context, snapshot) =>
                            builder(context, snapshot, textColor)),
      ),
    );
  }

  Widget builder(
      BuildContext context, AsyncSnapshot<Avatar?> snapshot, Color textColor) {
    if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data!.fileId != null &&
        snapshot.data!.fileName != null) {
      return FutureBuilder<File?>(
        future: _fileRepo.getFile(
            snapshot.data!.fileId!, snapshot.data!.fileName!,
            thumbnailSize: contactUid == _authRepo.currentUserUid
                ? null
                : ThumbnailSize.medium),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (snaps.hasData) {
            return CircleAvatar(
              radius: radius,
              backgroundImage: Image.file(
                snaps.data,
              ).image,
            );
          } else {
            return showDisplayName(textColor);
          }
        },
      );
    } else {
      return showDisplayName(textColor);
    }
  }

  Widget showDisplayName(Color textColor) {
    if (forceText.isNotEmpty) {
      return avatarAlt(forceText.trim(), textColor);
    }
    return FutureBuilder<String>(
      future: _roomRepo.getName(contactUid),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.data != null) {
          String name = snapshot.data!.trim();
          return avatarAlt(name.trim(), textColor);
        } else {
          return Icon(
            Icons.person,
            size: radius,
            color: Colors.white,
          );
        }
      },
    );
  }

  Center avatarAlt(String name, Color textColor) {
    return Center(
      child: Text(
          name.length > 1
              ? name.substring(0, 1).toUpperCase()
              : name.toUpperCase(),
          maxLines: null,
          style: TextStyle(
              color: textColor, fontSize: (radius * 0.9).toInt().toDouble())),
    );
  }
}
