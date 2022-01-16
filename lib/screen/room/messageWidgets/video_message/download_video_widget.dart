import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

class DownloadVideoWidget extends StatefulWidget {
  final String uuid;
  final String name;
  final Function download;

  const DownloadVideoWidget(
      {Key? key,
      required this.uuid,
      required this.download,
      required this.name})
      : super(key: key);

  @override
  _DownloadVideoWidgetState createState() => _DownloadVideoWidgetState();
}

class _DownloadVideoWidgetState extends State<DownloadVideoWidget> {
  final _fileServices = GetIt.I.get<FileService>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final BehaviorSubject<bool> _startDownload = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fileRepo.getFile(widget.uuid, widget.name + ".png",
          thumbnailSize: ThumbnailSize.medium),
      builder: (c, thumbnail) {
        if (thumbnail.hasData && thumbnail.data != null) {
          return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.file(File(thumbnail.data!)).image,
                  fit: BoxFit.cover,
                ),
                color: Colors.black.withOpacity(0.5), //TODO check
              ),
              child: Center(child: buildStreamBuilder()));
        } else {
          return Center(
            child: buildStreamBuilder(),
          );
        }
      },
    );
  }

  Widget buildStreamBuilder() {
    return StreamBuilder<bool>(
      stream: _startDownload.stream,
      builder: (c, start) {
        if (start.hasData && start.data != null && start.data!) {
          return StreamBuilder<double>(
            stream: _fileServices.filesProgressBarStatus[widget.uuid],
            builder: (c, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data! > 0 &&
                  snapshot.data! <= 1) {
                return CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 5.0,
                  backgroundColor: Colors.lightBlue,
                  percent: snapshot.data!,
                  center: StreamBuilder<CancelToken?>(
                    stream: _fileServices.cancelTokens[widget.uuid],
                    builder: (c, s) {
                      if (s.hasData && s.data != null) {
                        return GestureDetector(
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.blue,
                            size: 40,
                          ),
                          onTap: () {
                            if (s.hasData && s.data != null) {
                              _startDownload.add(false);
                              s.data!.cancel();
                            }
                          },
                        );
                      } else {
                        return const CircularProgressIndicator(
                          strokeWidth: 4,
                        );
                      }
                    },
                  ),
                  progressColor: Colors.white,
                );
              } else {
                return const CircularProgressIndicator(
                  strokeWidth: 4,
                );
              }
            },
          );
        } else {
          return MaterialButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _startDownload.add(true);
              widget.download();
            },
            shape: const CircleBorder(),
            child: Icon(
              Icons.download_rounded,
              color: ExtraTheme.of(context).messageDetails,
            ),
            padding: const EdgeInsets.all(10),
          );
        }
      },
    );
  }
}
