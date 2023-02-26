import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/share_box/video_editor.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CameraBox extends StatefulWidget {
  final Uid roomUid;

  const CameraBox({super.key, required this.roomUid});

  @override
  State<CameraBox> createState() => _CameraBoxState();
}

class _CameraBoxState extends State<CameraBox> {
  final _cameraService = GetIt.I.get<CameraService>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<bool>(
          stream: _cameraService.changeCamera(),
          builder: (context, snapshot) {
            var scale = MediaQuery.of(context).size.aspectRatio *
                _cameraService.getAspectRatio();
            if (scale < 1) scale = 1 / scale;
            return Center(
              child: Transform.scale(
                scale: scale,
                child: _cameraService.buildPreview(),
              ),
            );
          },
        ),
        StreamBuilder<int>(
          stream: _cameraService.getDuration(),
          builder: (c, duration) {
            if (duration.hasData &&
                duration.data != null &&
                duration.data! > 0) {
              return Align(
                alignment: Alignment.topCenter,
                child: BlurContainer(
                  skew: 4,
                  // padding: const EdgeInsets.only(
                  //     top: 6, bottom: 3, left: 12, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.video_camera,
                        color: Colors.red,
                        size: 40,
                      ),
                      DefaultTextStyle(
                        style: const TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 16,
                        ),
                        child: Text(
                          _getDuration(Duration(seconds: duration.data!)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: GestureDetector(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.circle,
                      color: Colors.white,
                      size: 80,
                    ),
                    DefaultTextStyle(
                      style: const TextStyle(decoration: TextDecoration.none),
                      child: Text(_i18n.get("camera_helper")),
                    ),
                  ],
                ),
                onTap: () {
                  // // final navigatorState = Navigator.of(context);
                  //                   // final file = await _controller!.takePicture();
                  //                   // if (widget.setAvatar != null) {
                  //                   //   widget.pop();
                  //                   //   navigatorState.pop();
                  //                   //   widget.setAvatar!(file.path);
                  //                   // } else {
                  //                   //   openImage(file, pop);
                  //                   // }
                  var file = _cameraService.takePicture();
                },
                onLongPressStart: (f) {
                  _cameraService.startVideoRecorder();
                },
                onLongPressEnd: (d) async {
                  var file = await _cameraService.stopVideoRecorder();
                  unawaited(
                      Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return VideoEditor(
                      path: file.path,
                      roomUid: widget.roomUid,
                    );
                  })));
                },
              )),
        ),
        if (_cameraService.switchToCameraOIsAvailable())
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30, right: 10),
              child: IconButton(
                onPressed: () => _cameraService.switchToAnotherCamera(),
                icon: const Icon(
                  CupertinoIcons.arrow_2_squarepath,
                ),
                color: Colors.white70,
                iconSize: 35,
              ),
            ),
          )
      ],
    );
  }

  String _getDuration(Duration duration) {
    return "${duration.inMinutes < 10 ? "0${duration.inMinutes}" : duration.inMinutes}:${duration.inSeconds < 10 ? "0${duration.inSeconds}" : duration.inSeconds}";
  }
}
