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
  final String? type;
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
    this.type,
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
  String _type = "";
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
      _type = widget.type!;
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
      _type = _editableFile.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return !_isFileFormatAccept || !_isFileSizeAccept
        ? FileErrorDialog(
            isFileFormatAccept: _isFileFormatAccept,
            invalidFormatFileName: _invalidFormatFileName,
            invalidSizeFileName: _invalidSizeFileName,
          )
        : (widget.files != null && widget.files!.isNotEmpty) ||
                widget.editableMessage != null
            ? SingleChildScrollView(
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (isSingleImage())
                        imageUi(null)
                      else
                        SizedBox(
                          height: widget.editableMessage != null
                              ? 50
                              : widget.files!.length * 100.toDouble() >
                                      MediaQuery.of(context).size.height - 300
                                  ? MediaQuery.of(context).size.height - 300
                                  : widget.files!.length * 100.toDouble(),
                          width: 350,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.editableMessage != null
                                ? 1
                                : widget.files!.length,
                            itemBuilder: (c, index) {
                              return Row(
                                children: [
                                  if (isImageFile(index))
                                    buildImage(
                                      widget.files![index].path,
                                      width: 100,
                                      height: 100,
                                    )
                                  else
                                    ClipOval(
                                      child: Material(
                                        color:
                                            theme.primaryColor, // button color
                                        child: const InkWell(
                                          splashColor:
                                              Colors.blue, // inkwell color
                                          child: SizedBox(
                                            width: 30,
                                            height: 40,
                                            child: Icon(
                                              Icons.insert_drive_file,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.editableMessage != null
                                          ? _editedFile != null
                                              ? _editedFile!.name
                                              : widget.editableMessage!.json
                                                  .toFile()
                                                  .name
                                          : widget.files![index].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: buildManage(index: index),
                                  )
                                ],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 6,
                              );
                            },
                          ),
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      RawKeyboardListener(
                        focusNode: _captionFocusNode,
                        onKey: (event) {
                          if (event.physicalKey == PhysicalKeyboardKey.enter) {
                            send();
                          }
                        },
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
                            labelText: _i18n.get("caption"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.editableMessage == null)
                            GestureDetector(
                              onTap: () async {
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          if (widget.editableMessage != null)
                            const SizedBox(
                              width: 40,
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  _i18n.get("cancel"),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              GestureDetector(
                                onTap: () {
                                  send();
                                },
                                child: Text(
                                  _i18n.get("send"),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10)
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            : const SizedBox.shrink();
  }

  bool isImageFile(int index) {
    return widget.files![index].path.contains("image") ||
        widget.files![index].path.contains("jpg") ||
        widget.files![index].path.contains("png") ||
        widget.files![index].path.contains("jfif") ||
        widget.files![index].path.contains("jpeg");
  }

  Future<void> openEditImagePage(int? index) async {
    final navigatorState = Navigator.of(context);
    String? path = "";
    if (widget.files!.isEmpty && _editedFile == null) {
      path = await _fileRepo.getFileIfExist(
        _editableFile.uuid,
        _editableFile.name,
      );
    }
    if (widget.files!.isNotEmpty || _editedFile != null || path != null) {
      navigatorState.push(
        MaterialPageRoute(
          builder: (c) {
            return OpenImagePage(
              onEditEnd: (path) {
                widget.files!.isEmpty
                    ? _editedFile != null
                        ? _editedFile!.path = path
                        : _editedFile = model.File(path, path.split(".").last)
                    : index == null
                        ? widget.files!.first.path = path
                        : widget.files![index].path = path;
                Navigator.pop(context);
                setState(() {});
              },
              imagePath: widget.files!.isEmpty
                  ? _editedFile != null
                      ? _editedFile!.path
                      : path!
                  : index == null
                      ? widget.files!.first.path
                      : widget.files![index].path,
            );
          },
        ),
      ).ignore();
    }
  }

  bool isSingleImage() {
    return ((widget.editableMessage != null || widget.files!.length <= 1) &&
        (_type.contains("image") ||
            _type.contains("jpg") ||
            _type.contains("png") ||
            _type.contains("jfif") ||
            _type.contains("jpeg")));
  }

  Widget imageUi(int? index) {
    //if index==null isSingleImage
    return GestureDetector(
      onTap: () => openEditImagePage(index),
      child: SizedBox(
        height: index == null ? MediaQuery.of(context).size.height / 3 : null,
        child: Stack(
          children: [
            Center(
              child: widget.files!.isNotEmpty
                  ? buildImage(
                      index == null
                          ? widget.files!.first.path
                          : widget.files![index].path,
                    )
                  : _editedFile != null
                      ? buildImage(_editedFile!.path)
                      : FutureBuilder<String?>(
                          future: _fileRepo.getFileIfExist(
                            _editableFile.uuid,
                            _editableFile.name,
                          ),
                          builder: (c, s) {
                            if (s.hasData && s.data != null) {
                              return Image.file(File(s.data!));
                            } else {
                              return buildRow(0, showManage: false);
                            }
                          },
                        ),
            ),
            Positioned(
              right: 5,
              top: 2,
              child: Container(
                color: Colors.black12,
                child: buildManage(index: 0),
              ),
            ),
          ],
        ),
      ),
    );
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

  Row buildRow(int index, {bool showManage = true}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ClipOval(
          child: Material(
            color: theme.primaryColor, // button color
            child: const InkWell(
              splashColor: Colors.blue, // inkwell color
              child: SizedBox(
                width: 30,
                height: 40,
                child: Icon(
                  Icons.insert_drive_file,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 3,
        ),
        Expanded(
          child: Text(
            widget.files != null && widget.files!.isNotEmpty
                ? widget.files![index].name
                : _editableFile.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showManage)
          Align(alignment: Alignment.topRight, child: buildManage(index: index))
      ],
    );
  }

  Widget buildManage({required int index}) {
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
                _type = _editedFile!.extension.toString();
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

                _type = result.files.first.extension!;
              }

              setState(() {});
            }
          },
          icon: const Icon(
            Icons.wifi_protected_setup,
            color: Colors.blue,
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
            icon: const Icon(
              Icons.delete,
              color: Colors.blue,
              size: 16,
            ),
          ),
        if (widget.editableMessage == null)
          IconButton(
            onPressed: () {
              openEditImagePage(index);
            },
            icon: const Icon(
              Icons.edit,
              color: Colors.blue,
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
    return AlertDialog(
      title: Text(
        _i18n.get("error"),
        style: const TextStyle(fontSize: 16, color: Colors.blue),
      ),
      content: SizedBox(
        width: 150,
        child: Text(
          !_isFileFormatAccept
              ? "${_i18n.get("cant_sent")} $_invalidFormatFileName"
              : "$_invalidSizeFileName ${_i18n.get("file_size_error")}",
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                _i18n.get("ok"),
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
