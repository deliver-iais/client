import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rxdart/rxdart.dart';

class LoadFileStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final String? messagePacketId; // TODO Needs to be refactored
  final String? roomUid;
  final Function onPressed;

  const LoadFileStatus(
      {Key? key,
      required this.fileId,
      required this.fileName,
      this.messagePacketId,
      this.roomUid,
      required this.onPressed})
      : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}



class _LoadFileStatusState extends State<LoadFileStatus> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _fileService = GetIt.I.get<FileService>();
  bool isPendingMes = true;
  final BehaviorSubject<bool> _starDownload = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    if (widget.messagePacketId != null) {
      return StreamBuilder<PendingMessage?>(
          stream: _messageRepo.watchPendingMessage(widget.messagePacketId!),
          builder: (context, pendingMessage) {
            isPendingMes =
                pendingMessage.hasData && pendingMessage.data != null;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Stack(
                  children: <Widget>[
                    pendingMessage.data != null
                        ? pendingMessage.data!.status ==
                                SendingStatus.SENDING_FILE
                            ? StreamBuilder<double?>(
                                stream: _fileService
                                    .filesProgressBarStatus[widget.fileId],
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return CircularPercentIndicator(
                                      radius: 45.0,
                                      lineWidth: 4.0,
                                      center: StreamBuilder<CancelToken?>(
                                        stream: _fileService
                                            .cancelTokens[widget.fileId],
                                        builder: (c, s) {
                                          if (s.hasData && s.data != null) {
                                            return GestureDetector(
                                              child: const Icon(
                                                Icons.cancel,
                                                size: 35,
                                              ),
                                              onTap: () {
                                                s.data!.cancel();
                                                _messageRepo
                                                    .deletePendingMessage(widget
                                                        .messagePacketId!);
                                              },
                                            );
                                          } else {
                                            return Icon(
                                              Icons.arrow_upward,
                                              color: ExtraTheme.of(context)
                                                  .fileMessageDetails,
                                              size: 35,
                                            );
                                          }
                                        },
                                      ),
                                      percent: snapshot.data!,
                                      backgroundColor: ExtraTheme.of(context)
                                          .circularFileStatus,
                                      progressColor: ExtraTheme.of(context)
                                          .fileMessageDetails,
                                    );
                                  } else {
                                    return CircularPercentIndicator(
                                      radius: 45.0,
                                      lineWidth: 4.0,
                                      center: IconButton(
                                        padding: const EdgeInsets.all(0),
                                        icon: Icon(
                                          Icons.arrow_upward,
                                          color: ExtraTheme.of(context)
                                              .fileMessageDetails,
                                          size: 35,
                                        ),
                                        onPressed: () {},
                                      ),
                                      percent: 0.01,
                                      backgroundColor: ExtraTheme.of(context)
                                          .circularFileStatus,
                                      progressColor: ExtraTheme.of(context)
                                          .fileMessageDetails,
                                    );
                                  }
                                })
                            : const SendingFileCircularIndicator(
                                loadProgress: 0.9,
                                isMedia: false,
                              )
                        : Container(),
                    if (!isPendingMes) buildDownload()
                  ],
                ),
              ],
            );
          });
    } else {
      return buildDownload();
    }
    //TODO animation to change icon????
  }

  Widget buildDownload() {
    return StreamBuilder<double>(
        stream: _fileService.filesProgressBarStatus[widget.fileId],
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null && snapshot.data! > 0) {
            return CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 4.0,
              percent: snapshot.data!,
              backgroundColor: ExtraTheme.of(context).circularFileStatus,
              center: StreamBuilder<CancelToken?>(
                stream: _fileService.cancelTokens[widget.fileId],
                builder: (c, s) {
                  if (s.hasData && s.data != null) {
                    return GestureDetector(
                      child: const Icon(
                        Icons.cancel,
                        size: 35,
                      ),
                      onTap: () {
                        _starDownload.add(false);
                        s.data!.cancel();
                        _fileService.cancelTokens[widget.fileId]!.add(null);
                      },
                    );
                  } else {
                    return StreamBuilder<bool>(
                      stream:_starDownload.stream,
                      builder: (context, snapshot) {
                        if(snapshot.hasData && snapshot.data != null && snapshot.data!){
                          return const CircularProgressIndicator(strokeWidth: 4,color: Colors.blue,);
                        }else{
                           return GestureDetector(
                              onTap: () {
                                _starDownload.add(true);
                                widget.onPressed();
                              },
                              child: Icon(
                                Icons.arrow_downward,
                                color: ExtraTheme.of(context).fileMessageDetails,
                                size: 35,
                              ));
                        }
                      }
                    );
                  }
                },
              ),
            );
          } else {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ExtraTheme.of(context).circularFileStatus),
              child: StreamBuilder<bool>(
                  stream:_starDownload.stream,
                  builder: (context, snapshot) {
                    if(snapshot.hasData && snapshot.data != null && snapshot.data!){
                      return const CircularProgressIndicator(strokeWidth: 4,color: Colors.blue,);
                    }else{
                      return  IconButton(
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_downward,
                          color: ExtraTheme.of(context).fileMessageDetails,
                          size: 35,
                        ),
                        onPressed: () {
                          _starDownload.add(true);
                          widget.onPressed();
                        },
                      );
                    }
                  }
              )

            );
          }
        });
  }
}
