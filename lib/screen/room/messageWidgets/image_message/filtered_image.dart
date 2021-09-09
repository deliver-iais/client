import 'dart:io';
import 'dart:ui';

import 'package:we/repository/fileRepo.dart';
import 'package:we/screen/room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:we/services/file_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FilteredImage extends StatefulWidget {
  final String uuid;
  final String name;
  final String path;
  final bool sended;
  final double width;
  final double height;
  final Function onPressed;

  FilteredImage(
      {this.uuid,
      this.name,
      this.path,
      this.sended,
      this.width,
      this.height,
      this.onPressed});

  @override
  _FilteredImageState createState() => _FilteredImageState();
}

class _FilteredImageState extends State<FilteredImage> {
  bool startDownload = false;
  @override
  Widget build(BuildContext context) {
    var fileRepo = GetIt.I.get<FileRepo>();
    return FutureBuilder<File>(
        future:
            fileRepo.getFile(widget.uuid, widget.name, thumbnailSize: ThumbnailSize.medium),
        builder: (context, file) {
          if (file.hasData == false && widget.path != null) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  File(widget.path),
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.fill,
                ),
                SendingFileCircularIndicator(
                  loadProgress: 0.8,
                  isMedia: true,
                )
              ],
            );
          } else {
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(
                  file.data,
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  width: widget.width,
                  height: widget.height,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.0),
                      ),
                    ),
                  ),
                ),
                !widget.sended
                    ? SendingFileCircularIndicator(
                        loadProgress: 0.8,
                        isMedia: true,
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: IconButton(
                          icon: startDownload? CircularProgressIndicator():Icon(Icons.file_download),
                          onPressed: () {
                            startDownload  = true;
                            widget.onPressed.call();
                          },
                        ),
                      )
              ],
            );
          }
        });
  }
}
