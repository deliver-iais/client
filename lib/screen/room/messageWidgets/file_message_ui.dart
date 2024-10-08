import 'dart:math';

import 'package:deliver/box/dao/auto_download_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/animation_message/ws_ui.dart';
import 'package:deliver/screen/room/messageWidgets/audio_and_document_file_ui.dart';
import 'package:deliver/screen/room/messageWidgets/image_message/image_ui.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_message.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class FileMessageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final CustomColorScheme colorScheme;
  final void Function(String) onUsernameClick;
  final void Function() onEdit;
  final bool isSeen;
  final File file;

  FileMessageUi({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.minWidth,
    required this.isSender,
    required this.onUsernameClick,
    required this.colorScheme,
    required this.isSeen,
    required this.onEdit,
  }) : file = message.json.toFile();

  @override
  FileMessageUiState createState() => FileMessageUiState();
}

class FileMessageUiState extends State<FileMessageUi> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _autoDownloadDao = GetIt.I.get<AutoDownloadDao>();
  final GlobalKey _fileMessageBoxKey = GlobalKey();
  final fileMessageBoxWidth = BehaviorSubject.seeded(0.0);

  @override
  void initState() {
    super.initState();
    mediaAutomaticDownload();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        fileMessageBoxWidth
            .add(_fileMessageBoxKey.currentContext?.size?.width ?? 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = getImageDimensions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (settings.showDeveloperDetails.value)
          DebugC(label: "file details", children: [Debug(widget.file)]),
        Container(key: _fileMessageBoxKey, child: _buildMainUi()),
        if (widget.file.caption.isNotEmpty)
          StreamBuilder<double>(
            stream: fileMessageBoxWidth,
            builder: (context, snapshot) {
              return SizedBox(
                width: snapshot.data ?? dimensions.width,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(top: 4),
                  child: TextUI(
                    message: widget.message,
                    maxWidth: widget.maxWidth,
                    isSender: widget.isSender,
                    isSeen: widget.isSeen,
                    colorScheme: widget.colorScheme,
                    onUsernameClick: widget.onUsernameClick,
                    onBotCommandClick: (str) => {},
                  ),
                ),
              );
            },
          )
      ],
    );
  }

  Widget _buildMainUi() {
    if (_isWsFile()) {
      return WsUi(
        message: widget.message,
        maxWidth: widget.maxWidth,
        minWidth: widget.minWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
        colorScheme: widget.colorScheme,
        onEdit: widget.onEdit,
      );
    } else if (_isImageFile()) {
      return ImageUi(
        message: widget.message,
        maxWidth: widget.maxWidth,
        minWidth: widget.minWidth,
        isSender: widget.isSender,
        isSeen: widget.isSeen,
        colorScheme: widget.colorScheme,
        onEdit: widget.onEdit,
      );
    } else if (_isVideoFile() && !isWeb) {
      // we can't support audio or video player on web!!!
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

  Size getImageDimensions() {
    var width = widget.file.width.toDouble();
    var height = widget.file.height.toDouble();

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

  Future<void> mediaAutomaticDownload() async {
    final category = _autoDownloadDao.convertCategory(
      widget.message.roomUid.category,
    );
    final isAutoDownloadEnable = _isImageFile()
        ? await _autoDownloadDao.isPhotoAutoDownloadEnable(category)
        : await _autoDownloadDao.isFileAutoDownloadEnable(category);
    if (isAutoDownloadEnable) {
      if (!_isImageFile()) {
        final limitSize =
            await _autoDownloadDao.getFileSizeLimitForAutoDownload(category);
        if (widget.file.size > limitSize) {
          return;
        }
      }
      await downloadFile();
    }
  }

  Future<void> downloadFile() async {
    final isExist = await _fileRepo.isExist(
      widget.file.uuid,
    );
    if (!isExist) {
      await _fileRepo.getFile(
        widget.file.uuid,
        widget.file.name,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool _isWsFile() => widget.file.isWsFileProto();

  bool _isImageFile() => widget.file.isImageFileProto();

  bool _isVideoFile() => widget.file.isVideoFileProto();
}
