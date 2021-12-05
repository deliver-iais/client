import 'dart:io';
import 'dart:typed_data';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
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
  final Map<String, String>? paths;
  final Uid currentRoom;
  final Message? editableMessage;

  const ShowCaptionDialog(
      {Key? key,
      this.paths,
      this.type,
      required this.currentRoom,
      this.editableMessage})
      : super(key: key);

  @override
  _ShowCaptionDialogState createState() => _ShowCaptionDialogState();
}

class _ShowCaptionDialogState extends State<ShowCaptionDialog> {
  final _messageRepo = GetIt.I.get<MessageRepo>();

  final _i18n = GetIt.I.get<I18N>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  final TextEditingController _editingController = TextEditingController();

  late file_pb.File _editableFile;
  final List<String> _fileNames = [];
  String _type = "";
  final FocusNode _captionFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.editableMessage == null) {
      _type = widget.type!;
      for (var element in widget.paths!.keys) {
        element = element.replaceAll("\\", "/");
        _fileNames.add(element.split("/").last);
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
    return (widget.paths != null && widget.paths!.isNotEmpty) ||
            widget.editableMessage != null
        ? SingleChildScrollView(
            child: AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  (widget.editableMessage != null ||
                              widget.paths!.length <= 1) &&
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
                                  child: widget.paths!.isNotEmpty
                                      ? kIsWeb
                                          ? Image.network(
                                              widget.paths!.values.first)
                                          : Image.file(
                                              File(widget.paths!.values.first))
                                      : FutureBuilder<String?>(
                                          future: _fileRepo.getFileIfExist(
                                              _editableFile.uuid,
                                              _editableFile.name),
                                          builder: (c, s) {
                                            if (s.hasData && s.data != null) {
                                              return Image.file(File(s.data!));
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
                          height: widget.paths!.length * 50.toDouble(),
                          width: 300,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.paths!.length,
                            itemBuilder: (c, index) {
                              return Row(
                                children: [
                                  ClipOval(
                                    child: Material(
                                        color: Theme.of(context)
                                            .primaryColor, // button color
                                        child: const InkWell(
                                            splashColor:
                                                Colors.blue, // inkwell color
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
                                      _fileNames[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color:
                                              ExtraTheme.of(context).textField),
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
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        send();
                      }
                    },
                    child: TextFormField(
                        controller: _editingController,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        autofocus: true,
                        style: TextStyle(
                            fontSize: 15,
                            color: ExtraTheme.of(context).textField),
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
                                widget.paths![element.name] = element.path!;
                                _fileNames.add(isWindows()
                                    ? element.path!.split("\\").last
                                    : element.path!.split("/").last);
                              }
                            }
                            setState(() {});
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
            caption: _editingController.text,
            newFileName: _fileNames.isNotEmpty ? _fileNames[0] : "",
            newFilePath: widget.paths!.isNotEmpty ? widget.paths![0] : null)
        : _messageRepo.sendMultipleFilesMessages(
            widget.currentRoom, widget.paths!,
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
            _fileNames.isNotEmpty ? _fileNames[index] : _editableFile.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ExtraTheme.of(context).textField),
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

              if (result != null && result.paths.isNotEmpty) {
                String p = isWindows()
                    ? result.paths[0]!.split("\\").last
                    : result.paths[0]!.split("/").last;
                _fileNames.isNotEmpty
                    ? _fileNames[index] = p
                    : _fileNames.add(p);
                if (widget.paths != null) {
                  widget.paths!.remove(widget.paths!.keys.toList()[index]);
                }
                widget.paths![result.files.first.name] = kIsWeb
                    ? Uri.dataFromBytes(result.files.first.bytes!.toList())
                        .toString()
                    : result.files.first.path!;

                // widget.paths!.isNotEmpty
                //     ? widget.paths![index] = result.paths[0]!
                //     : widget.paths!.add(result.paths[0]!);
                _type = result.paths.first!.split(".").last;
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
                widget.paths!.remove(widget.paths!.keys.toList()[index]);
                _fileNames.removeAt(index);
                if (widget.paths == null || widget.paths!.isEmpty) {
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
    return result;
  }
}
