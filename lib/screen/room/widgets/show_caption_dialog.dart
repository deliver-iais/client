import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as P;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class ShowCaptionDialog extends StatefulWidget {
  final List<String> paths;
  final String type;
  final Uid currentRoom;
  final Message editableMessage;

  ShowCaptionDialog(
      {Key key, this.paths, this.type, this.currentRoom, this.editableMessage})
      : super(key: key);

  @override
  _ShowCaptionDialogState createState() => _ShowCaptionDialogState();
}

class _ShowCaptionDialogState extends State<ShowCaptionDialog> {
  final _messageRepo = GetIt.I.get<MessageRepo>();

  final _i18n = GetIt.I.get<I18N>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  final TextEditingController _editingController = TextEditingController();

  List<String> fileNames = [];
  String type = "";
  P.File _editableFile;
  List<String> _fileNames = [];
  String _type = "";
  FocusNode _captionFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.editableMessage == null) {
      type = widget.type;
      widget.paths.forEach((element) {
        element = element.replaceAll("\\", "/");
        fileNames.add(element.split("/").last);
      });
    } else {
      _editableFile = widget.editableMessage.json.toFile();
      _editingController.text = _editableFile.caption ?? "";
      type = _editableFile.type;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (widget.paths != null && widget.paths.length > 0) ||
            widget.editableMessage != null
        ? SingleChildScrollView(
            child: Container(
                child: AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  (widget.editableMessage != null ||
                              widget.paths.length <= 1) &&
                          type != null &&
                          (type.contains("image") ||
                              type.contains("jpg") ||
                              type.contains("png") ||
                              type.contains("jfif") ||
                              type.contains("jpeg"))
                      ? Container(
                          height: MediaQuery.of(context).size.height / 3,
                          child: Stack(
                            children: [
                              Center(
                                  child: widget.paths.length > 0
                                      ? Image.file(File(widget.paths.first))
                                      : FutureBuilder<File>(
                                          future: _fileRepo.getFileIfExist(
                                              _editableFile.uuid,
                                              _editableFile.name),
                                          builder: (c, s) {
                                            if (s.hasData && s.data != null) {
                                              return Image.file(s.data);
                                            } else
                                              return buildRow(0,showManage: false);
                                          })),
                              Positioned(
                                  right: 5,
                                  top: 2,
                                  child: Container(
                                      color: Colors.black12,
                                      child: buildManage(index: 0))),
                            ],
                          ))
                      : Container(
                          height: widget.paths.length * 50.toDouble(),
                          width: 300,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.paths.length,
                            itemBuilder: (c, index) {
                              return Row(
                                children: [
                                  ClipOval(
                                    child: Material(
                                        color: Theme.of(context)
                                            .primaryColor, // button color
                                        child: InkWell(
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
                                  SizedBox(
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
                              return SizedBox(
                                height: 6,
                              );
                            },
                          ),
                        ),
                  SizedBox(
                    height: 5,
                  ),
                  RawKeyboardListener(
                    focusNode: _captionFocusNode,
                    onKey: (event) {
                      if (event.logicalKey == LogicalKeyboardKey.enter) {
                        sendMessages();
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
                            var res = await getFile(allowMultiple: true);
                            res.paths.forEach((element) {
                              widget.paths.add(element);
                              fileNames.add(isWindows()
                                  ? element.split("\\").last
                                  : element.split("/").last);
                            });
                            setState(() {});
                          },
                          child: Text(
                            _i18n.get("add"),
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      if (widget.editableMessage != null)
                        SizedBox(
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
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                widget.editableMessage != null
                                    ? _messageRepo.editFileMessage(
                                        widget.editableMessage.roomUid.asUid(),
                                        widget.editableMessage,
                                        caption: _editingController.text,
                                        newFileName: fileNames.length > 0
                                            ? fileNames[0]
                                            : "",
                                        newFilePath: widget.paths.length > 0
                                            ? widget.paths[0]
                                            : null)
                                    : _messageRepo.sendMultipleFilesMessages(
                                        widget.currentRoom, widget.paths,
                                        caption:
                                            _editingController.text.toString());
                              },
                              child: Text(
                                _i18n.get("send"),
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              )),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
          )
        : SizedBox.shrink();
  }

  Row buildRow(int index, {bool showManage = true}) {
    return Row(
      children: [
        ClipOval(
          child: Material(
              color: Theme.of(context).primaryColor, // button color
              child: InkWell(
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
        SizedBox(
          width: 3,
        ),
        Expanded(
          child: Text(
            fileNames.isNotEmpty && fileNames[index] != null
                ? fileNames[index]
                : _editableFile.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ExtraTheme.of(context).textField),
          ),
        ),
        if (showManage)
          Align(alignment: Alignment.topRight, child: buildManage(index: index))
      ],
    );
  }

  Widget buildManage({int index}) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              FilePickerResult result = await getFile(allowMultiple: false);
              if (result.paths != null && result.paths.length > 0) {
                String p = isWindows()
                    ? result.paths[0].split("\\").last
                    : result.paths[0].split("/").last;
                fileNames.isNotEmpty ? fileNames[index] = p : fileNames.add(p);
                widget.paths.isNotEmpty
                    ? widget.paths[index] = result.paths[0]
                    : widget.paths.add(result.paths[0]);
                type = result.paths.first.split(".").last;
                setState(() {});
              }
            },
            icon: Icon(
              Icons.wifi_protected_setup,
              color: Colors.blue,
              size: 16,
            )),
        if (widget.editableMessage == null)
          IconButton(
              onPressed: () {
                widget.paths.removeAt(index);
                fileNames.removeAt(index);
                if (widget.paths == null || widget.paths.length == 0)
                  Navigator.pop(context);
                setState(() {});
              },
              icon: Icon(
                Icons.delete,
                color: Colors.blue,
                size: 16,
              ))
      ],
    );
  }

  Future<FilePickerResult> getFile({bool allowMultiple}) async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.custom,
        allowedExtensions: [
          "pdf",
          "mp4",
          "pptx",
          "docx",
          "xlsx",
          'png',
          'jpg',
          'jpeg',
          'gif',
          'rar',
          'txt'
        ]);
    return result;
  }
}
