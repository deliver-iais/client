import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/screen/room/messageWidgets/audio_and_document_file_ui.dart';
import 'package:deliver/screen/room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_message.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class FileMessageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final void Function(String) onUsernameClick;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const FileMessageUi(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.minWidth,
      required this.isSender,
      required this.onUsernameClick,
      required this.colorScheme,
      required this.isSeen})
      : super(key: key);

  @override
  _FileMessageUiState createState() => _FileMessageUiState();
}

class _FileMessageUiState extends State<FileMessageUi> {
  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    final type = file.type;
    final caption = file.caption;
    final dimensions =
        getImageDimensions(file.width.toDouble(), file.height.toDouble());

    final width = dimensions.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (isDebugEnabled())
          DebugC(label: "file details", children: [Debug(file)]),
        _buildMainUi(type),
        if (caption.isNotEmpty)
          SizedBox(
            width: width,
            child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TextUI(
                    message: widget.message,
                    maxWidth: widget.maxWidth,
                    isSender: widget.isSender,
                    isSeen: widget.isSeen,
                    colorScheme: widget.colorScheme,
                    onUsernameClick: widget.onUsernameClick,
                    onBotCommandClick: (str) => {})),
          )
      ],
    );
  }

  Widget _buildMainUi(String type) {
    if (type.contains('image') ||
        type.contains("png") ||
        type.contains("jpg")) {
      return ImageUi(
        message: widget.message,
        maxWidth: widget.maxWidth,
        minWidth: widget.minWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
        colorScheme: widget.colorScheme,
      );
    } else if (type.contains('video')) {
      return VideoMessage(
        message: widget.message,
        maxWidth: widget.maxWidth,
        minWidth: widget.minWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
        colorScheme: widget.colorScheme,
      );
    } else {
      return AudioAndDocumentFileUI(
        message: widget.message,
        maxWidth: widget.maxWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
        colorScheme: widget.colorScheme,
      );
    }
  }

  Size getImageDimensions(double width, double height) {
    final maxWidth = widget.maxWidth;
    if (width == 0 || height == 0) {
      width = maxWidth;
      height = maxWidth;
    }
    final aspect = width / height;
    var w = 0.0;
    var h = 0.0;
    if (aspect > 1) {
      w = min(width, maxWidth);
      h = w / aspect;
    } else {
      h = min(height, maxWidth);
      w = h * aspect;
    }

    return Size(w, h);
  }
}
