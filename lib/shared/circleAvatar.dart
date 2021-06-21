import 'dart:math';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/methods/colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final bool forceToUpdate;
  final bool showAsStreamOfAvatar;
  final bool showSavedMessageLogoIfNeeded;

  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();

  CircleAvatarWidget(this.contactUid, this.radius,
      {this.forceToUpdate = false,
      this.showAsStreamOfAvatar = false,
      this.showSavedMessageLogoIfNeeded = false});

  Color colorFor(BuildContext context, String text) {
    var hash = 0;
    for (var i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (100);
    var r = new Random(finalHash);
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
      _accountRepo.isCurrentUser(contactUid.asString());

  @override
  Widget build(BuildContext context) {
    var color = colorFor(context, contactUid.asString());
    var textColor =
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return CircleAvatar(
      radius: radius,
      backgroundColor: isSavedMessage()
          ? Colors.blue
          : contactUid.category == Categories.SYSTEM
              ? Colors.black12
              : color,
      child: contactUid.category == Categories.SYSTEM
          ? Image(
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
                  ? StreamBuilder<LastAvatar>(
                      stream: _avatarRepo.getLastAvatarStream(
                          contactUid, forceToUpdate),
                      builder: (context, snapshot) =>
                          this.builder(context, snapshot, textColor))
                  : FutureBuilder<LastAvatar>(
                      future:
                          _avatarRepo.getLastAvatar(contactUid, forceToUpdate),
                      builder: (context, snapshot) =>
                          this.builder(context, snapshot, textColor)),
    );
  }

  Widget builder(BuildContext context, AsyncSnapshot<LastAvatar> snapshot,
      Color textColor) {
    if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.data.fileId != null &&
        snapshot.data.fileName != null) {
      return FutureBuilder(
        future: _fileRepo.getFile(snapshot.data.fileId, snapshot.data.fileName,
            thumbnailSize: contactUid == _accountRepo.currentUserUid
                ? ThumbnailSize.large
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
    return contactUid != _accountRepo.currentUserUid
        ? FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(contactUid),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                String name = snapshot.data.replaceAll(' ', '');
                return Center(
                  child: Text(name.length > 2 ? name.substring(0, 2) : name,
                      style:
                          TextStyle(color: textColor, fontSize: (radius * 0.6).toInt().toDouble(), height: 2)),
                );
              } else {
                return Icon(
                  Icons.person,
                  size: radius,
                  color: Colors.white,
                );
              }
            },
          )
        : FutureBuilder<Account>(
            future: _accountRepo.getAccount(),
            builder: (BuildContext context, AsyncSnapshot<Account> snapshot) {
              if (snapshot.data != null) {
                return Text(
                    snapshot.data.firstName != null
                        ? snapshot.data.firstName.substring(0, 2)
                        : "",
                    style: TextStyle(
                        color: Colors.white, fontSize: radius, height: 2));
              } else {
                return SizedBox.shrink();
              }
            },
          );
  }
}
