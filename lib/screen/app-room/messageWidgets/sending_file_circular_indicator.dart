import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class SendingFileCircularIndicator extends StatefulWidget {
  final double loadProgress;
  final bool isMedia;
  final Function cancelUpload;

  const SendingFileCircularIndicator({Key key, this.loadProgress, this.isMedia,this.cancelUpload})
      : super(key: key);

  @override
  _SendingFileCircularIndicatorState createState() =>
      _SendingFileCircularIndicatorState();
}

class _SendingFileCircularIndicatorState
    extends State<SendingFileCircularIndicator>
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
    return Stack(
      children: [
        RotationTransition(
          turns: _controller,
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              value: widget.loadProgress,
              strokeWidth: 5,
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          alignment: Alignment.center,
          icon: Icon(
            Icons.close,
            color: widget.isMedia
                ? Theme.of(context).accentColor
                : Theme.of(context).primaryColor,
            size: 35,
          ),
          onPressed: widget.cancelUpload,
        ),
      ],
    );
  }
}
