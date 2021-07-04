import 'dart:math';

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/message_header.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/text_message/text_ui.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_message.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

class FileMessageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final Function lastCross;
  final bool isSender;
  final Function onUsernameClick;
  final CrossAxisAlignment last;
  final bool isSeen;

  const FileMessageUi(
      {Key key,
      this.message,
      this.maxWidth,
      this.lastCross,
      this.isSender,
      this.onUsernameClick,
      this.last,
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
      crossAxisAlignment: widget.last,
      children: <Widget>[
        _buildMainUi(type),
        if (caption.isNotEmpty)
          Container(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: TextUi(
                message: widget.message,
                maxWidth: widget.maxWidth,
                lastCross: widget.lastCross,
                isSender: widget.isSender,
                onUsernameClick: widget.onUsernameClick,
                isCaption: true,
                imageWidth: width,
                color: ExtraTheme.of(context).textMessage,
              ),
            ),
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
