import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/theme/extra_theme.dart';
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

  StreamBuilder<double> buildStreamBuilder() {
    return StreamBuilder<double>(
      stream: _fileServices.filesDownloadStatus[widget.uuid],
      builder: (c, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data! > 0) {
          return CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 5.0,
            backgroundColor: Colors.lightBlue,
            percent: snapshot.data!,
            center: const Icon(
              Icons.download_rounded,
              color: Colors.lightBlue,
            ),
            progressColor: Colors.white,
          );
        } else {
          return MaterialButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
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
