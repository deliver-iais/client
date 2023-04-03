import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/file_details.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AudioAndDocumentFileUI extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const AudioAndDocumentFileUI({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  });

  @override
  AudioAndDocumentFileUIState createState() => AudioAndDocumentFileUIState();
}

class AudioAndDocumentFileUIState extends State<AudioAndDocumentFileUI> {
  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 6.0, top: 4, bottom: 4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: <Widget>[
                CircularFileStatusIndicator(
                  message: widget.message,
                  backgroundColor: widget.colorScheme.primary,
                  foregroundColor: widget.colorScheme.onPrimary,
                ),
                Container(
                  width: widget.maxWidth * 0.55,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 2.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!file.isVoiceFileProto())
                          SizedBox(
                            width: widget.maxWidth * 0.5,
                            child: Text(
                              file.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                        FileDetails(
                          maxWidth: widget.maxWidth * 0.55,
                          file: file,
                          colorScheme: widget.colorScheme,
                          withColor: false,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (file.caption.isEmpty)
            TimeAndSeenStatus(
              widget.message,
              isSender: widget.isSender,
              isSeen: widget.isSeen,
              needsPadding: true,
            )
        ],
      ),
    );
  }
}
