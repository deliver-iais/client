import 'dart:io';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatelessWidget {
  final Uid contactUid;
  final double radius;
  final String forceText;
  final bool showSavedMessageLogoIfNeeded;
  final bool hideName;
  final bool isHeroEnabled;
  late final _globalKey = GlobalObjectKey(contactUid.asString());
  final _streamKey = GlobalKey();
  final _futureKey = GlobalKey();

  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();

  CircleAvatarWidget(this.contactUid, this.radius,
      {Key? key,
      this.forceText = "",
      this.hideName = false,
      this.isHeroEnabled = true,
      this.showSavedMessageLogoIfNeeded = false})
      : super(key: key);

  bool isSavedMessage() =>
      showSavedMessageLogoIfNeeded &&
      _authRepo.isCurrentUser(contactUid.asString());

  bool isSystem() => contactUid.category == Categories.SYSTEM;

  @override
  Widget build(BuildContext context) {
    final scheme =
        ExtraTheme.of(context).messageColorScheme(contactUid.asString());

    return HeroMode(
      enabled: isHeroEnabled,
      child: Hero(
        tag: contactUid.asString(),
        child: Container(
          key: isWeb ? null : _globalKey,
          width: radius * 2,
          height: radius * 2,
          clipBehavior: Clip.hardEdge,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: scheme.primary),
          child: getImageWidget(contactUid, scheme.onPrimary),
        ),
      ),
    );
  }

  Widget getImageWidget(Uid uid, Color textColor) {
    if (uid.category == Categories.SYSTEM) {
      return const Image(
        image: AssetImage('assets/images/logo.png'),
      );
    } else if (isSavedMessage()) {
      return Icon(
        CupertinoIcons.bookmark,
        size: radius,
        color: textColor,
      );
    } else {
      return StreamBuilder<String?>(
          key: _streamKey,
          initialData: _avatarRepo.fastForwardAvatarFilePath(contactUid),
          stream: _avatarRepo.getLastAvatarFilePathStream(contactUid, false),
          builder: (context, snapshot) =>
              builder(context, snapshot, textColor));
    }
  }

  Widget builder(
      BuildContext context, AsyncSnapshot<String?> snapshot, Color textColor) {
    if (snapshot.hasData) {
      return isWeb
          ? Image.network(snapshot.data!, fit: BoxFit.fill)
          : Image.file(
              File(snapshot.data!),
              fit: BoxFit.cover,
            );
    } else {
      return showDisplayName(textColor);
    }
  }

  Widget showDisplayName(Color textColor) {
    if (forceText.isNotEmpty) {
      return avatarAlt(forceText.trim(), textColor);
    }
    return DefaultTextStyle(
      style: TextStyle(color: textColor, fontSize: radius, height: 1),
      child: FutureBuilder<String>(
        initialData: _roomRepo.fastForwardName(contactUid),
        future: _roomRepo.getName(contactUid),
        key: _futureKey,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.data != null) {
            final name = snapshot.data!.trim();
            return avatarAlt(name.trim(), textColor);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget avatarAlt(String name, Color textColor) {
    if (hideName) {
      return const SizedBox.shrink();
    }
    return Center(
        child: Text(
      name.length > 1 ? name.substring(0, 1).toUpperCase() : name.toUpperCase(),
      maxLines: 1,
      style: TextStyle(color: textColor, fontSize: radius, height: 1),
    ));
  }
}
