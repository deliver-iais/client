import 'dart:io';

import 'package:deliver/screen/room/widgets/share_box/file_box_item_icon.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FileBoxItem extends StatelessWidget {
  final File file;

  const FileBoxItem({
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
        byteFormat(File(file.path).lengthSync()),
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 13,
        ),
      ),
    );
  }
}
