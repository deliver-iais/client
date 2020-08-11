import 'package:deliver_flutter/screen/app-room/widgets/share_box/file_item_widget.dart';
import 'package:flutter/material.dart';

import 'helper_classes.dart';

class ShareBoxFile extends StatelessWidget {
  final List<FileItem> filesList;
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedFiles;

  const ShareBoxFile(
      {Key key,
      @required this.filesList,
      @required this.scrollController,
      @required this.onClick,
      @required this.selectedFiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: filesList.length,
        itemBuilder: (ctx, index) {
          return FileItemWidget(
              fileItem: filesList[index],
              selected: selectedFiles[index] ?? false,
              onTap: () => onClick(index),
              iconData: Icons.insert_drive_file);
        });
  }
}
