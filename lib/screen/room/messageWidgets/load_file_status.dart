import 'dart:math';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LoadFileStatus extends StatefulWidget {
  final file_pb.File file;
  final Color background;
  final bool isUploading;
  final Color foreground;

  final void Function(String?)? onDownloadCompleted;
  final void Function()? onCanceled;
  final void Function()? onResendFile;

  final bool sendingFileFailed;
  final bool isPendingForwarded;
  final bool showDetails;
  final double widgetSize;

  const LoadFileStatus({
    super.key,
    required this.file,
    required this.background,
    required this.foreground,
    required this.isUploading,
    this.onCanceled,
    this.onDownloadCompleted,
    this.onResendFile,
    this.sendingFileFailed = false,
    this.isPendingForwarded = false,
    this.showDetails = false,
    this.widgetSize = 50.0,
  });

  @override
  LoadFileStatusState createState() => LoadFileStatusState();
}

class LoadFileStatusState extends State<LoadFileStatus>
    with SingleTickerProviderStateMixin {
  static final _fileService = GetIt.I.get<FileService>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  final GlobalKey _key = GlobalKey();

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

  double get iconSize => widget.widgetSize * 0.6;

  double get padding => widget.widgetSize * 0.04;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      decoration: BoxDecoration(
        borderRadius: widget.showDetails ? secondaryBorder : mainBorder,
        color: widget.background,
      ),
      width: widget.showDetails ? null : widget.widgetSize,
      height: widget.showDetails ? null : widget.widgetSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isUploading) buildUpload() else buildDownload(),
          if (widget.showDetails)
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<Map<String, double>>(
                    initialData: const {},
                    stream: _fileService.filesProgressBarStatus.stream,
                    builder: (c, map) {
                      final progress = map.data![widget.file.uuid] ?? 0;
                      return _buildText(
                        progress > 0
                            ? "${byteFormat((progress * widget.file.size.toInt()).toInt())} / ${byteFormat(widget.file.size.toInt())}"
                            : byteFormat(widget.file.size.toInt()),
                        context,
                      );
                    },
                  ),
                  if (widget.file.duration > 0)
                    _buildText(
                      Duration(seconds: widget.file.duration.toInt())
                          .toString()
                          .substring(0, 7),
                      context,
                    )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildText(String text, BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: widget.foreground,
      ),
    );
  }

  Widget buildUpload() {
    return StreamBuilder<Map<String, FileStatus>>(
      stream: _fileService.watchFileStatus(),
      builder: (c, fileStatus) {
        Widget child = const SizedBox.shrink();
        if (fileStatus.hasData &&
            fileStatus.data != null &&
            fileStatus.data![widget.file.uuid] == FileStatus.STARTED) {
          child = buildFileStatus();
        } else if (widget.sendingFileFailed || widget.isPendingForwarded) {
          child = IconButton(
            padding: const EdgeInsets.all(0),
            icon: Icon(
              Icons.arrow_upward,
              color: widget.foreground,
              size: 35,
            ),
            onPressed: () => widget.onResendFile?.call(),
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
    return SizedBox(
      width: widget.widgetSize,
      height: widget.widgetSize,
      child: StreamBuilder<Map<String, FileStatus>>(
        stream: _fileService.watchFileStatus(),
        builder: (context, snapshot) {
          Widget child = const SizedBox();
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data![widget.file.uuid] == FileStatus.STARTED) {
            child = buildFileStatus();
          } else {
            child = IconButton(
              padding: const EdgeInsets.all(0),
              icon: Icon(
                Icons.arrow_downward,
                color: widget.foreground,
                size: iconSize,
              ),
              onPressed: onDownload,
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
    return SizedBox(
      width: widget.widgetSize,
      height: widget.widgetSize,
      child: StreamBuilder<Map<String, double>>(
        initialData: const {},
        stream: _fileService.filesProgressBarStatus,
        builder: (c, map) {
          final double progress =
              max(min(map.data![widget.file.uuid] ?? 0, 1), 0.0001);
          return Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: CircularPercentIndicator(
                      radius: (widget.widgetSize / 2) - padding,
                      lineWidth: padding * 2,
                      circularStrokeCap: CircularStrokeCap.round,
                      percent:
                          widget.isUploading ? min(progress, 0.96) : progress,
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
                    onTap: onCancel,
                    child: Icon(
                      Icons.close,
                      color: widget.foreground,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> onDownload() async {
    final path = await _fileRepo.getFile(
      widget.file.uuid,
      widget.file.name,
      showAlertOnError: true,
    );

    widget.onDownloadCompleted?.call(path);
  }

  Future<void> onCancel() async {
    widget.onCanceled?.call();
    _fileRepo.cancelUploadFile(widget.file.uuid);
  }
}
