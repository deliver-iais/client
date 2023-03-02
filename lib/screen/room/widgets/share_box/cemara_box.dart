import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/screen/room/widgets/share_box/video_viewer_page.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/shared/methods/format_duration.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CameraBox extends StatefulWidget {
  final Uid roomUid;
  final Function(String)? onAvatarSelected;
  final bool selectAsAvatar;

  const CameraBox({
    super.key,
    required this.roomUid,
    this.onAvatarSelected,
    this.selectAsAvatar = false,
  });

  @override
  State<CameraBox> createState() => _CameraBoxState();
}

class _CameraBoxState extends State<CameraBox> {
  final _cameraService = GetIt.I.get<CameraService>();
  final _i18n = GetIt.I.get<I18N>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<bool>(
          stream: _cameraService.onCameraChanged(),
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
                child: SizedBox(
                  width: 100,
                  child: BlurContainer(
                    skew: 4,
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
                            formatDuration(Duration(seconds: duration.data!)),
                          ),
                        ),
                      ],
                    ),
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
                    size: 80,
                  ),
                  if (!widget.selectAsAvatar)
                    DefaultTextStyle(
                      style: const TextStyle(decoration: TextDecoration.none),
                      child: Text(
                        _i18n.get("take_picture_and_video_helper"),
                      ),
                    ),
                ],
              ),
              onTap: () => _cameraService.takePicture().then((file) {
                if (widget.selectAsAvatar) {
                  Navigator.pop(context);
                  widget.onAvatarSelected!(file.path);
                } else {
                  openImage(file);
                }
              }),
              onLongPressStart: (_) => !widget.selectAsAvatar
                  ? _cameraService.startVideoRecorder()
                  : null,
              onLongPressEnd: (d) =>
                  !widget.selectAsAvatar ? _onRouteToVideoViewer() : null,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 10),
            child: IconButton(
              onPressed: () async {
                await _cameraService.changeRecordAudioState();
                setState(() {});
              },
              icon: Icon(
                _cameraService.enableAudio()
                    ? CupertinoIcons.volume_mute
                    : CupertinoIcons.volume_up,
              ),
              color: Colors.white70,
              iconSize: 35,
            ),
          ),
        ),
        if (_cameraService.hasMultiCamera())
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

  void _sendMessage(File file, String caption) {
    Navigator.pop(context);
    _messageRepo.sendFileMessage(widget.roomUid, file, caption: caption);
  }

  void _onRouteToVideoViewer() {
    _cameraService.stopVideoRecorder().then(
          (file) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => VideoViewerPage(
                file: file,
                onSend: (caption) => _sendMessage(file, caption),
              ),
            ),
          ),
        );
  }

  void openImage(File file) {
    var imagePath = file.path;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return OpenImagePage(
            forceToShowCaptionTextField: true,
            send: (caption) => _sendMessage(file, caption),
            onEditEnd: (path) {
              imagePath = path;
              if (widget.selectAsAvatar) {
                widget.onAvatarSelected!(imagePath);
              }
              Navigator.pop(context);
            },
            imagePath: imagePath,
          );
        },
      ),
    );
  }
}
