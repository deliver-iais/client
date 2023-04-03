import 'dart:async';

import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/screen/room/widgets/share_box/view_image_page.dart';
import 'package:deliver/services/drag_and_drop_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void showCaptionDialog({
  required Uid roomUid,
  required BuildContext context,
  List<model.File> files = const [],
  void Function()? resetRoomPageDetails,
  int replyMessageId = 0,
  Message? editableMessage,
  String? caption,
  bool showSelectedImage = false,
}) {
  if (editableMessage == null && files.isEmpty) return;
  showDialog(
    context: context,
    builder: (context) {
      return ShowCaptionDialog(
        resetRoomPageDetails: resetRoomPageDetails,
        replyMessageId: replyMessageId,
        caption: caption ?? "",
        showSelectedImage: showSelectedImage,
        editableMessage: editableMessage,
        currentRoom: roomUid,
        files: files,
      );
    },
  );
}

// TODO(hasan): refactor ShowCaptionDialog class, https://gitlab.iais.co/deliver/wiki/-/issues/432
class ShowCaptionDialog extends StatefulWidget {
  final List<model.File> files;
  final Uid currentRoom;
  final Message? editableMessage;
  final bool showSelectedImage;
  final int replyMessageId;
  final String caption;
  final void Function()? resetRoomPageDetails;

  const ShowCaptionDialog({
    super.key,
    required this.files,
    required this.currentRoom,
    required this.resetRoomPageDetails,
    required this.replyMessageId,
    this.editableMessage,
    this.showSelectedImage = false,
    this.caption = "",
  });

  @override
  ShowCaptionDialogState createState() => ShowCaptionDialogState();
}

