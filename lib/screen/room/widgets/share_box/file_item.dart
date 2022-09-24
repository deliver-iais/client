import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/file_icon.dart';
import 'package:deliver/screen/room/widgets/share_box/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FileItem extends StatelessWidget {
  final FileSystemEntity file;

  const FileItem({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      leading: FileIcon(file: file),
      title: Text(
        basename(file.path),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        FileUtils.formatBytes(File(file.path).lengthSync(), 2),
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 13,
        ),
      ),
    );
  }
}
