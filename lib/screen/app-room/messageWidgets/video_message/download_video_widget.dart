import 'package:deliver_flutter/services/file_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DownloadVideoWidget extends StatefulWidget {
  final String uuid;
  final Function download;


  DownloadVideoWidget({this.uuid, this.download});

  @override
  _DownloadVideoWidgetState createState() => _DownloadVideoWidgetState();
}

class _DownloadVideoWidgetState extends State<DownloadVideoWidget> {



  bool startDownload = false;

  var fileServices = GetIt.I.get<FileService>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
        ),
        child: startDownload
            ? StreamBuilder<double>(
          stream:
          fileServices.filesDownloadStatus[widget.uuid],
          builder: (c, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 4.0,
                percent: snapshot.data,
                center: Icon(Icons.arrow_downward),
                progressColor: Colors.red,
              );
            } else {
              return CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 4.0,
                percent: 0.1,
                center: Icon(Icons.arrow_downward),
                progressColor: Colors.red,
              );
            }
          },
        )
            : IconButton(
          icon: Icon(Icons.file_download),
          onPressed: () async {
            setState(() {
              startDownload = true;
            });
            widget.download;

          },
        ),
      ),
    );
  }
}