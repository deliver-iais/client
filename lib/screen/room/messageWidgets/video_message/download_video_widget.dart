import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

// TODO(hasan): Migrate from Download*Widget to LoadFileStatus instead of this if it is possible, https://gitlab.iais.co/deliver/wiki/-/issues/434
class DownloadVideoWidget extends StatefulWidget {
  final String uuid;
  final String name;
  final void Function() download;
  final Color background;
  final Color foreground;

  const DownloadVideoWidget({
    Key? key,
    required this.uuid,
    required this.download,
    required this.name,
    required this.background,
    required this.foreground,
  }) : super(key: key);

  @override
  _DownloadVideoWidgetState createState() => _DownloadVideoWidgetState();
}

class _DownloadVideoWidgetState extends State<DownloadVideoWidget> {
  final _fileServices = GetIt.I.get<FileService>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final BehaviorSubject<bool> _startDownload = BehaviorSubject.seeded(false);
  final _futureKey = GlobalKey();
  final _streamKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      key: _futureKey,
      future: _fileRepo.getFile(
        widget.uuid,
        widget.name + ".png",
        thumbnailSize: ThumbnailSize.small,
      ),
      builder: (c, thumbnail) {
        if (thumbnail.hasData && thumbnail.data != null) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.file(File(thumbnail.data!)).image,
                fit: BoxFit.cover,
              ),
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(child: buildStreamBuilder()),
          );
        } else {
          return Center(
            child: buildStreamBuilder(),
          );
        }
      },
    );
  }

  Widget buildStreamBuilder() {
    return StreamBuilder<double>(
      key: _streamKey,
      stream: _fileServices.filesProgressBarStatus[widget.uuid],
      builder: (c, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data! > 0 &&
            snapshot.data! <= 1) {
          return Container(
            decoration:
                BoxDecoration(color: widget.background, shape: BoxShape.circle),
            child: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 4.0,
              backgroundColor: widget.background,
              progressColor: widget.foreground,
              percent: snapshot.data!,
              center: StreamBuilder<CancelToken?>(
                stream: _fileServices.cancelTokens[widget.uuid],
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
                          _fileServices.cancelTokens[widget.uuid]!.add(null);
                          _startDownload.add(false);
                          s.data!.cancel();
                        },
                      ),
                    );
                  } else {
                    return StreamBuilder<bool>(
                      stream: _startDownload.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!) {
                          return CircularProgressIndicator(
                            color: widget.background,
                          );
                        } else {
                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                _startDownload.add(true);
                                widget.download();
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
            ),
          );
        } else {
          return Container(
            height: 50,
            width: 50,
            decoration:
                BoxDecoration(color: widget.background, shape: BoxShape.circle),
            child: StreamBuilder<bool>(
              stream: _startDownload.stream,
              builder: (context, start) {
                if (start.hasData && start.data != null && start.data!) {
                  return const CircularProgressIndicator();
                } else {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        _startDownload.add(true);
                        widget.download();
                      },
                      child: Icon(
                        Icons.arrow_downward,
                        size: 35,
                        color: widget.foreground,
                      ),
                    ),
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
