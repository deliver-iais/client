import 'dart:io';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:we/localization/i18n.dart';
import 'package:we/repository/messageRepo.dart';
import 'package:flutter/material.dart';

class ShowCaptionDialog extends StatelessWidget {
  final List<String> paths;
  final String type;
  final Uid currentRoom;

  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final TextEditingController _editingController = TextEditingController();

  ShowCaptionDialog({Key key, this.paths, this.type, this.currentRoom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Stack(children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                paths.length <= 1 &&
                        (type.contains("image") || type.contains("jpg"))
                    ? Container(
                        height: MediaQuery.of(context).size.height / 3,
                        child: Center(child: Image.file(File(paths.first))),
                      )
                    : Container(
                        height: paths.length * 50.toDouble(),
                        width: 200,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: paths.length,
                          itemBuilder: (c, i) {
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
                                    paths[i].split("/").last,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
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
          ]),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text(
                _i18n.get("cancel"),
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _messageRepo.sendMultipleFilesMessages(currentRoom, paths,
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
        ),
      ),
    );
  }
}
