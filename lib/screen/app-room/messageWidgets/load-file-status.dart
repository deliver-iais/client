import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';

class LoadFileStatus extends StatefulWidget {
  final File file;
  final int dbId;
  final Function changeStatus;
  final String loadStatus;
  final double loadProgress;
  LoadFileStatus({
    Key key,
    this.file,
    this.dbId,
    this.changeStatus,
    this.loadStatus,
    this.loadProgress,
  }) : super(key: key);

  @override
  _LoadFileStatusState createState() => _LoadFileStatusState();
}

class _LoadFileStatusState extends State<LoadFileStatus>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Stack(
          children: <Widget>[
            widget.loadStatus == 'pending' || widget.loadStatus == 'loading'
                ? RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ExtraTheme.of(context).text,
                      ),
                      child: CircularProgressIndicator(
                        value: widget.loadProgress,
                        strokeWidth: 8,
                      ),
                    ),
                  )
                : Container(),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.file.type == 'audio' || widget.file.type == 'file'
                    ? ExtraTheme.of(context).text
                    : Colors.black.withOpacity(0.8),
              ),
              child: widget.loadStatus == 'pending' ||
                      widget.loadStatus == 'loading'
                  ? IconButton(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.center,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColor,
                        size: 35,
                      ),
                      onPressed: () {
                        widget.changeStatus('nothing');
                      },
                    )
                  : widget.loadStatus == 'nothing'
                      ? IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(
                            Icons.file_download,
                            color: Theme.of(context).primaryColor,
                            size: 33,
                          ),
                          onPressed: () {
                            widget.changeStatus('pending');
                          },
                        )
                      : widget.file.type == 'audio'
                          ? PlayAudioStatus(
                              file: widget.file,
                              dbId: widget.dbId,
                            )
                          : widget.file.type == 'file'
                              ? OpenFileStatus()
                              : Container(),
            ),
          ],
        ),
        // status != 'loaded' ? Text("222 Mb") : Container(),
      ],
    );
    //TODO animation to change icon????
  }
}

class LoadImageStatus extends StatefulWidget {
  final File file;
  final int dbId;
  final Function changeStatus;
  final String loadStatus;
  final double loadProgress;
  LoadImageStatus({
    Key key,
    this.file,
    this.dbId,
    this.changeStatus,
    this.loadStatus,
    this.loadProgress,
  }) : super(key: key);

  @override
  _LoadImageStatusState createState() => _LoadImageStatusState();
}

class _LoadImageStatusState extends State<LoadImageStatus>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
