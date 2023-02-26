import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/crop_screen.dart';
import 'package:deliver/screen/room/widgets/share_box/share_box_input_caption.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({
    super.key,
    required this.path,
    required this.roomUid,
  });

  final String path;
  final Uid roomUid;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final _i18n = GetIt.I.get<I18N>();
  final double height = 60;
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final Trimmer _trimmer = Trimmer();
  await _trimmer.loadVideo(videoFile: file);

  TextEditingController textController = TextEditingController();

  late final VideoEditorController _controller = VideoEditorController.file(
    File(widget.path),
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError(
      (error) {
        Navigator.pop(context);
      },
      test: (e) => e is VideoMinDurationError,
    );
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.initialized
        ? Scaffold(
            appBar: AppBar(
              leading: _routingService.backButtonLeading(),
              actions: _actions(),
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                CropGridViewer.preview(
                  controller: _controller,
                ),
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(seconds: 10),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState: (value) =>
                      setState(() => _isPlaying = value),
                ),
                Center(
                  child: AnimatedBuilder(
                    animation: _controller.video,
                    builder: (_, __) => GestureDetector(
                      onTap: _controller.video.play,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 10,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: _trimSlider(),
                        ),
                        ShareBoxInputCaption(
                          captionEditingController: textController,
                          send: () {
                            _controller.exportVideo(
                              onCompleted: (file) {
                                print("==========");
                                _messageRepo.sendFileMessage(
                                  widget.roomUid,
                                  pathToFileModel(file.path),
                                  caption: textController.text,
                                );
                                Navigator.pop(context);
                              },onError: (_,__){
                                print("eroroororoo");

                            }
                            );
                          },
                          count: 0,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }

  List<Widget> _actions() {
    return [
      IconButton(
        onPressed: () => _controller.rotate90Degrees(RotateDirection.left),
        icon: const Icon(Icons.rotate_left),
        tooltip: _i18n.get("rotate_left"),
      ),
      IconButton(
        onPressed: () => _controller.rotate90Degrees(),
        icon: const Icon(Icons.rotate_right),
        tooltip: _i18n.get("rotate_right"),
      ),
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => CropScreen(controller: _controller),
          ),
        ),
        icon: const Icon(Icons.crop),
        tooltip: _i18n.get("crop"),
      ),
    ];
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final duration = _controller.videoDuration.inSeconds;
          final pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(
              children: [
                Text(formatter(Duration(seconds: pos.toInt()))),
                const Expanded(child: SizedBox()),
                if (_controller.isTrimmed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatter(_controller.startTrim)),
                      const SizedBox(width: 10),
                      Text(formatter(_controller.endTrim)),
                    ],
                  )
              ],
            ),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }
}
