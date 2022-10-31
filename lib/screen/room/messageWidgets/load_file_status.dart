import 'dart:math';

import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

const LOADING_INDICATOR_WIDGET_SIZE = 50.0;
const LOADING_INDICATOR_PADDING = 2.0;

class LoadFileStatus extends StatefulWidget {
  final String uuid;
  final String name;
  final Color background;
  final bool isPendingMessage;
  final Color foreground;
  final void Function()? onDownload;
  final void Function()? onCancel;
  final bool sendingFileFailed;
  final bool isPendingForwarded;
  final void Function()? resendFileMessage;

  const LoadFileStatus({
    super.key,
    required this.uuid,
    required this.name,
    required this.onDownload,
    required this.background,
    required this.isPendingMessage,
    required this.foreground,
    this.onCancel,
    this.sendingFileFailed = false,
    this.isPendingForwarded = false,
    this.resendFileMessage,
  });

  @override
  LoadFileStatusState createState() => LoadFileStatusState();
}

class LoadFileStatusState extends State<LoadFileStatus>
    with SingleTickerProviderStateMixin {
  static final _fileService = GetIt.I.get<FileService>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _scaffoldKey,
      width: LOADING_INDICATOR_WIDGET_SIZE,
      height: LOADING_INDICATOR_WIDGET_SIZE,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: widget.background),
      child: widget.isPendingMessage ? buildUpload() : buildDownload(),
    );
  }

  Widget buildUpload() {
    return StreamBuilder<Map<String, FileStatus>>(
      stream: _fileService.watchFileStatus(),
      builder: (c, fileStatus) {
        Widget child = const SizedBox.shrink();
        if (fileStatus.hasData &&
            fileStatus.data != null &&
            fileStatus.data![widget.uuid] == FileStatus.STARTED) {
          child = buildFileStatus();
        } else if (widget.sendingFileFailed || widget.isPendingForwarded) {
          child = IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(
              Icons.arrow_upward,
              color: widget.foreground,
              size: 35,
            ),
            onPressed: () => widget.resendFileMessage?.call(),
          );
        } else {
          child = buildFileStatus();
        }
        return AnimatedSwitcher(
          duration: VERY_SLOW_ANIMATION_DURATION,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: child,
        );
      },
    );
  }

  Widget buildDownload() {
    return Container(
      width: LOADING_INDICATOR_WIDGET_SIZE,
      height: LOADING_INDICATOR_WIDGET_SIZE,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.background,
      ),
      child: StreamBuilder<Map<String, FileStatus>>(
        stream: _fileService.watchFileStatus(),
        builder: (context, snapshot) {
          Widget child = const SizedBox();
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data![widget.uuid] == FileStatus.STARTED) {
            child = buildFileStatus();
          } else {
            child = IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(
                Icons.arrow_downward,
                color: widget.foreground,
                size: 35,
              ),
              onPressed: () => widget.onDownload?.call(),
            );
          }
          return AnimatedSwitcher(
            duration: VERY_SLOW_ANIMATION_DURATION,
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: child,
          );
        },
      ),
    );
  }

  Widget buildFileStatus() {
    return StreamBuilder<Map<String, double>>(
      initialData: const {},
      stream: _fileService.filesProgressBarStatus,
      builder: (c, map) {
        final progress = map.data![widget.uuid] ?? 0;
        return Stack(
          children: [
            Center(
              child: Padding(
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
                    percent: max(min(progress, 1), 0.0001),
                    backgroundColor: widget.background,
                    progressColor: widget.foreground,
                  ),
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
                    widget.onCancel?.call();
                    _fileService.cancelUploadOrDownloadFile(widget.uuid);
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
