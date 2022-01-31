import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class RecordAudioSlideWidget extends StatelessWidget {
  final double opacity;
  final DateTime time;
  final bool running;
  final BehaviorSubject<DateTime> streamTime;
  final BehaviorSubject<bool> _show = BehaviorSubject.seeded(true);
  final _i18n = GetIt.I.get<I18N>();

  RecordAudioSlideWidget(
      {Key? key,
      required this.opacity,
      required this.time,
      required this.running,
      required this.streamTime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 1.0 - opacity,
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
              Opacity(
                opacity: opacity,
                child: StreamBuilder<bool>(
                    stream: _show.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data!) {
                        return const Opacity(
                          opacity: 0,
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                          ),
                        );
                      } else {
                        return const Opacity(
                          opacity: 1,
                          child: Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                          ),
                        );
                      }
                    }),
              )
            ],
          ),
        ),
        StreamBuilder<DateTime>(
            stream: streamTime.stream,
            builder: (c, t) {
              _show.add(!_show.value);
              if (t.hasData && t.data != null && t.data!.isAfter(time)) {
                return Text(
                  durationTimeFormat(t.data!.difference(time)),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
        Opacity(
          opacity: opacity,
          child: Row(
            children: <Widget>[
              const Icon(Icons.chevron_left),
              Text(
                _i18n.get("slideToCancel"),
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
