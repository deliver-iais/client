import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowImagePage extends StatefulWidget {
  final File imageFile;
  final Uid contactUid;

  const ShowImagePage({Key key, this.imageFile, this.contactUid})
      : super(key: key);

  @override
  _ImageWidget createState() => _ImageWidget();
}

class _ImageWidget extends State<ShowImagePage> {
  TextEditingController _controller = TextEditingController();

  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            _messageRepo.sendFileMessageDeprecated(
                widget.contactUid, [widget.imageFile.path],
                caption: _controller.value.text);
            ExtendedNavigator.of(context).pop();
          },
          splashColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(widget.contactUid),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                return Text(
                  snapshot.data,
                  style: TextStyle(color: Colors.white),
                );
              } else {
                return Text(
                  "Unknown",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                );
              }
            },
          ),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image.file(widget.imageFile).image, fit: BoxFit.cover),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    minLines: 2,
                    autofocus: true,
                    maxLines: 15,
                    textInputAction: TextInputAction.newline,
                    controller: _controller,
                    decoration: InputDecoration.collapsed(
                        hintText:
                            appLocalization.getTraslateValue("typeSomeThing")),
                  ),
                ),
                SizedBox(height: 40,)
              ],
            )));
  }
}
