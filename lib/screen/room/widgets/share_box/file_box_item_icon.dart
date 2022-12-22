import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/video_thumbnail.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';

class FileIcon extends StatelessWidget {
  final File file;

  const FileIcon({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final f = File(file.path);
    final extensions = extension(f.path).toLowerCase();
    final mimeType = mime(basename(file.path).toLowerCase()) ?? '';
    final type = mimeType.isEmpty ? '' : mimeType.split('/')[0];
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
      switch (type) {
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
                width: 50,
                height: 50,
              ),
            ),
          );
        case 'video':
          return SizedBox(
            height: 50,
            width: 50,
            child: VideoThumbnail(
              path: file.path,
            ),
          );
        case 'audio':
          return buildFileIcon(
            Icons.music_note,
            theme,
            theme.colorScheme.onTertiaryContainer,
          );
        case 'text':
          return buildFileIcon(
            Icons.text_snippet,
            theme,
            theme.colorScheme.onErrorContainer,
          );
        default:
          return buildFileIcon(
            Icons.insert_drive_file_rounded,
            theme,
            theme.colorScheme.onErrorContainer,
          );
      }
    }
  }
}

Widget buildFileIcon(IconData icon, ThemeData theme, Color color) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(borderRadius: tertiaryBorder, color: color),
    child: Icon(
      icon,
      size: 35,
      color: theme.colorScheme.background,
    ),
  );
}
