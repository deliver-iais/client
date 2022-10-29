import 'dart:io';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/file_details.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DownloadVideoWidget extends StatefulWidget {
  final pb.File file;
  final void Function() download;
  final Color background;
  final Color foreground;
  final double maxWidth;

  final CustomColorScheme colorScheme;

  const DownloadVideoWidget({
    super.key,
    required this.download,
    required this.background,
    required this.foreground,
    required this.file,
    required this.colorScheme,
    required this.maxWidth,
  });

  @override
  DownloadVideoWidgetState createState() => DownloadVideoWidgetState();
}

class DownloadVideoWidgetState extends State<DownloadVideoWidget> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  final _futureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<String?>(
          key: _futureKey,
          future: _fileRepo.getFile(
            widget.file.uuid,
            "${widget.file.name}.png",
            thumbnailSize: ThumbnailSize.small,
            intiProgressbar: false,
          ),
          builder: (c, thumbnail) {
            if (thumbnail.hasData && thumbnail.data != null) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  image: DecorationImage(
                    image: Image.file(File(thumbnail.data!)).image,
                    fit: BoxFit.cover,
                  ),
                  color: Colors.black.withOpacity(0.5),
                ),
                child: buildLoadFileStatus(() => widget.download()),
              );
            } else {
              return buildLoadFileStatus(() => widget.download());
            }
          },
        ),
        FileDetails(
          file: widget.file,
          colorScheme: widget.colorScheme,
          maxWidth: widget.maxWidth * 0.55,
          withColor: true,
        ),
      ],
    );
  }

  Widget buildLoadFileStatus(
    Function() onTap, {
    bool isPendingMessage = false,
  }) {
    return Center(
      child: LoadFileStatus(
        uuid: widget.file.uuid,
        name: widget.file.name,
        isPendingMessage: isPendingMessage,
        onPressed: () => onTap(),
        onCancel: (){},
        background: widget.background.withOpacity(0.8),
        foreground: widget.foreground,
      ),
    );
  }
}
