import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/size_formater.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;

  const VideoMessage({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  bool isDownloaded = false;
  @override
  Widget build(BuildContext context) {
    File video = widget.message.json.toFile();
    Duration duration = Duration(seconds: video.duration.round());
    String videoLength;
    if (duration.inHours == 0) {
      videoLength = duration.inMinutes > 9
          ? duration.toString().substring(2, 7)
          : duration.toString().substring(3, 7);
    } else {
      videoLength = duration.toString().split('.').first.padLeft(8, "0");
    }
    return Container(
      width: video.width.toDouble(),
      height: video.height.toDouble(),
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: isDownloaded
            ? <Widget>[
                VideoUi(video: video),
                Positioned(
                  child: Text(videoLength),
                  top: 5,
                  left: 5,
                ),
                Positioned(child: Icon(Icons.more_vert), top: 5, right: 0),
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: IconButton(
                        icon: Icon(Icons.play_arrow), onPressed: () {}))
              ]
            : <Widget>[
                Positioned(
                  child: Text(videoLength),
                  top: 5,
                  left: 5,
                ),
                Positioned(
                  child: Text(sizeFormater(video.size.toInt())),
                  top: 20,
                  left: 5,
                ),
                Positioned(child: Icon(Icons.more_vert), top: 5, right: 0),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () {
                      setState(() {
                        isDownloaded = true;
                      });
                    },
                  ),
                )
              ],
      ),
    );
  }
}
