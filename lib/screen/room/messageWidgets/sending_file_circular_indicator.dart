import 'package:deliver/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SendingFileCircularIndicator extends StatefulWidget {
  final double loadProgress;
  final bool isMedia;
  final File? file;
  final Color background;
  final Color foreground;

  const SendingFileCircularIndicator(
      {Key? key,
      required this.loadProgress,
      required this.isMedia,
      this.file,
      required this.background,
      required this.foreground})
      : super(key: key);

  @override
  _SendingFileCircularIndicatorState createState() =>
      _SendingFileCircularIndicatorState();
}

class _SendingFileCircularIndicatorState
    extends State<SendingFileCircularIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  var fileService = GetIt.I.get<FileService>();

  @override
  void initState() {
    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.file != null) {
      return Stack(
        children: [
          StreamBuilder<double>(
              stream: fileService.filesProgressBarStatus[widget.file!.uuid],
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircularPercentIndicator(
                    backgroundColor: widget.foreground,
                    radius: 55.0,
                    lineWidth: 5.0,
                    percent: snapshot.data!,
                    progressColor: widget.foreground,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
          IconButton(
            padding: const EdgeInsets.only(top: 8, left: 5),
            alignment: Alignment.center,
            icon: Icon(
              Icons.close,
              color: widget.isMedia
                  ? Theme.of(context).colorScheme.secondary //?????TODO
                  : Theme.of(context).primaryColor,
              size: 38,
            ),
            onPressed: null,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
