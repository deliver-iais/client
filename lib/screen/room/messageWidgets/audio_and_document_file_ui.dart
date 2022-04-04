import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/file_details.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
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
    Key? key,
    required this.message,
    required this.maxWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  }) : super(key: key);

  @override
  _AudioAndDocumentFileUIState createState() => _AudioAndDocumentFileUIState();
}

class _AudioAndDocumentFileUIState extends State<AudioAndDocumentFileUI> {
  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 6),
      child: Row(
        crossAxisAlignment: file.name.isPersian()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          CircularFileStatusIndicator(
            message: widget.message,
            backgroundColor: widget.colorScheme.onPrimary,
            foregroundColor: widget.colorScheme.primary,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                    FileDetails(file: file)
                  ],
                ),
                if (file.caption.isEmpty)
                  TimeAndSeenStatus(
                    widget.message,
                    isSender: widget.isSender,
                    isSeen: widget.isSeen,
                    foregroundColor:
                        widget.colorScheme.onPrimaryContainerLowlight(),
                    backgroundColor: widget.colorScheme.primaryContainer,
                    needsPadding: true,
                    needsPositioned: false,
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
