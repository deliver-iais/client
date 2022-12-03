import 'dart:io';
import 'dart:ui';

import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileBlurAvatar extends StatelessWidget {
  final AvatarRepo _avatarRepo = GetIt.I.get<AvatarRepo>();
  late final Uid roomUid;
  bool hasShaderMaskOver = true;
  final List<double> shaderMaskStops;
  final double coverOpacity;
  final double blurSigma;

  ProfileBlurAvatar(this.roomUid, {this.hasShaderMaskOver : true, this.shaderMaskStops : const [0.4, 0.95],
      this.coverOpacity : 0.6, this.blurSigma : 17.0});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return StreamBuilder<String?>(
      key: GlobalKey(),
      initialData: _avatarRepo
          .fastForwardAvatarFilePath(roomUid),
      stream: _avatarRepo.getLastAvatarFilePathStream(
        roomUid,
        forceToUpdate: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          final image = isWeb
              ? Image.network(snapshot.data!,
              fit: BoxFit.cover)
              : Image.file(
            File(snapshot.data!),
            fit: BoxFit.cover,
            // scale: 0.001,
          );
          return ShaderMask(
            blendMode: BlendMode.srcOver,
            shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                stops: shaderMaskStops,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.background
                      .withOpacity(0),
                  if(hasShaderMaskOver) theme.colorScheme.background
                ]).createShader(
              Rect.fromLTWH(
                  0, 0, bounds.width, bounds.height),
            ),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                  theme.colorScheme.background
                      .withOpacity(coverOpacity),
                  BlendMode.srcOver),
              child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                      sigmaX: blurSigma, sigmaY: blurSigma),
                  child: image),
            ),
          );

          // if(image.height == image.width){
          //   image.fit =
          // }
        } else {
          // TODO : fix this one
          return FlutterLogo();
          // return showDisplayName(textColor);
        }
      },
    );
  }

}