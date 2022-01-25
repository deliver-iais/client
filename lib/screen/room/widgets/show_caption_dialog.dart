import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class ShowCaptionDialog extends StatefulWidget {
  final String? type;
  final List<model.File>? files;
  final Uid currentRoom;
  final Message? editableMessage;
  final bool showSelectedImage;

  const ShowCaptionDialog(
      {Key? key,
      this.files,
      this.type,
      required this.currentRoom,
      this.showSelectedImage = false,
      this.editableMessage})
      : super(key: key);

  @override
  _ShowCaptionDialogState createState() => _ShowCaptionDialogState();
}

class _ShowCaptionDialogState extends State<ShowCaptionDialog> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _fileService = GetIt.I.get<FileService>();
  final _i18n = GetIt.I.get<I18N>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  final TextEditingController _editingController = TextEditingController();

  late file_pb.File _editableFile;
  String _type = "";
  final FocusNode _captionFocusNode = FocusNode();
  bool _isFileFormatAccept = false;
  model.File? _editedFile;
  String _invalidFormatFileName = "";

  @override
  void initState() {
    _isFileFormatAccept = widget.editableMessage != null;
    if (widget.editableMessage == null) {
      _type = widget.type!;
      for (var element in widget.files!) {
        element.path = element.path.replaceAll("\\", "/");
        _isFileFormatAccept = _fileService.isFileFormatAccepted(
            element.extension ?? element.name.split(".").last);
        if (!_isFileFormatAccept) {
          _invalidFormatFileName = element.name;
          break;
        }
      }
    } else {
      _editableFile = widget.editableMessage!.json!.toFile();
      _editingController.text = _editableFile.caption;
      _type = _editableFile.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !_isFileFormatAccept
        ? AlertDialog(
            title: Text(
              _i18n.get("error"),
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            content: Text(
              _i18n.get("cant_sent") + " " + _invalidFormatFileName,
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
          )
        : (widget.files != null && widget.files!.isNotEmpty) ||
                widget.editableMessage != null
            ? SingleChildScrollView(
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      (widget.editableMessage != null ||
                                  widget.files!.length <= 1) &&
                              (_type.contains("image") ||
                                  _type.contains("jpg") ||
                                  _type.contains("png") ||
                                  _type.contains("jfif") ||
                                  _type.contains("jpeg"))
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              child: Stack(
                                children: [
                                  Center(
                                      child: widget.files!.isNotEmpty
                                          ? kIsWeb
                                              ? Image.network(
                                                  widget.files!.first.path)
                                              : Image.file(File(
                                                  widget.files!.first.path))
                                          : _editedFile != null
                                              ? Image.file(
                                                  File(_editedFile!.path))
                                              : FutureBuilder<String?>(
                                                  future:
                                                      _fileRepo.getFileIfExist(
                                                          _editableFile.uuid,
                                                          _editableFile.name),
                                                  builder: (c, s) {
                                                    if (s.hasData &&
                                                        s.data != null) {
                                                      return Image.file(
                                                          File(s.data!));
                                                    } else {
                                                      return buildRow(0,
                                                          showManage: false);
                                                    }
                                                  })),
                                  Positioned(
                                      right: 5,
                                      top: 2,
                                      child: Container(
                                          color: Colors.black12,
                                          child: buildManage(index: 0))),
                                ],
                              ))
                          : SizedBox(
                              height: widget.editableMessage != null
                                  ? 50
                                  : widget.files!.length * 50.toDouble(),
                              width: 300,
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: widget.editableMessage != null
                                    ? 1
                                    : widget.files!.length,
                                itemBuilder: (c, index) {
                                  return Row(
                                    children: [
                                      ClipOval(
                                        child: Material(
                                            color: Theme.of(context)
                                                .primaryColor, // button color
                                            child: const InkWell(
                                                splashColor: Colors
                                                    .blue, // inkwell color
                                                child: SizedBox(
                                                  width: 30,
                                                  height: 40,
                                                  child: Icon(
                                                    Icons.insert_drive_file,
                                                    size: 20,
                                                  ),
                                                ))),
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      Expanded(
                                        child: Text(
                                          widget.editableMessage != null
                                              ? _editedFile != null
                                                  ? _editedFile!.name
                                                  : widget
                                                      .editableMessage!.json!
                                                      .toFile()
                                                      .name
                                              : widget.files![index].name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      Align(
                                          alignment: Alignment.topRight,
                                          child: buildManage(index: index))
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
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
                        child: TextFormField(
                            controller: _editingController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            autofocus: true,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black),
                            decoration: InputDecoration(
                              labelText: _i18n.get("caption"),
                            )),
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
                                FilePickerResult? res =
                                    await getFile(allowMultiple: true);
                                if (res != null) {
                                  for (var element in res.files) {
                                    widget.files!.add(model.File(
                                        kIsWeb
                                            ? Uri.dataFromBytes(
                                                    element.bytes!.toList())
                                                .toString()
                                            : element.path!,
                                        element.name,
                                        extension: element.extension,
                                        size: element.size));
                                  }
                                  setState(() {});
                                }
                              },
                              child: Text(
                                _i18n.get("add"),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blue),
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
                                      color: Colors.blue, fontSize: 15),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              GestureDetector(
                                  onTap: () {
                                    send();
                                  },
                                  child: Text(_i18n.get("send"),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 16))),
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

  void send() {
    Navigator.pop(context);
    widget.editableMessage != null
        ? _messageRepo.editFileMessage(
            widget.editableMessage!.roomUid.asUid(), widget.editableMessage!,
            caption: _editingController.text, file: _editedFile)
        : _messageRepo.sendMultipleFilesMessages(
            widget.currentRoom, widget.files!,
            caption: _editingController.text.toString());
  }

  Row buildRow(int index, {bool showManage = true}) {
    return Row(
      children: [
        ClipOval(
          child: Material(
              color: Theme.of(context).primaryColor, // button color
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
                  ))),
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
              FilePickerResult? result = await getFile(allowMultiple: false);

              if (result != null && result.files.isNotEmpty) {
                if (widget.editableMessage != null) {
                  _editedFile = model.File(
                      kIsWeb
                          ? Uri.dataFromBytes(
                              result.files.first.bytes!.toList(),
                            ).toString()
                          : result.files.first.path!,
                      result.files.first.name,
                      extension: result.files.first.extension,
                      size: result.files.first.size);
                  _type = _editedFile!.extension.toString();
                } else {
                  widget.files![index] = model.File(
                      kIsWeb
                          ? Uri.dataFromBytes(
                              result.files.first.bytes!.toList(),
                            ).toString()
                          : result.files.first.path!,
                      result.files.first.name,
                      extension: result.files.first.extension,
                      size: result.files.first.size);

                  _type = result.files.first.extension!;
                }

                setState(() {});
              }
            },
            icon: const Icon(
              Icons.wifi_protected_setup,
              color: Colors.blue,
              size: 16,
            )),
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
              ))
      ],
    );
  }

  Future<FilePickerResult?> getFile({required bool allowMultiple}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
    );
    for (var element in result!.files) {
      _isFileFormatAccept =
          _fileService.isFileFormatAccepted(element.extension ?? element.name);
      if (!_isFileFormatAccept) {
        _invalidFormatFileName = element.name;
        break;
      }
    }
    if (_isFileFormatAccept) {
      return result;
    } else {
      ToastDisplay.showToast(
          toastText: _i18n.get("cant_sent") + " " + _invalidFormatFileName,
          tostContext: context);
      return null;
    }
  }
}
