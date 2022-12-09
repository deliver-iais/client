import 'dart:io';

import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/profile/widgets/all_media_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllImagePage extends StatelessWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final Message? message;
  final String? filePath;
  final void Function()? onEdit;

  const AllImagePage({
    super.key,
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.filePath,
    this.message,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AllMediaPage(
      roomUid: roomUid,
      messageId: messageId,
      mediaType: MediaType.IMAGE,
      filePath: filePath,
      initIndex: initIndex,
      message: message,
      onEdit: onEdit,
      mediaUiWidget: (filePath) =>
          isWeb ? Image.network(filePath) : Image.file(File(filePath)),
    );
  }
}
