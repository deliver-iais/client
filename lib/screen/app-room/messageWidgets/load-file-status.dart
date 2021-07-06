import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/sending_status.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// TODO Needs to be refactored. WTF WTF WTF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
class LoadFileStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final int messageId;
  final String messagePacketId; // TODO Needs to be refactored
  final String roomUid;
  final Function onPressed;

  const LoadFileStatus(
      {Key key,
      this.fileId,
      this.fileName,
      this.messageId,
      this.messagePacketId,
      this.roomUid,
      this.onPressed})
      : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}

class _LoadFileStatusState extends State<LoadFileStatus> {
  bool _startDownload = false;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _fileService = GetIt.I.get<FileService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PendingMessage>(
        stream: _messageRepo.watchPendingMessage(widget.messagePacketId),
        builder: (context, pendingMessage) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: <Widget>[
                  pendingMessage.data != null
                      ? pendingMessage.data.status == SendingStatus.SENDING_FILE
                          ? StreamBuilder<double>(
                              stream:
                                  _fileService.filesUploadStatus[widget.fileId],
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return CircularPercentIndicator(
                                    radius: 55.0,
                                    lineWidth: 4.0,
                                    percent: snapshot.data,
                                    backgroundColor: ExtraTheme.of(context)
                                        .circularFileStatus,
                                    progressColor: ExtraTheme.of(context)
                                        .fileMessageDetails,
                                  );
                                } else {
                                  return CircularPercentIndicator(
                                    radius: 55.0,
                                    lineWidth: 4.0,
                                    percent: 0.01,
                                    backgroundColor: ExtraTheme.of(context)
                                        .circularFileStatus,
                                    progressColor: ExtraTheme.of(context)
                                        .fileMessageDetails,
                                  );
                                }
                              })
                          : SendingFileCircularIndicator(
                              loadProgress: 0.9,
                              isMedia: false,
                            )
                      : Container(),
                  _startDownload
                      ? Container(
                          child: StreamBuilder<double>(
                              stream: _fileService
                                  .filesDownloadStatus[widget.fileId],
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  return CircularPercentIndicator(
                                    radius: 45.0,
                                    lineWidth: 4.0,
                                    percent: snapshot.data,
                                    backgroundColor: ExtraTheme.of(context)
                                        .circularFileStatus,
                                    center: Icon(Icons.arrow_downward,
                                        color: ExtraTheme.of(context)
                                            .fileMessageDetails),
                                    progressColor: ExtraTheme.of(context)
                                        .fileMessageDetails,
                                  );
                                } else {
                                  return CircularPercentIndicator(
                                    radius: 45.0,
                                    lineWidth: 4.0,
                                    percent: 0.1,
                                    center: Icon(
                                      Icons.arrow_downward,
                                      color: ExtraTheme.of(context)
                                          .fileMessageDetails,
                                    ),
                                    backgroundColor: ExtraTheme.of(context)
                                        .circularFileStatus,
                                    progressColor: ExtraTheme.of(context)
                                        .fileMessageDetails,
                                  );
                                }
                              }))
                      : Padding(
                          padding: EdgeInsets.only(left: 3, top: 4),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    ExtraTheme.of(context).circularFileStatus),
                            child: pendingMessage.data != null
                                ? IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: Icon(
                                      Icons.arrow_upward,
                                      color: ExtraTheme.of(context)
                                          .fileMessageDetails,
                                      size: 33,
                                    ),
                                    onPressed: () {},
                                  )
                                : IconButton(
                                    padding: EdgeInsets.all(0),
                                    alignment: Alignment.center,
                                    icon: Icon(
                                      Icons.arrow_downward,
                                      color: ExtraTheme.of(context)
                                          .fileMessageDetails,
                                      size: 35,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _startDownload = true;
                                      });
                                      widget.onPressed(
                                          widget.fileId, widget.fileName);
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
