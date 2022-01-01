import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShowImagePage extends StatefulWidget {
  final File imageFile;
  final Uid roomUid;

  const ShowImagePage(
      {Key? key, required this.imageFile, required this.roomUid})
      : super(key: key);

  @override
  _ImageWidget createState() => _ImageWidget();
}

class _ImageWidget extends State<ShowImagePage> {
  final TextEditingController _controller = TextEditingController();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            _messageRepo.sendMultipleFilesMessages(
                widget.roomUid,
                [
                  model.File(widget.imageFile.path,
                      widget.imageFile.path.split(".").last)
                ],
                caption: _controller.value.text);
            _routingServices.pop();
          },
          splashColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          title: FutureBuilder<String>(
            future: _roomRepo.getName(widget.roomUid),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                return Text(
                  snapshot.data!,
                  style: const TextStyle(color: Colors.white),
                );
              } else {
                return Text(
                  "Unknown",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                );
              }
            },
          ),
          leading: _routingServices.backButtonLeading(context),
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
                    style: const TextStyle(color: Colors.black),
                    maxLines: 15,
                    textInputAction: TextInputAction.newline,
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: i18n.get("typeSomeThing")),
                  ),
                ),
                const SizedBox(height: 40)
              ],
            )));
  }
}
