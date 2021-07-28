import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class RecordAudioSlideWidget extends StatelessWidget {
  final double opacity;
  final DateTime time;
  final bool running;
  final BehaviorSubject<DateTime> streamTime;
  final BehaviorSubject<bool> _show = BehaviorSubject.seeded(true);

  RecordAudioSlideWidget(
      {this.opacity, this.time, this.running, this.streamTime});

  @override
  Widget build(BuildContext context) {
    var _i18n = I18N.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 1.0 - opacity,
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
              Opacity(
                opacity: opacity,
                child: StreamBuilder(
                    stream: _show.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data) {
                        return Opacity(
                          opacity: 0,
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                          ),
                        );
                      } else
                        return Opacity(
                          opacity: 1,
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                          ),
                        );
                    }),
              )
            ],
          ),
        ),
        StreamBuilder<DateTime>(
            stream: streamTime.stream,
            builder: (c, t) {
              _show.add(!_show.valueWrapper.value);
              if (t.hasData && t.data != null && t.data.isAfter(time))
                return Text(
                  "${durationTimeFormat(t.data.difference(time))}",
                  style: TextStyle(color: ExtraTheme.of(context).textField),
                );
              else
                return SizedBox.shrink();
            }),
        Opacity(
          opacity: opacity,
          child: Row(
            children: <Widget>[
              Icon(Icons.chevron_left),
              Text(
                _i18n.get("slideToCancel"),
                style: TextStyle(
                  fontSize: 12,
                  color: ExtraTheme.of(context).textField,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
