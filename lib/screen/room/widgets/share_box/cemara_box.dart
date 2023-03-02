import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/screen/room/widgets/share_box/video_viewer_page.dart';
import 'package:deliver/services/camera_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/colors.dart';
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
    final theme = Theme.of(context);

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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 100,
                    child: BlurContainer(
                      skew: 10,
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
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Expanded(
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 24.0,
              ),
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: getEnableBackgroundColor(
                      isEnable: _cameraService.enableAudio(),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await _cameraService.changeRecordAudioState();
                        setState(() {});
                      },
                      icon: getEnableIcon(
                        isEnable: _cameraService.enableAudio(),
                        enableIcon: CupertinoIcons.volume_up,
                        disableIcon: CupertinoIcons.volume_mute,
                        size: 25,
                      ),
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: _cameraService.getDuration(),
                    builder: (context, snapshot) {
                      final isRecording = (snapshot.data ?? 0) > 0;
                      return GestureDetector(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: ANIMATION_DURATION,
                              height: isRecording ? 85 : 75,
                              width: isRecording ? 85 : 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isRecording ? Colors.red : Colors.white,
                                  width: 6,
                                ),
                                color: isRecording
                                    ? Colors.red
                                    : Colors.transparent,
                              ),
                            ),
                            if (!widget.selectAsAvatar) ...[
                              const SizedBox(height: 12),
                              DefaultTextStyle(
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: isRecording ? 0 : null,
                                  color:
                                      isRecording ? Colors.transparent : null,
                                ),
                                child: Text(
                                  _i18n.get("take_picture_and_video_helper"),
                                ),
                              ),
                            ],
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
                        onLongPressEnd: (d) => !widget.selectAsAvatar
                            ? _onRouteToVideoViewer()
                            : null,
                      );
                    },
                  ),
                  if (_cameraService.hasMultiCamera())
                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          getEnableBackgroundColor(isEnable: false),
                      child: IconButton(
                        onPressed: () => _cameraService.switchToAnotherCamera(),
                        icon: const Icon(
                          CupertinoIcons.camera_rotate,
                        ),
                        color: getEnableColor(isEnable: false),
                        iconSize: 25,
                      ),
                    )
                  else
                    const SizedBox(
                      width: 50,
                      height: 50,
                    )
                ],
              ),
            ),
          ),
        ),
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
