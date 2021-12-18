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

// TODO Needs to be refactored. WTF WTF WTF!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
class LoadFileStatus extends StatefulWidget {
  final String fileId;
  final String fileName;
  final int? messageId;
  final String? messagePacketId; // TODO Needs to be refactored
  final String? roomUid;
  final Function onPressed;

  const LoadFileStatus(
      {Key? key,
      required this.fileId,
      required this.fileName,
      this.messageId,
      this.messagePacketId,
      this.roomUid,
      required this.onPressed})
      : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}

class _LoadFileStatusState extends State<LoadFileStatus> {
  bool _startDownload = false;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _fileService = GetIt.I.get<FileService>();
  bool isPendingMes = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PendingMessage?>(
        stream: _messageRepo.watchPendingMessage(widget.messagePacketId!),
        builder: (context, pendingMessage) {
          isPendingMes = pendingMessage.hasData && pendingMessage.data != null;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: <Widget>[
                  pendingMessage.data != null
                      ? pendingMessage.data!.status ==
                              SendingStatus.SENDING_FILE
                          ? StreamBuilder<double?>(
                              stream:
                                  _fileService.filesUploadStatus[widget.fileId],
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
                                              _messageRepo.deletePendingMessage(
                                                  widget.messagePacketId!);
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
                  if (!isPendingMes)
                    _startDownload
                        ? StreamBuilder<double>(
                            stream:
                                _fileService.filesDownloadStatus[widget.fileId],
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data != null &&
                                  snapshot.data! > 0) {
                                return CircularPercentIndicator(
                                  radius: 45.0,
                                  lineWidth: 4.0,
                                  percent: snapshot.data!,
                                  backgroundColor:
                                      ExtraTheme.of(context).circularFileStatus,
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
                                            _fileService
                                                .cancelTokens[widget.fileId]!
                                                .add(null);
                                          },
                                        );
                                      } else {
                                        return Icon(
                                          Icons.arrow_downward,
                                          color: ExtraTheme.of(context)
                                              .fileMessageDetails,
                                          size: 35,
                                        );
                                      }
                                    },
                                  ),
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
                                  backgroundColor:
                                      ExtraTheme.of(context).circularFileStatus,
                                  progressColor:
                                      ExtraTheme.of(context).fileMessageDetails,
                                );
                              }
                            })
                        : Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    ExtraTheme.of(context).circularFileStatus),
                            child: pendingMessage.data != null
                                ? const SizedBox.shrink()
                                : IconButton(
                                    padding: const EdgeInsets.all(0),
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
                          )
                ],
              ),
            ],
          );
        });
    //TODO animation to change icon????
  }
}
