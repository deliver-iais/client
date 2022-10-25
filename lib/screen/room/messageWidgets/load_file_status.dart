import 'dart:math';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

const LOADING_INDICATOR_WIDGET_SIZE = 50.0;
const LOADING_INDICATOR_PADDING = 2.0;

class LoadFileStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final Color background;
  final bool isPendingMessage;
  final Color foreground;
  final String? messagePacketId;
  final void Function() onPressed;

  const LoadFileStatus({
    super.key,
    required this.fileId,
    required this.fileName,
    required this.onPressed,
    required this.background,
    required this.isPendingMessage,
    required this.foreground,
    this.messagePacketId,
  });

  @override
  LoadFileStatusState createState() => LoadFileStatusState();
}

class LoadFileStatusState extends State<LoadFileStatus>
    with SingleTickerProviderStateMixin {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _fileService = GetIt.I.get<FileService>();
  final BehaviorSubject<bool> _starDownload = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _fileService.initProgressBar(widget.fileId);
    _starDownload
        .add(_fileService.fileStatus[widget.fileId] == FileStatus.STARTED);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LOADING_INDICATOR_WIDGET_SIZE,
      height: LOADING_INDICATOR_WIDGET_SIZE,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: widget.background),
      child: widget.isPendingMessage ? buildUpload() : buildDownload(),
    );
  }

  Widget buildUpload() {
    return buildFileStatus();
  }

  Widget buildDownload() {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _starDownload.stream,
      builder: (c, start) {
        if (start.data!) {
          return buildFileStatus();
        } else {
          return Container(
            width: LOADING_INDICATOR_WIDGET_SIZE,
            height: LOADING_INDICATOR_WIDGET_SIZE,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.background,
            ),
            child: StreamBuilder<bool>(
              stream: _starDownload,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!) {
                  return CircularProgressIndicator(
                    color: widget.foreground,
                  );
                } else {
                  return IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Icon(
                      Icons.arrow_downward,
                      color: widget.foreground,
                      size: 35,
                    ),
                    onPressed: () {
                      _starDownload.add(true);
                      widget.onPressed();
                    },
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  Widget buildFileStatus() {
    return StreamBuilder<Map<String, double>>(
      stream: _fileService.filesProgressBarStatus,
      builder: (c, map) {
        final progress = map.data![widget.fileId] ?? 0;
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(LOADING_INDICATOR_PADDING),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * pi,
                    child: child,
                  );
                },
                child: CircularPercentIndicator(
                  radius: (LOADING_INDICATOR_WIDGET_SIZE / 2) -
                      LOADING_INDICATOR_PADDING,
                  lineWidth: 4.0,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: max(min(progress ?? 0, 1), 0.0001),
                  backgroundColor: widget.background,
                  progressColor: widget.foreground,
                ),
              ),
            ),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  child: Icon(
                    Icons.close,
                    color: widget.foreground,
                    size: 35,
                  ),
                  onTap: () {
                    if (widget.isPendingMessage) {
                      _messageRepo
                          .deletePendingMessage(widget.messagePacketId!);
                    } else {
                      _starDownload.add(false);
                    }

                    _fileService.cancelUploadOrDownloadFile(widget.fileId);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
