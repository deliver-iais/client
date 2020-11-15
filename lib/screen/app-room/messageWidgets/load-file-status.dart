import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

import 'audio_message/play_audio_status.dart';

class LoadFileStatus extends StatefulWidget {
  final File file;
  final int dbId;
  final Function onPressed;

  const LoadFileStatus({Key key, this.file, this.dbId, this.onPressed})
      : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}

class _LoadFileStatusState extends State<LoadFileStatus> {
  bool startDownload = false;
  PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var fileService = GetIt.I.get<FileService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PendingMessage>(
        stream: pendingMessageDao.getByMessageDbId(widget.dbId),
        builder: (context, pendingMessage) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: <Widget>[
                  pendingMessage.data != null
                      ? pendingMessage.data.status == SendingStatus.SENDING_FILE
                          ? StreamBuilder<double>(
                              stream: fileService
                                  .filesUploadStatus[widget.file.uuid],
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CircularPercentIndicator(
                                    radius: 55.0,
                                    lineWidth: 4.0,
                                    percent: snapshot.data,
                                    progressColor: Colors.black,
                                  );
                                } else {
                                  return CircularPercentIndicator(
                                    radius: 55.0,
                                    lineWidth: 4.0,
                                    percent: 0.01,
                                    progressColor: Colors.black,
                                  );
                                }
                              })
                          : SendingFileCircularIndicator(
                              loadProgress: 0.9,
                              isMedia: false,
                            )
                      : Container(),
                  startDownload
                      ? Container(
                          child: StreamBuilder<double>(
                              stream: fileService
                                  .filesDownloadStatus[widget.file.uuid],
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return CircularPercentIndicator(
                                    radius: 45.0,
                                    lineWidth: 4.0,
                                    percent: snapshot.data,
                                    progressColor: Colors.blue,
                                  );
                                } else {
                                  return CircularPercentIndicator(
                                    radius: 45.0,
                                    lineWidth: 4.0,
                                    percent: 0.1,
                                    progressColor: Colors.blue,
                                  );
                                  ;
                                }
                              }))
                      : Padding(
                          padding: EdgeInsets.only(left: 5, top: 7),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ExtraTheme.of(context).text),
                            child: pendingMessage.data != null
                                ? IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.arrow_upward,
                                      color: Theme.of(context).primaryColor,
                                      size: 33,
                                    ),
                                    onPressed: () {},
                                  )
                                : IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    icon: Icon(
                                      Icons.arrow_downward,
                                      color: Theme.of(context).primaryColor,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        startDownload = true;
                                      });
                                      widget.onPressed(
                                          widget.file.uuid, widget.file.name);
                                    },
                                  ),
                          ),
                        )
                ],
              ),
            ],
          );
        });
    //TODO animation to change icon????
  }
}
