import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/drag_and_drop_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/keyboard.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void showCaptionDialog({
  List<model.File>? files,
  required Uid roomUid,
  required BuildContext context,
  void Function()? resetRoomPageDetails,
  int replyMessageId = 0,
  Message? editableMessage,
  String? caption,
  bool showSelectedImage = false,
}) {
  if (editableMessage == null && (files?.isEmpty ?? false)) return;
  showDialog(
    context: context,
    builder: (context) {
      return ShowCaptionDialog(
        resetRoomPageDetails: resetRoomPageDetails,
        replyMessageId: replyMessageId,
        caption: caption,
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
  final List<model.File>? files;
  final Uid currentRoom;
  final Message? editableMessage;
  final bool showSelectedImage;
  final int replyMessageId;
  final void Function()? resetRoomPageDetails;
  final String? caption;

  const ShowCaptionDialog({
    super.key,
    this.files,
    required this.currentRoom,
    this.showSelectedImage = false,
    this.editableMessage,
    required this.resetRoomPageDetails,
    required this.replyMessageId,
    this.caption,
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

  late file_pb.File _editableFile;
  final FocusNode _captionFocusNode = FocusNode();
  model.File? _editedFile;
  Iterable<NotAcceptableFile>? _notAcceptableFiles;

  @override
  void initState() {
    if (widget.editableMessage == null) {
      _notAcceptableFiles = getNotAcceptableFiles(widget.files!);

      if (widget.caption != null && widget.caption!.isNotEmpty) {
        _editingController.text = synthesizeToOriginalWord(widget.caption!);
      }
    } else {
      _editableFile = widget.editableMessage!.json.toFile();
      _editingController.text = synthesizeToOriginalWord(_editableFile.caption);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  _notAcceptableFiles!=null && _notAcceptableFiles!.isNotEmpty
        ? NotAcceptableFilesErrorDialog(notAcceptableFiles: _notAcceptableFiles!)
        : ((widget.files?.isNotEmpty ?? false) ||
                widget.editableMessage != null)
            ? Directionality(
                textDirection: _i18n.defaultTextDirection,
                child: SingleChildScrollView(
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
                    actions: [buildActionButtonsRow()],
                  ),
                ),
              )
            : const SizedBox.shrink();
  }

  bool isImageFile(int index) {
    final extension = _editedFile != null
        ? _editedFile!.extension
        : widget.editableMessage != null
            ? _editableFile.type
            : widget.files?[index].extension;
    return (extension != null && isImageFileExtension(extension));
  }

  Widget _buildSelectedFileTitle() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.files!.length.toString() + _i18n.get("files_selected"),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          IconButton(
            onPressed: () async {
              final files = await getFile(allowMultiple: true);
              for (final f in files) {
                widget.files!.add(f);
              }
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtonsRow() {
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
                color: theme.primaryColor,
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
                color: theme.primaryColor,
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
        itemCount: widget.editableMessage != null ? 1 : widget.files!.length,
        itemBuilder: (c, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: (isImageFile(
              index,
            ))
                ? GestureDetector(
                    onTap: () => openEditImagePage(index),
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
                          Center(child: buildImageFileUi(index)),
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

  Widget buildImageFileUi(int index) {
    if (widget.editableMessage != null && _editedFile == null) {
      return FutureBuilder<String?>(
        future: _fileRepo.getFileIfExist(
          _editableFile.uuid,
          _editableFile.name,
        ),
        builder: (c, s) {
          if (s.hasData && s.data != null) {
            return Image.file(
              File(s.data!),
              width: 180,
            );
          } else {
            return buildSimpleFileUi(
              0,
              showManage: false,
            );
          }
        },
      );
    } else {
      return buildImage(
        _editedFile?.path ?? widget.files![index].path,
        width: 180,
      );
    }
  }

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

  Future<void> openEditImagePage(int index) async {
    final navigatorState = Navigator.of(context);
    String? path = "";
    if (widget.editableMessage != null) {
      path = await _fileRepo.getFileIfExist(
        _editableFile.uuid,
        _editableFile.name,
      );
    }

    navigatorState.push(
      MaterialPageRoute(
        builder: (c) {
          return OpenImagePage(
            onEditEnd: (path) {
              if (widget.files != null) {
                widget.files![index].path = path;
              } else if (_editedFile != null) {
                _editedFile!.path = path;
              } else if (widget.editableMessage != null) {
                _editedFile = model.File(
                  path,
                  extension: _editableFile.type,
                  path.split(".").first,
                );
              }
              Navigator.pop(context);
              setState(() {});
            },
            imagePath: (_editedFile?.path) ??
                (widget.editableMessage != null
                    ? path!
                    : widget.files![index].path),
          );
        },
      ),
    ).ignore();
  }

  Widget buildImage(String path, {double? width, double? height}) => isWeb
      ? Image.network(path)
      : Image.file(
          File(path),
          width: width,
          height: height,
        );

  void send() {
    Navigator.pop(context);
    widget.editableMessage != null
        ? _messageRepo.editFileMessage(
            widget.editableMessage!.roomUid.asUid(),
            widget.editableMessage!,
            caption: _editingController.text.trim(),
            file: _editedFile,
          )
        : _messageRepo.sendMultipleFilesMessages(
            widget.currentRoom,
            widget.files!,
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
            color: theme.primaryColor, // button color
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
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            widget.editableMessage != null
                ? _editedFile != null
                    ? _editedFile!.name
                    : widget.editableMessage!.json.toFile().name
                : widget.files![index].name,
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
                widget.files![index] = file;
              }
              setState(() {});
            }
          },
          icon: Icon(
            CupertinoIcons.refresh,
            color: theme.primaryColor,
            size: 16,
          ),
        ),
        if (widget.editableMessage == null)
          IconButton(
            onPressed: () {
              widget.files!.removeAt(index);
              if (widget.files == null || widget.files!.isEmpty) {
                Navigator.pop(context);
              }
              setState(() {});
            },
            icon: Icon(
              Icons.delete,
              color: theme.primaryColor,
              size: 16,
            ),
          ),
        if (isImageFile(index))
          IconButton(
            onPressed: () {
              openEditImagePage(index);
            },
            icon: Icon(
              Icons.edit,
              color: theme.primaryColor,
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

    final files = (result?.files ?? []).map(filePickerPlatformFileToFileModel);

    final notAcceptableFile = getNotAcceptableFiles(files);

    if (notAcceptableFile.isNotEmpty) {
      final naf = notAcceptableFile.first;

      final errorText = naf.hasNotAcceptableExtension
          ? _i18n.get("cant_sent")
          : naf.isEmpty
              ? _i18n.get("file_size_zero")
              : _i18n.get("file_size_error");

      ToastDisplay.showToast(
        toastText: errorText,
        toastContext: context,
      );

      return [];
    } else {
      return files;
    }
  }
}

class NotAcceptableFilesErrorDialog extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  final Iterable<NotAcceptableFile> notAcceptableFiles;

  const NotAcceptableFilesErrorDialog({
    super.key,
    required this.notAcceptableFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: AlertDialog(
        title: Text(
          _i18n.get("error"),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              _i18n.get("ok"),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
        content: SizedBox(
          width: 350,
          child: Column(
            children: [
              for (final file in notAcceptableFiles)
                if (file.hasNotAcceptableExtension)
                  Wrap(
                    children: [
                      Text(file.file.name),
                      Text(_i18n.get("cant_sent")),
                    ],
                  )
                else if (file.isEmpty)
                  Wrap(
                    children: [
                      Text(file.file.name),
                      Text(_i18n.get("file_size_zero"))
                    ],
                  )
                else if (file.hasExtraSize)
                  Wrap(
                    children: [
                      Text(file.file.name),
                      Text(_i18n.get("file_size_error")),
                    ],
                  )
            ],
          ),
        ),
      ),
    );
  }
}
