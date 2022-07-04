import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/audio_modules/recorder_module.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecordAudioSlideWidget extends StatelessWidget {
  static final _audioService = GetIt.I.get<AudioService>();
  static final _i18n = GetIt.I.get<I18N>();

  const RecordAudioSlideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: SizedBox(
        height: 46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(
                Icons.fiber_manual_record,
                color: Colors.red,
              ),
            ),
            StreamBuilder<Duration>(
              initialData: Duration.zero,
              stream: _audioService.recordingDurationStream,
              builder: (c, t) {
                final duration = t.data ?? Duration.zero;
                if (duration.compareTo(Duration.zero) > 0) {
                  return Text(
                    durationTimeFormat(duration),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const Spacer(),
            StreamBuilder<bool>(
              stream: _audioService.recorderIsLockedSteam,
              builder: (context, snapshot) {
                final isLocked = snapshot.data ?? false;
                if (!isLocked) {
                  return Row(
                    children: <Widget>[
                      const Icon(Icons.chevron_left),
                      TextButton(
                        child: Text(
                          _i18n.get("slideToCancel"),
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () {
                          _audioService.cancelRecording();
                        },
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Container(
                      width: 52,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: mainBorder,
                        color: theme.colorScheme.primary,
                      ),
                      child: StreamBuilder<bool>(
                        stream: _audioService.recorderIsPaused,
                        builder: (context, snapshot) {
                          final isPaused = snapshot.data ?? false;
                          return IconButton(
                            color: theme.colorScheme.onPrimary,
                            onPressed: () {
                              _audioService.toggleRecorderPause();
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isPaused
                                  ? CupertinoIcons.circle
                                  : CupertinoIcons.pause,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 52,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: mainBorder,
                        color: theme.colorScheme.primary,
                      ),
                      child: IconButton(
                        icon: Icon(
                          CupertinoIcons.clear_thick,
                          color: theme.colorScheme.onPrimary,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _audioService.cancelRecording();
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
