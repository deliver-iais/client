import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/header_details.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/methods/isPersian.dart';

class MessageHeader extends StatefulWidget {
  final Message message;
  final double maxWidth;

  const MessageHeader({Key key, this.message, this.maxWidth}) : super(key: key);
  @override
  _MessageHeaderState createState() => _MessageHeaderState();
}

class _MessageHeaderState extends State<MessageHeader> {
  File file;
  String loadStatus = 'loaded';
  double loadProgress = 0.0;
  @override
  void initState() {
    super.initState();
    // loadData();
    file = widget.message.json.toFile();
  }

  loadData() {
    Future.delayed(Duration(seconds: 3)).whenComplete(() {
      setState(() {
        loadStatus = 'loading';
        loadProgress = 0.1;
      });
    }).then((value) =>
        Future.delayed(Duration(milliseconds: 1000)).whenComplete(() {
          setState(() {
            loadProgress = 0.3;
          });
        }).then((value) => Future.delayed(Duration(milliseconds: 1000))
            .whenComplete(() {
              setState(() {
                loadProgress = 0.6;
              });
            })
            .then((value) =>
                Future.delayed(Duration(milliseconds: 1000)).whenComplete(() {
                  setState(() {
                    loadProgress = 0.9;
                  });
                }))
            .then((value) =>
                Future.delayed(Duration(milliseconds: 1000)).whenComplete(() {
                  setState(() {
                    loadProgress = 1;
                    loadStatus = 'loaded';
                  });
                }))));
  }

  changeStatus(String newStatus) {
    setState(() {
      loadStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: file.name.isPersian()
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        LoadFileStatus(
          file: file,
          dbId: widget.message.dbId,
          changeStatus: changeStatus,
          loadStatus: loadStatus,
          loadProgress: loadProgress,
        ),
        Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Container(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        file.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            HeaderDetails(
                loadStatus: loadStatus, loadProgress: loadProgress, file: file),
          ],
        ),
      ],
    );
  }
}
