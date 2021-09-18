import 'dart:io';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/methods/platform.dart';

class ShowCaptionDialog extends StatefulWidget {
  final List<String> paths;
  final String type;
  final Uid currentRoom;

  ShowCaptionDialog({Key key, this.paths, this.type, this.currentRoom})
      : super(key: key);

  @override
  _ShowCaptionDialogState createState() => _ShowCaptionDialogState();
}

class _ShowCaptionDialogState extends State<ShowCaptionDialog> {
  final _messageRepo = GetIt.I.get<MessageRepo>();

  final _i18n = GetIt.I.get<I18N>();

  final TextEditingController _editingController = TextEditingController();

  List<String> fileNames = [];
  String type = "";

  @override
  void initState() {
    type = widget.type;
    widget.paths.forEach((element) {
      if(isWindows() && element.contains("\\"))
        element = element.replaceAll("\\", "/");
      fileNames.add(element.split("/").last);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.paths != null && widget.paths.length > 0
        ? SingleChildScrollView(
            child: Container(
                child: AlertDialog(
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  widget.paths.length <= 1 &&
                          type != null &&
                          (type.contains("image") ||
                              type.contains("jpg") ||
                              type.contains("png") ||
                              type.contains("jfif"))
                      ? Container(
                          height: MediaQuery.of(context).size.height / 3,
                          child: Stack(
                            children: [
                              Center(
                                  child: Image.file(File(widget.paths.first))),
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
                                      fileNames[index],
                                      overflow: TextOverflow.ellipsis,
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
                  TextFormField(
                      controller: _editingController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      style: TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: _i18n.get("caption"),
                      )),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                _messageRepo.sendMultipleFilesMessages(
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

  Widget buildManage({int index}) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              FilePickerResult result = await getFile(allowMultiple: false);
              if (result.paths != null && result.paths.length > 0) {
                fileNames[index] = isWindows()
                    ? result.paths[0].split("\\").last
                    : result.paths[0].split("/").last;
                widget.paths[index] = result.paths[0];
                type = result.paths.first.split(".").last;
                setState(() {});
              }
            },
            icon: Icon(
              Icons.wifi_protected_setup,
              color: Colors.blue,
              size: 16,
            )),
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
          'rar'
        ]);
    return result;
  }
}
