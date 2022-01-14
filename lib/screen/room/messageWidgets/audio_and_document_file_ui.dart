import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/header_details.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class AudioAndDocumentFileUI extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const AudioAndDocumentFileUI(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.isSender,
      required this.isSeen})
      : super(key: key);

  @override
  _AudioAndDocumentFileUIState createState() => _AudioAndDocumentFileUIState();
}

class _AudioAndDocumentFileUIState extends State<AudioAndDocumentFileUI> {


  @override
  Widget build(BuildContext context) {
    var file = widget.message.json!.toFile();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: file.name.isPersian()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          CircularFileStatusIndicator(
            message: widget.message,
          ),
          Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: SizedBox(
                  width: 175,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 155,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            file.name,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color:
                                ExtraTheme.of(context).textMessage),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              HeaderDetails(file: file),
              file.caption.isEmpty
                  ? TimeAndSeenStatus(
                  widget.message, widget.isSender, widget.isSeen,
                  needsBackground: true)
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}
