import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SendingFileCircularIndicator extends StatefulWidget {
  final double loadProgress;
  final bool isMedia;
  final File file;

  const SendingFileCircularIndicator(
      {Key key, this.loadProgress, this.isMedia, this.file})
      : super(key: key);

  @override
  _SendingFileCircularIndicatorState createState() =>
      _SendingFileCircularIndicatorState();
}

class _SendingFileCircularIndicatorState
    extends State<SendingFileCircularIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  var fileService = GetIt.I.get<FileService>();

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
    if(widget.file != null){
      return Stack(
        children: [
          StreamBuilder<double>(
              stream: fileService.filesUploadStatus[widget.file.uuid],
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircularPercentIndicator(
                    radius: 55.0,
                    lineWidth: 5.0,
                    percent: snapshot.data,
                    progressColor: Colors.blue,
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
          IconButton(
            padding: EdgeInsets.only(top: 8, left: 5),
            alignment: Alignment.center,
            icon: Icon(
              Icons.close,
              color: widget.isMedia
                  ? Theme.of(context).accentColor
                  : Theme.of(context).primaryColor,
              size: 38,
            ),
            onPressed: null,
          ),
        ],
      );
    }else{
      return SizedBox.shrink();
    }


  }
}
