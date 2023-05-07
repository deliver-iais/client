import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WsUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;
  final void Function() onEdit;

  late final file_pb.File image = message.json.toFile();

  WsUi({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.minWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
    required this.onEdit,
  });

  @override
  WsUiState createState() => WsUiState();
}

class WsUiState extends State<WsUi> {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _fileRepo = GetIt.I.get<FileRepo>();

  late final future = _fileRepo.getFile(
    widget.image.uuid,
    widget.image.name,
    intiProgressbar: false,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isSender = _authRepo.isCurrentUserSender(widget.message);

    return Column(
      // Reply box in animated emoji has different UI
      crossAxisAlignment:
          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        FutureBuilder<String?>(
          future: future,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox(
                width: 280.0,
                height: 280.0,
                child: TextLoader(borderRadius: mainBorder),
              );
            } else {
              return WsFilePreview(
                file: File(snapshot.data!),
                width: 280,
                height: 280,
              );
            }
          },
        ),
        Container(
          decoration: const BoxDecoration(borderRadius: mainBorder),
          child: TimeAndSeenStatus(
            widget.message,
            isSender: isSender,
            isSeen: widget.isSeen,
            needsPositioned: false,
            showBackground: true,
            needsPadding: true,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
