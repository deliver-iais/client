import 'dart:io';

import 'package:flutter/material.dart';

import 'helper_classes.dart';

class ShareBoxMusic extends StatefulWidget {
  final ScrollController scrollController;
  final Function onClick;
  final Map<int, bool> selectedAudio;
  final Function playMusic;
  final Map<int, IconData> icons;

  ShareBoxMusic(
      {Key? key,
      required this.scrollController,
      required this.onClick,
      required this.playMusic,
      required this.icons,
      required this.selectedAudio})
      : super(key: key);

  @override
  _ShareBoxMusicState createState() => _ShareBoxMusicState();
}

class _ShareBoxMusicState extends State<ShareBoxMusic> {
  var _future;

  @override
  void initState() {
    _future = AudioItem.getAudios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>?>(
        future: _future,
        builder: (context, audios) {
          if (audios.hasData) {
            return ListView.builder(
                controller: widget.scrollController,
                itemCount: audios.data!.length,
                itemBuilder: (ctx, index) {
                  var fileItem = audios.data![index];
                  var onTap = () => widget.onClick(index, fileItem.path);

                  var selected = widget.selectedAudio[index] ?? false;
                  return GestureDetector(
                    child: Container(
                      color: selected ? Colors.black12 : Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              widget.icons[index] ?? Icons.play_circle_filled,
                              color: Colors.blue,
                              size: 40,
                            ),
                            onPressed: () =>
                                widget.playMusic(index, fileItem.path),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: Text(
                              fileItem.path.split("/").last,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: onTap,
                  );
                });
          }
          return SizedBox.shrink();
        });
  }
}
