import 'dart:io';
import 'dart:math';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final String forceText;
  final bool showSavedMessageLogoIfNeeded;
  final bool hideName;

  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();

  const CircleAvatarWidget(this.contactUid, this.radius,
      {Key? key,
      this.forceText = "",
      this.hideName = false,
      this.showSavedMessageLogoIfNeeded = false})
      : super(key: key);

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
    if (isSystem()) color = Colors.white;

    var textColor =
        changeColor(color, saturation: 0.8, lightness: 0.5).computeLuminance() >
                0.5
            ? Colors.black
            : Colors.white;

    return Hero(
      tag: contactUid.asString(),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: !isSystem()
                ? LinearGradient(colors: [
                    changeColor(color, saturation: 0.8, lightness: 0.4),
                    changeColor(color, saturation: 0.8, lightness: 0.5),
                    changeColor(color, saturation: 0.8, lightness: 0.7),
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)
                : null),
        child: contactUid.category == Categories.SYSTEM
            ? const Image(
                image: AssetImage('assets/images/logo.png'),
              )
            : isSavedMessage()
                ? Icon(
                    Icons.bookmark,
                    size: radius,
                    color: Colors.white,
                  )
                : StreamBuilder<String?>(
                    initialData: _avatarRepo.fastForwardAvatar(contactUid),
                    stream: _avatarRepo
                        .getLastAvatarStream(contactUid, false)
                        .asBroadcastStream(),
                    builder: (context, snapshot) =>
                        builder(context, snapshot, textColor)),
      ),
    );
  }

  Widget builder(
      BuildContext context, AsyncSnapshot<String?> snapshot, Color textColor) {
    if (snapshot.hasData) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: kIsWeb
            ? Image.network(snapshot.data!).image
            : Image.file(File(snapshot.data!)).image,
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
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget avatarAlt(String name, Color textColor) {
    if (hideName) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Text(
          name.length > 1
              ? name.substring(0, 1).toUpperCase()
              : name.toUpperCase(),
          maxLines: 1,
          style: TextStyle(color: textColor, fontSize: radius, height: 1)),
    );
  }
}
