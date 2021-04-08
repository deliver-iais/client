import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer/flutter_timer.dart';

class RecordAudioSlideWidget extends  StatelessWidget{
  final Function opacity;
  final DateTime time;
  final bool rinning;
  RecordAudioSlideWidget({this.opacity,this.time,this.rinning});
  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 1.0 - opacity(),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
              Opacity(
                opacity: opacity(),
                child: Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        TikTikTimer(
          height: 20,
          width: 70,
          timerTextStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor),
          initialDate: time,
          running: rinning,
          backgroundColor:
          ExtraTheme.of(context).secondColor,
          borderRadius: 0,
        ),
        Opacity(
          opacity: opacity(),
          child: Row(
            children: <Widget>[
              Icon(Icons.chevron_left),
              Text(
                  _appLocalization
                      .getTraslateValue("slideToCancel"),
                  style: TextStyle(
                      fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }



}