import 'dart:async';
import 'dart:math';

import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/broadcast_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircleAvatarWidget extends StatefulWidget {
  final Uid uid;
  final double radius;
  final String forceText;
  final bool showSavedMessageLogoIfNeeded;
  final bool hideName;
  final bool isHeroEnabled;
  final bool forceToUpdateAvatar;
  final Widget? noAvatarWidget;
  final BorderRadius? borderRadius;

  const CircleAvatarWidget(
    this.uid,
    this.radius, {
    super.key,
    this.borderRadius,
    this.forceText = "",
    this.hideName = false,
    this.isHeroEnabled = true,
    this.showSavedMessageLogoIfNeeded = false,
    this.forceToUpdateAvatar = false,
    this.noAvatarWidget,
  });

  @override
  State<CircleAvatarWidget> createState() => _CircleAvatarWidgetState();
}

class _CircleAvatarWidgetState extends State<CircleAvatarWidget> {
  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _broadcastService = GetIt.I.get<BroadcastService>();

  Uid get uid => widget.uid;

  final _streamKey = GlobalKey();

  final _futureKey = GlobalKey();

  late final Future<List<Uid>?> broadcastUsersFuture;

  late final Future<String> nameFuture;

  late final Stream<String?> lastAvatarFilePathStream;

  late final _globalKey = GlobalObjectKey(uid.asString());

  bool isSavedMessage() =>
      widget.showSavedMessageLogoIfNeeded && _authRepo.isCurrentUser(uid);

  bool isSystem() => uid.category == Categories.SYSTEM;

  bool isBroadcast() => uid.category == Categories.BROADCAST;

  @override
  void initState() {
    if (uid.isBroadcast()) {
      broadcastUsersFuture = _broadcastService.getFirstPageOfBroadcastMembers(uid);
    }

    if (!isSystem() &&
        !isSavedMessage() &&
        !isBroadcast() &&
        settings.showAvatarImages.value) {
      lastAvatarFilePathStream = _avatarRepo.getLastAvatarFilePathStream(
        uid,
        forceToUpdate: widget.forceToUpdateAvatar,
      );
    }

    nameFuture = _roomRepo.getName(uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ExtraTheme.of(context).messageColorScheme(uid);

    var boxDecoration = BoxDecoration(
      shape: BoxShape.circle,
      color: isBroadcast() ? null : scheme.primary,
    );

    if (widget.borderRadius != null) {
      boxDecoration = BoxDecoration(
        borderRadius: widget.borderRadius,
        color: scheme.primary,
      );
    }
    final imageContainer = Container(
      key: isWeb ? null : _globalKey,
      width: widget.radius * 2,
      height: widget.radius * 2,
      clipBehavior: Clip.hardEdge,
      decoration: boxDecoration,
      child: getImageWidget(scheme.onPrimary, context),
    );
    return widget.isHeroEnabled
        ? HeroMode(
            enabled: settings.showAnimations.value,
            child: Hero(tag: uid.asString(), child: imageContainer),
          )
        : imageContainer;
  }

  Widget getImageWidget(Color textColor, BuildContext context) {
    if (isSystem()) {
      return const Image(
        image: AssetImage('assets/images/logo.webp'),
      );
    } else if (isSavedMessage()) {
      return Icon(
        CupertinoIcons.bookmark,
        size: widget.radius,
        color: textColor,
      );
    } else if (isBroadcast()) {
      return buildBroadcastAvatar(context);
    } else {
      if (!settings.showAvatarImages.value) {
        return showAvatarAlternative(textColor);
      }

      return StreamBuilder<String?>(
        key: _streamKey,
        initialData: _avatarRepo.fastForwardAvatarFilePath(uid),
        stream: lastAvatarFilePathStream,
        builder: (context, snapshot) => builder(context, snapshot, textColor),
      );
    }
  }

  Widget builder(
    BuildContext context,
    AsyncSnapshot<String?> snapshot,
    Color textColor,
  ) {
    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
      final imgP = snapshot.data!.imageProvider();

      final image = Image(image: imgP, fit: BoxFit.cover);

      final completer = Completer<ImageInfo>();
      imgP.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete(info);
          }
        }),
      );

      return FutureBuilder<ImageInfo>(
        future: completer.future,
        builder: (context, snapshot2) {
          if (snapshot2.hasData &&
              ((snapshot2.data!.image.height - snapshot2.data!.image.width)
                      .abs() <=
                  3)) {
            return Image(image: imgP, fit: BoxFit.scaleDown);
          } else {
            return image;
          }
        },
      );
    } else {
      return showAvatarAlternative(textColor);
    }
  }

  Widget showAvatarAlternative(Color textColor) =>
      widget.noAvatarWidget ?? showDisplayName(textColor);

  Widget showDisplayName(Color textColor) {
    if (widget.forceText.isNotEmpty) {
      return avatarAlt(widget.forceText.trim(), textColor);
    }
    return DefaultTextStyle(
      style: TextStyle(color: textColor, fontSize: widget.radius, height: 1),
      child: FutureBuilder<String>(
        initialData: _roomRepo.fastForwardName(uid),
        future: nameFuture,
        key: _futureKey,
        builder: (context, snapshot) {
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
    if (widget.hideName) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Text(
        name.length > 1
            ? name.substring(0, 1).toUpperCase()
            : name.toUpperCase(),
        maxLines: 1,
        style: TextStyle(color: textColor, fontSize: widget.radius, height: 1),
      ),
    );
  }

  Widget buildBroadcastAvatar(BuildContext buildContext) {
    return FutureBuilder<List<Uid>?>(
      future: broadcastUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final recipientUidList = snapshot.data!;
          final avatarCount =
              recipientUidList.length > 4 ? 4 : recipientUidList.length;
          final avatarSize =
              (widget.radius * (avatarCount + 1 / (avatarCount * 2))) /
                  avatarCount;
          return SizedBox(
            height: widget.radius * 2,
            width: widget.radius * 2,
            child: Stack(
              children: List.generate(avatarCount, (index) {
                final angle = (2 * pi * index) / avatarCount;
                final dx = (widget.radius - avatarSize / 2) * (1 + cos(angle));
                final dy = (widget.radius - avatarSize / 2) * (1 - sin(angle));

                return Positioned(
                  left: dx,
                  top: dy,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CircleAvatarWidget(
                      recipientUidList[index],
                      20,
                      isHeroEnabled: false,
                    ),
                  ),
                );
              }),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
