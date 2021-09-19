import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadVideoWidget extends StatefulWidget {
  final String uuid;
  final String name;
  final Function download;

  DownloadVideoWidget({this.uuid, this.download, this.name});

  @override
  _DownloadVideoWidgetState createState() => _DownloadVideoWidgetState();
}

class _DownloadVideoWidgetState extends State<DownloadVideoWidget> {
  bool startDownload = false;
  var fileServices = GetIt.I.get<FileService>();
  var _fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _fileRepo.getFile(widget.uuid, widget.name + ".png",
          thumbnailSize: ThumbnailSize.medium),
      builder: (c, thumbnail) {
        if (thumbnail.hasData && thumbnail.data != null) {
          return Container(
              decoration: BoxDecoration(
                image: new DecorationImage(
                  image: Image.file(thumbnail.data).image,
                  fit: BoxFit.cover,
                ),
                color: Colors.black.withOpacity(0.5),//TODO check
              ),
              child: Center(
                child: startDownload
                    ? StreamBuilder<double>(
                        stream: fileServices.filesDownloadStatus[widget.uuid],
                        builder: (c, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return CircularPercentIndicator(
                              radius: 35.0,
                              lineWidth: 4.0,
                              percent: snapshot.data,
                              center: Icon(Icons.download_rounded, color: ExtraTheme.of(context).messageDetails,),
                              progressColor: ExtraTheme.of(context).messageDetails,
                            );
                          } else {
                            return CircularPercentIndicator(
                              radius: 35.0,
                              lineWidth: 4.0,
                              percent: 0.01,
                              center: Icon(Icons.download_rounded, color: ExtraTheme.of(context).messageDetails,),
                              progressColor: ExtraTheme.of(context).messageDetails,
                            );
                          }
                        },
                      )
                    : MaterialButton(
                  color: Theme.of(context).buttonColor,
                  onPressed: () async {
                    widget.download();
                    startDownload = true;
                    setState(() {
                    });
                  },
                  shape: CircleBorder(),
                  child: Icon(Icons.download_rounded, color: ExtraTheme.of(context).messageDetails,),
                  padding: const EdgeInsets.all(10),
                ),
              ));
        } else {
          return Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: startDownload
                  ? StreamBuilder<double>(
                      stream: fileServices.filesDownloadStatus[widget.uuid],
                      builder: (c, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 4.0,
                            percent: snapshot.data,
                            center: Icon(Icons.arrow_downward, color: ExtraTheme.of(context).messageDetails,),
                            progressColor: ExtraTheme.of(context).messageDetails,
                          );
                        } else {
                          return CircularPercentIndicator(
                            radius: 35.0,
                            lineWidth: 4.0,
                            percent: 0.1,
                            center: Icon(Icons.arrow_downward, color: ExtraTheme.of(context).messageDetails,),
                            progressColor: ExtraTheme.of(context).messageDetails,
                          );
                        }
                      },
                    )
                  : IconButton(
                      icon: Icon(Icons.file_download, color: ExtraTheme.of(context).messageDetails,),
                      onPressed: () async {
                        startDownload = true;
                        widget.download();
                        setState(() {
                        });

                      },
                    ),
            ),
          );
        }
      },
    );
  }
}
