import 'dart:ui';

import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileBlurAvatar extends StatelessWidget {
  final AvatarRepo _avatarRepo = GetIt.I.get<AvatarRepo>();
  final RoomRepo _roomRepo = GetIt.I.get<RoomRepo>();
  late final Uid roomUid;
  final bool hasShaderMaskOver;
  final List<double> shaderMaskStops;
  final double coverOpacity;
  final double blurSigma;

  ProfileBlurAvatar(
    this.roomUid, {
    super.key,
    this.hasShaderMaskOver = true,
    this.shaderMaskStops = const [0.4, 0.95],
    this.coverOpacity = 0.6,
    this.blurSigma = 17.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<String?>(
      key: GlobalKey(),
      initialData: _avatarRepo.fastForwardAvatarFilePath(roomUid),
      stream: _avatarRepo.getLastAvatarFilePathStream(
        roomUid,
        forceToUpdate: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final image = Image(
            image: snapshot.data!.imageProvider(),
            fit: BoxFit.cover,
          );
          return ShaderMask(
            blendMode: BlendMode.srcOver,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              stops: shaderMaskStops,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.background.withOpacity(0),
                if (hasShaderMaskOver) theme.colorScheme.background
              ],
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                theme.colorScheme.background.withOpacity(coverOpacity),
                BlendMode.srcOver,
              ),
              child: ImageFiltered(
                imageFilter:
                    ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: image,
              ),
            ),
          );

          // if(image.height == image.width){
          //   image.fit =
          // }
        } else {
          return ShaderMask(
            blendMode: BlendMode.srcOver,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              stops: shaderMaskStops,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.background.withOpacity(0),
                if (hasShaderMaskOver) theme.colorScheme.background
              ],
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                theme.colorScheme.background.withOpacity(coverOpacity + 0.1),
                BlendMode.srcOver,
              ),
              child: ImageFiltered(
                imageFilter:
                    ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: ExtraTheme.of(context)
                      .messageColorScheme(roomUid)
                      .onPrimaryContainer,
                  // color: Colors.orange,
                ),
              ),
            ),
          );
          // return showDisplayName(textColor);
        }
      },
    );
  }

  Widget showDisplayName(Color textColor) {
    return DefaultTextStyle(
      style: TextStyle(color: textColor, fontSize: 16, height: 1),
      child: FutureBuilder<String>(
        initialData: _roomRepo.fastForwardName(roomUid),
        future: _roomRepo.getName(roomUid),
        key: GlobalKey(),
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
    return Center(
      child: Text(
        name.length > 1
            ? name.substring(0, 1).toUpperCase()
            : name.toUpperCase(),
        maxLines: 1,
        style: TextStyle(color: textColor, fontSize: 16, height: 1),
      ),
    );
  }
}
