import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/video_thumbnail.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final File file;
  int width;
  int height;

  FileIcon({
    Key? key,
    required this.file,
    this.width = 50,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = extension(file.path).toLowerCase();
    final mimeMainType = file.path.getMimeString().getMimeMainType();
    if (extensions == '.apk') {
      return buildFileIcon(Icons.android, theme, theme.colorScheme.secondary);
    } else if (extensions == '.crdownload') {
      return buildFileIcon(Icons.download, theme, theme.colorScheme.error);
    } else if (extensions == '.zip' || extensions.contains('tar')) {
      return buildFileIcon(Icons.archive, theme, theme.colorScheme.primary);
    } else if (extensions == '.epub' ||
        extensions == '.pdf' ||
        extensions == '.mobi') {
      return buildFileIcon(
        Icons.picture_as_pdf,
        theme,
        theme.colorScheme.tertiary,
      );
    } else {
      switch (mimeMainType) {
        case 'image':
          return ClipRRect(
            clipBehavior: Clip.hardEdge,
            borderRadius: tertiaryBorder,
            child: Image(
              errorBuilder: (b, o, c) {
                return const Icon(Icons.image);
              },
              image: ResizeImage(
                FileImage(File(file.path)),
                width: width,
                height: height,
              ),
            ),
          );
        case 'video':
          return SizedBox(
            height: height.toDouble(),
            width: width.toDouble(),
            child: VideoThumbnail(
              path: file.path,
            ),
          );
        case 'audio':
          return buildFileIcon(
            Icons.music_note,
            theme,
            theme.colorScheme.onTertiaryContainer,
            width: width.toDouble(),
            height: height.toDouble(),
          );
        case 'text':
          return buildFileIcon(
            Icons.text_snippet,
            theme,
            theme.colorScheme.onErrorContainer,
            width: width.toDouble(),
            height: height.toDouble(),
          );
        default:
          return buildFileIcon(
            Icons.insert_drive_file_rounded,
            theme,
            theme.colorScheme.onErrorContainer,
            width: width.toDouble(),
            height: height.toDouble(),
          );
      }
    }
  }
}

Widget buildFileIcon(IconData icon, ThemeData theme, Color color,
    {double width = 50, double height = 50}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(borderRadius: tertiaryBorder, color: color),
    child: Icon(
      icon,
      size: 35,
      color: theme.colorScheme.background,
    ),
  );
}
