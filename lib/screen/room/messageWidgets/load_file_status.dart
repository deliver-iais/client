import 'dart:math';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

class LoadFileStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final Color background;
  final bool isPendingMessage;
  final Color foreground;
  final String?
      messagePacketId; // TODO(hasan): Revise this field usage, https://gitlab.iais.co/deliver/wiki/-/issues/434
  final void Function() onPressed;

  const LoadFileStatus({
    Key? key,
    required this.fileId,
    required this.fileName,
    required this.onPressed,
    required this.background,
    required this.isPendingMessage,
    required this.foreground,
    this.messagePacketId,
  }) : super(key: key);

  @override
  LoadFileStatusState createState() => LoadFileStatusState();
}

class LoadFileStatusState extends State<LoadFileStatus> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _fileService = GetIt.I.get<FileService>();
  final BehaviorSubject<bool> _starDownload = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _fileService.initProgressBar(widget.fileId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: widget.background),
      child: widget.isPendingMessage ? buildUpload() : buildDownload(),
    );
  }

  Widget buildUpload() {
    return StreamBuilder<double?>(
      stream: _fileService.filesProgressBarStatus[widget.fileId],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! > 0) {
          return CircularPercentIndicator(
            radius: 45.0,
            lineWidth: 4.0,
            center: StreamBuilder<CancelToken?>(
              stream: _fileService.cancelTokens[widget.fileId],
              builder: (c, s) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: const Icon(
                      Icons.close,
                      size: 35,
                    ),
                    onTap: () {
                      if (s.hasData && s.data != null) {
                        s.data!.cancel();
                      }
                      _messageRepo
                          .deletePendingMessage(widget.messagePacketId!);
                    },
                  ),
                );
              },
            ),
            percent: snapshot.data!,
            backgroundColor: widget.background,
            progressColor: widget.foreground,
          );
        } else {
          return Stack(
            children: [
              const Center(
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Center(
                  child: GestureDetector(
                    child: const Icon(
                      Icons.close,
                      size: 36,
                    ),
                    onTap: () {
                      _messageRepo
                          .deletePendingMessage(widget.messagePacketId!);
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget buildDownload() {
    return StreamBuilder<double>(
      stream: _fileService.filesProgressBarStatus[widget.fileId],
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data! > 0) {
          return CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 4.0,
            percent: min(snapshot.data!, 1.0),
            backgroundColor: widget.background,
            progressColor: widget.foreground,
            center: StreamBuilder<CancelToken?>(
              stream: _fileService.cancelTokens[widget.fileId],
              builder: (c, s) {
                if (s.hasData && s.data != null) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: widget.foreground,
                        size: 35,
                      ),
                      onTap: () {
                        _starDownload.add(false);
                        s.data!.cancel();
                        _fileService.cancelTokens[widget.fileId]!.add(null);
                      },
                    ),
                  );
                } else {
                  return StreamBuilder<bool>(
                    stream: _starDownload.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!) {
                        return CircularProgressIndicator(
                          color: widget.foreground,
                        );
                      } else {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              _starDownload.add(true);
                              widget.onPressed();
                            },
                            child: Icon(
                              Icons.arrow_downward,
                              color: widget.foreground,
                              size: 35,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          );
        } else {
          return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.background,
            ),
            child: StreamBuilder<bool>(
              stream: _starDownload.stream,
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
}
