import 'dart:math';

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/message_header.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/video_message/video_message.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';

class FileMessageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final Function onUsernameClick;
  final bool isSeen;

  const FileMessageUi(
      {Key key,
      this.message,
      this.maxWidth,
      this.isSender,
      this.onUsernameClick,
      this.isSeen})
      : super(key: key);

  @override
  _FileMessageUiState createState() => _FileMessageUiState();
}

class _FileMessageUiState extends State<FileMessageUi> {
  @override
  Widget build(BuildContext context) {
    var file = widget.message.json.toFile();
    var type = file.type;
    var caption = file.caption;
    var dimensions =
        getImageDimensions(file.width.toDouble(), file.height.toDouble());

    double width = dimensions.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildMainUi(type),
        if (caption.isNotEmpty)
          Container(
            width: width,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: TextUI(
                  message: widget.message,
                  maxWidth: widget.maxWidth,
                  isSender: widget.isSender,
                  isSeen: widget.isSeen,
                  onUsernameClick: widget.onUsernameClick,
                )),
          )
      ],
    );
  }

  Widget _buildMainUi(String type) {
    if (type.contains('image')) {
      return ImageUi(
        message: widget.message,
        maxWidth: widget.maxWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
      );
    } else if (type.contains('video')) {
      return VideoMessage(
        message: widget.message,
        maxWidth: widget.maxWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
      );
    } else {
      return UnknownFileUi(
        message: widget.message,
        maxWidth: widget.maxWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
      );
    }
  }

  Size getImageDimensions(double width, double height) {
    double maxWidth = widget.maxWidth;
    if (width == null || width == 0 || height == null || height == 0) {
      width = maxWidth;
      height = maxWidth;
    }
    double aspect = width / height;
    double w = 0;
    double h = 0;
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