class ShowCaptionDialogState extends State<ShowCaptionDialog> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  final _dragAndDropService = GetIt.I.get<DragAndDropService>();

  final TextEditingController _editingController = TextEditingController();
  final FocusNode _captionFocusNode = FocusNode();

  file_pb.File? get _editableMessageFile =>
      widget.editableMessage?.json.toFile();
  model.File? _editedFile;

  @override
  void initState() {
    _editingController.text = synthesizeToOriginalWord(
      _editableMessageFile?.caption ?? widget.caption,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ((widget.files.isNotEmpty) || widget.editableMessage != null)
        ? SingleChildScrollView(
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              actionsPadding: const EdgeInsets.all(0),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 300,
                ),
                width: 330,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.editableMessage == null) ...[
                      _buildSelectedFileTitle(),
                      const Divider()
                    ],
                    _buildFilesListWidget(),
                    const Divider(),
                    _buildCaptionInputBox(),
                  ],
                ),
              ),
              actions: [_buildActionButtonsRow()],
            ),
          )
        : const SizedBox.shrink();
  }

  bool isEditing() => _editableMessageFile != null;

  bool isImageFile(int index) {
    final type = _editedFile?.path.getMimeString() ??
        _editableMessageFile?.type ??
        getWidgetFilesIndex(index)?.path.getMimeString();

    return type != null && isImageFileType(type);
  }

  Widget _buildSelectedFileTitle() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${widget.files.length} ${_i18n.get("files_selected")}",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          IconButton(
            onPressed: () async {
              final files = await getFile(allowMultiple: true);
              widget.files.addAll(files);
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: () {
              _dragAndDropService.enableDrag();
              Navigator.pop(context);
            },
            child: Text(
              _i18n.get("cancel"),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              _dragAndDropService.enableDrag();
              send();
            },
            child: Text(
              _i18n.get("send"),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesListWidget() {
    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: isEditing() ? 1 : widget.files.length,
        itemBuilder: (c, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: (isImageFile(index))
                ? GestureDetector(
                    onTap: () => _openEditImagePage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: tertiaryBorder,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                      child: Stack(
                        children: [
                          Center(child: _buildImageFileUi(index)),
                          Positioned(
                            right: 3,
                            top: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: tertiaryBorder,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.9),
                              ),
                              child: Center(
                                child: buildManageFilesRow(index: index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : buildSimpleFileUi(index),
          );
        },
      ),
    );
  }

  Widget _buildImageFileUi(int index) {
    try {
      if (_editableMessageFile != null && _editedFile == null) {
        return FutureBuilder<String?>(
          future: _fileRepo.getFileIfExist(
            _editableMessageFile!.uuid,
            _editableMessageFile!.name,
          ),
          builder: (c, s) {
            if (s.hasData && s.data != null) {
              return _buildImageWidget(s.data!);
            } else {
              return buildSimpleFileUi(0, showManage: false);
            }
          },
        );
      } else {
        return _buildImageWidget(_editedFile?.path ?? widget.files[index].path);
      }
    } catch (_) {
      return buildSimpleFileUi(0, showManage: false);
    }
  }

  Widget _buildImageWidget(String path) =>
      Image(image: path.imageProvider(cacheWidth: 180), width: 180);

  Widget _buildCaptionInputBox() {
    return RawKeyboardListener(
      focusNode: _captionFocusNode,
      onKey: (event) {
        if (isEnterClicked(event) && !event.isShiftPressed) {
          send();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        constraints: const BoxConstraints(maxWidth: 350),
        child: AutoDirectionTextForm(
          controller: _editingController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          autofocus: true,
          style: const TextStyle(
            fontSize: 15,
          ),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: _i18n.get("caption"),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditImagePage(int index) async {
    final navigatorState = Navigator.of(context);

    final String? path;

    if (isEditing()) {
      path = _editedFile?.path ??
          await _fileRepo.getFileIfExist(
            _editableMessageFile!.uuid,
            _editableMessageFile!.name,
          );
    } else {
      path = getWidgetFilesIndex(index)?.path;
    }

    if (path == null) {
      return;
    }

    navigatorState.push(
      MaterialPageRoute(
        builder: (c) {
          return ViewImagePage(
            onEditEnd: (path) {
              if (isEditing()) {
                _editedFile = pathToFileModel(path);
              } else {
                widget.files[index].path = path;
              }
              Navigator.pop(context);
              setState(() {});
            },
            imagePath: path!,
          );
        },
      ),
    ).ignore();
  }

  void send() {
    Navigator.pop(context);
    isEditing()
        ? _messageRepo.editFileMessage(
            widget.editableMessage!.roomUid.asUid(),
            widget.editableMessage!,
            caption: _editingController.text.trim(),
            file: _editedFile,
          )
        : _messageRepo.sendMultipleFilesMessages(
            widget.currentRoom,
            widget.files,
            replyToId: widget.replyMessageId,
            caption: _editingController.text,
          );
    widget.resetRoomPageDetails?.call();
  }

  Row buildSimpleFileUi(int index, {bool showManage = true}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Material(
            color: theme.colorScheme.primary,
            child: InkWell(
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.insert_drive_file,
                  size: 20,
                  color: theme.dialogBackgroundColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _editedFile?.name ??
                _editableMessageFile?.name ??
                getWidgetFilesIndex(index)?.name ??
                "",
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showManage)
          Align(
            alignment: Alignment.topRight,
            child: buildManageFilesRow(index: index),
          )
      ],
    );
  }

  Widget buildManageFilesRow({required int index}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            final files = await getFile(allowMultiple: false);

            if (files.isNotEmpty) {
              final file = files.first;
              if (widget.editableMessage != null) {
                _editedFile = file;
              } else {
                widget.files[index] = file;
              }
              setState(() {});
            }
          },
          icon: Icon(
            CupertinoIcons.refresh,
            color: theme.colorScheme.primary,
            size: 16,
          ),
        ),
        if (widget.editableMessage == null)
          IconButton(
            onPressed: () {
              widget.files.removeAt(index);
              if (widget.files.isEmpty) {
                Navigator.pop(context);
              }
              setState(() {});
            },
            icon: Icon(
              Icons.delete,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
        if (isImageFile(index))
          IconButton(
            onPressed: () => _openEditImagePage(index),
            icon: Icon(
              Icons.edit,
              color: theme.colorScheme.primary,
              size: 16,
            ),
          )
      ],
    );
  }

  Future<Iterable<model.File>> getFile({required bool allowMultiple}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
    );

    return (result?.files ?? []).map(filePickerPlatformFileToFileModel);
  }

  model.File? getWidgetFilesIndex(int index) =>
      widget.files.length - index < 1 ? null : widget.files[index];
}
