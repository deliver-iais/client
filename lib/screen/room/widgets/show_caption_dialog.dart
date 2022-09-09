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
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

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
  static final _fileService = GetIt.I.get<FileService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _fileRepo = GetIt.I.get<FileRepo>();

  final TextEditingController _editingController = TextEditingController();

  late file_pb.File _editableFile;
  final FocusNode _captionFocusNode = FocusNode();
  bool _isFileFormatAccept = false;
  bool _isFileSizeAccept = false;
  model.File? _editedFile;
  String _invalidFormatFileName = "";
  String _invalidSizeFileName = "";

  @override
  void initState() {
    _isFileFormatAccept = widget.editableMessage != null;
    _isFileSizeAccept = widget.editableMessage != null;
    if (widget.editableMessage == null) {
      for (final element in widget.files!) {
        element.path = element.path.replaceAll("\\", "/");
        _isFileFormatAccept = _fileService.isFileFormatAccepted(
          element.extension ?? element.name.split(".").last,
        );
        final size = element.size ?? 0;
        _isFileSizeAccept = size < MAX_FILE_SIZE_BYTE;
        if (!_isFileFormatAccept) {
          _invalidFormatFileName = element.name;
          break;
        }
        if (!_isFileSizeAccept) {
          _invalidSizeFileName = element.name;
          break;
        }
      }
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
    return !_isFileFormatAccept || !_isFileSizeAccept
        ? FileErrorDialog(
            isFileFormatAccept: _isFileFormatAccept,
            invalidFormatFileName: _invalidFormatFileName,
            invalidSizeFileName: _invalidSizeFileName,
          )
        : ((widget.files?.isNotEmpty ?? false) ||
                widget.editableMessage != null)
            ? Directionality(
                textDirection: _i18n.defaultTextDirection,
                child: SingleChildScrollView(
                  child: AlertDialog(
                    content: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 300,
                      ),
                      width: 300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildFilesListWidget(),
                          const SizedBox(
                            height: 5,
                          ),
                          buildCaptionInputBox(),
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
    return (extension != null &&
        (extension.contains("image") ||
            extension.contains("jpg") ||
            extension.contains("png") ||
            extension.contains("jfif") ||
            extension.contains("webp") ||
            extension.contains("jpeg")));
  }

  Widget buildActionButtonsRow() {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (widget.editableMessage == null)
          TextButton(
            onPressed: () async {
              final res = await getFile(allowMultiple: true);
              if (res != null) {
                for (final element in res.files) {
                  widget.files!.add(
                    model.File(
                      isWeb
                          ? Uri.dataFromBytes(
                              element.bytes!.toList(),
                            ).toString()
                          : element.path!,
                      element.name,
                      extension: element.extension,
                      size: element.size,
                    ),
                  );
                }
                setState(() {});
              }
            },
            child: Text(
              _i18n.get("add"),
              style: TextStyle(
                fontSize: 16,
                color: theme.primaryColor,
              ),
            ),
          ),
        const Spacer(),
        TextButton(
          onPressed: () {
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
    );
  }

  Widget buildFilesListWidget() {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.editableMessage != null ? 1 : widget.files!.length,
        itemBuilder: (c, index) {
          if (isImageFile(
            index,
          )) {
            return GestureDetector(
              onTap: () => openEditImagePage(index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: tertiaryBorder,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
            );
          } else {
            return Flexible(child: buildSimpleFileUi(index));
          }
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 20,
            child: Center(child: Divider()),
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

  Widget buildCaptionInputBox() {
    return RawKeyboardListener(
      focusNode: _captionFocusNode,
      onKey: (event) {
        if (event.physicalKey == PhysicalKeyboardKey.enter) {
          send();
        }
      },
      child: Container(
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

  Widget buildImage(String path, {double? width, double? height}) => kIsWeb
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
            caption: synthesize(_editingController.text.trim()),
            file: _editedFile,
          )
        : _messageRepo.sendMultipleFilesMessages(
            widget.currentRoom,
            widget.files!,
            replyToId: widget.replyMessageId,
            caption: synthesize(_editingController.text),
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
            final result = await getFile(allowMultiple: false);

            if (result != null && result.files.isNotEmpty) {
              if (widget.editableMessage != null) {
                _editedFile = model.File(
                  isWeb
                      ? Uri.dataFromBytes(
                          result.files.first.bytes!.toList(),
                        ).toString()
                      : result.files.first.path!,
                  result.files.first.name,
                  extension: result.files.first.extension,
                  size: result.files.first.size,
                );
              } else {
                widget.files![index] = model.File(
                  isWeb
                      ? Uri.dataFromBytes(
                          result.files.first.bytes!.toList(),
                        ).toString()
                      : result.files.first.path!,
                  result.files.first.name,
                  extension: result.files.first.extension,
                  size: result.files.first.size,
                );
              }

              setState(() {});
            }
          },
          icon: Icon(
            Icons.wifi_protected_setup,
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

  Future<FilePickerResult?> getFile({required bool allowMultiple}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
    );
    for (final element in result!.files) {
      _isFileFormatAccept =
          _fileService.isFileFormatAccepted(element.extension ?? element.name);
      _isFileSizeAccept = element.size < MAX_FILE_SIZE_BYTE;
      if (!_isFileFormatAccept) {
        _invalidFormatFileName = element.name;
        break;
      }
      if (!_isFileSizeAccept) {
        _invalidSizeFileName = element.name;
        break;
      }
    }
    if (_isFileFormatAccept && _isFileSizeAccept) {
      return result;
    } else {
      if (isDesktop) {
        ToastDisplay.showToast(
          toastText: !_isFileFormatAccept
              ? "${_i18n.get("cant_sent")} $_invalidFormatFileName"
              : _i18n.get("file_size_error"),
          toastContext: context,
        );
      }
      return null;
    }
  }
}

class FileErrorDialog extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  final bool _isFileFormatAccept;
  final String _invalidFormatFileName;
  final String _invalidSizeFileName;

  const FileErrorDialog({
    super.key,
    required bool isFileFormatAccept,
    required String invalidFormatFileName,
    required String invalidSizeFileName,
  })  : _isFileFormatAccept = isFileFormatAccept,
        _invalidFormatFileName = invalidFormatFileName,
        _invalidSizeFileName = invalidSizeFileName;

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
          width: 150,
          child: Wrap(
            children: [
              if (!_isFileFormatAccept) ...[
                Text(_invalidFormatFileName),
                Text(_i18n.get("cant_sent"))
              ] else ...[
                Text(_invalidSizeFileName),
                Text(_i18n.get("file_size_error")),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
