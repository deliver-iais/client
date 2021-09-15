import 'dart:io';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:we/localization/i18n.dart';
import 'package:we/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:we/shared/methods/platform.dart';

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

  @override
  void initState() {
    widget.paths.forEach((element) {
      fileNames.add(element.split("/").last);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.paths.length <= 1 &&
                      (widget.type.contains("image") ||
                          widget.type.contains("jpg"))
                  ? Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child:
                          Center(child: Image.file(File(widget.paths.first))),
                    )
                  : Container(
                      height: widget.paths.length * 50.toDouble(),
                      width: MediaQuery.of(context).size.width / 4,
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
                                  child: Row(
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            FilePickerResult result =
                                                await getFile(false);
                                            if (result.paths != null &&
                                                result.paths.length > 0) {
                                              fileNames[index] = isWindows()
                                                  ? result.paths[0]
                                                      .split("\\")
                                                      .last
                                                  : result.paths[0]
                                                      .split("/")
                                                      .last;
                                              widget.paths[index] =
                                                  result.paths[0];
                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(
                                            Icons.wifi_protected_setup,
                                            size: 17,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            widget.paths.removeAt(index);
                                            setState(() {});
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            size: 17,
                                          ))
                                    ],
                                  ))
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                            height: 5,
                          );
                        },
                      ),
                    ),
              SizedBox(
                height: 10,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    var res = await getFile(true);
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
                    style: TextStyle(fontSize: 18, color: Colors.blue),
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
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _messageRepo.sendMultipleFilesMessages(
                              widget.currentRoom, widget.paths,
                              caption: _editingController.text.toString());
                        },
                        child: Text(
                          _i18n.get("send"),
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        )),
                    SizedBox(
                      width: 10,
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<FilePickerResult> getFile(bool allowMultiple) async {
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
