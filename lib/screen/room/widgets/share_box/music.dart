import 'dart:io';

import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';

import 'helper_classes.dart';

class ShareBoxMusic extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(int, String) onClick;
  final Map<int, bool> selectedAudio;
  final void Function(int, String) playMusic;
  final Map<int, IconData> icons;

  const ShareBoxMusic({
    super.key,
    required this.scrollController,
    required this.onClick,
    required this.playMusic,
    required this.icons,
    required this.selectedAudio,
  });

  @override
  ShareBoxMusicState createState() => ShareBoxMusicState();
}

class ShareBoxMusicState extends State<ShareBoxMusic> {
  late Future<List<File>> _future;

  @override
  void initState() {
    _future = AudioItem.getAudios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<File>?>(
      future: _future,
      builder: (context, audios) {
        if (audios.hasData) {
          return ListView.builder(
            controller: widget.scrollController,
            itemCount: audios.data!.length,
            itemBuilder: (ctx, index) {
              final fileItem = audios.data![index];
              final isItemSelected = widget.selectedAudio[index] ?? false;
              return InkWell(
                child: Container(
                  color: isItemSelected
                      ? theme.primaryColor.withOpacity(0.3)
                      : null,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          widget.icons[index] ??
                              Icons.play_circle_filled_rounded,
                          color: theme.primaryColor,
                          size: 40,
                        ),
                        onPressed: () => widget.playMusic(index, fileItem.path),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Flexible(
                        child: Text(
                          fileItem.path.split("/").last,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  if (await fileItem.length() > MAX_FILE_SIZE_BYTE) {
                    FileErrorDialog(
                      isFileFormatAccept: true,
                      invalidFormatFileName: "",
                      invalidSizeFileName: fileItem.path.split("/").last,
                    );
                  } else {
                    widget.onClick(index, fileItem.path);
                  }
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
