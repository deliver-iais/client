import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DownloadVideoWidget extends StatefulWidget {
  final pb.File file;
  final void Function(String?) onDownloadCompleted;
  final Color background;
  final Color foreground;
  final double maxWidth;

  final CustomColorScheme colorScheme;

  const DownloadVideoWidget({
    super.key,
    required this.onDownloadCompleted,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      hitTestBehavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: onDownload,
        child: Stack(
          children: [
            SizedBox(
              width: getSize(widget.file.width),
              height: getSize(widget.file.height),
              child: FutureBuilder<String?>(
                key: _futureKey,
                future: _fileRepo.getFile(
                  widget.file.uuid,
                  "${widget.file.name}.webp",
                  thumbnailSize: ThumbnailSize.frame,
                  intiProgressbar: false,
                ),
                builder: (c, thumbnail) {
                  if (thumbnail.hasData && thumbnail.data != null) {
                    return Container(
                      width: getSize(widget.file.width),
                      height: getSize(widget.file.height),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        image: DecorationImage(
                          image: thumbnail.data!.imageProvider(),
                          fit: BoxFit.cover,
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: widget.file.width.toDouble(),
                      height: widget.file.height.toDouble(),
                      child: const TextLoader(),
                    );
                  }
                },
              ),
            ),
            Positioned(
              top: 2,
              left: 2,
              right: 2,
              child: Row(
                children: [
                  buildLoadFileStatus(widgetSize: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDownload() async {
    widget.onDownloadCompleted.call(
      await _fileRepo.getFile(
        widget.file.uuid,
        widget.file.name,
        showAlertOnError: true,
      ),
    );
  }

  double? getSize(int size) {
    if (size < 1) {
      return null;
    } else {
      return size * 1.0;
    }
  }

  Widget buildLoadFileStatus({
    bool isPendingMessage = false,
    required double widgetSize,
  }) {
    return LoadFileStatus(
      file: widget.file,
      isUploading: isPendingMessage,
      showDetails: !isPendingMessage,
      onDownloadCompleted: widget.onDownloadCompleted,
      background: widget.colorScheme.onPrimaryContainer.withOpacity(0.7),
      foreground: widget.colorScheme.onPrimary,
      widgetSize: widgetSize,
    );
  }
}
