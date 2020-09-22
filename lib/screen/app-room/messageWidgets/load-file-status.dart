import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoadFileStatus extends StatefulWidget {
  final File file;
  final int dbId;
  final Function onPressed;
  LoadFileStatus({Key key, this.file, this.dbId, this.onPressed})
      : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}

class _LoadFileStatusState extends State<LoadFileStatus> {
  @override
  Widget build(BuildContext context) {
    PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();
    return StreamBuilder<List<PendingMessage>>(
        stream: pendingMessageDao.getByMessageId(widget.dbId),
        builder: (context, pendingMessage) {
          if (pendingMessage.hasData) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  children: <Widget>[
                    pendingMessage.data.length != 0
                        ? pendingMessage.data[0].status ==
                                SendingStatus.SENDING_FILE
                            ? SendingFileCircularIndicator(
                                loadProgress: 0.5,
                                isMedia: false,
                              )
                            : SendingFileCircularIndicator(
                                loadProgress: 0.9,
                                isMedia: false,
                              )
                        : Container(),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ExtraTheme.of(context).text),
                      child: pendingMessage.data.length == 0
                          ? IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(
                                Icons.file_download,
                                color: Theme.of(context).primaryColor,
                                size: 33,
                              ),
                              onPressed: () {
                                widget.onPressed(
                                    widget.file.uuid, widget.file.name);
                              },
                            )
                          : IconButton(
                        padding: EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return CircularProgressIndicator();
          }
        });
    //TODO animation to change icon????
  }
}
