import 'package:deliver_flutter/screen/app-room/widgets/share_box/file_item_widget.dart';
import 'package:flutter/material.dart';

import 'helper_classes.dart';

class ShareBoxMusic extends StatelessWidget {
  final List<FileItem> audioAlbum;
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedAudio;

  const ShareBoxMusic(
      {Key key,
      @required this.audioAlbum,
      @required this.scrollController,
      @required this.onClick,
      @required this.selectedAudio})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: audioAlbum.length,
        itemBuilder: (ctx, index) {
          return FileItemWidget(
              fileItem: audioAlbum[index],
              selected: selectedAudio[index] ?? false,
              onTap: () => onClick(index),
              iconData: Icons.music_note);
        });
  }
}
