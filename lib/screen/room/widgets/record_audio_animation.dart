import 'dart:math';

import 'package:deliver/services/recorder_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class RecordAudioAnimation extends StatelessWidget {
  static final _recorderService = GetIt.I.get<RecorderService>();
  final RecordOnCompleteCallback? onComplete;
  final RecordOnCancelCallback? onCancel;

  late final BehaviorSubject<Offset> _pointerOffset =
      BehaviorSubject.seeded(Offset.zero);
  late final BehaviorSubject<Offset> _buttonOffset =
      BehaviorSubject.seeded(Offset.zero);

  RecordAudioAnimation({
    super.key,
    this.onComplete,
    this.onCancel,
  }) {
    _recorderService.isRecordingStream.listen((value) {
      if (!value) {
        _buttonOffset.add(Offset.zero);
      }
    });
    _pointerOffset.listen((value) {
      if (_recorderService.isLockedSteam.value) {
        _buttonOffset.add(Offset.zero);
      } else {
        if (value.dy < -110) {
          _recorderService.lock();
          _buttonOffset.add(Offset.zero);
        } else {
          if (value.dy.abs() < 30) {
            if (value.dx < -100) {
              _recorderService.cancel();
            } else {
              _buttonOffset.add(Offset(value.dx, 0));
            }
          } else {
            _buttonOffset.add(Offset(0, value.dy));
          }
        }
      }
      // _lockSteam.add();
      // value.dy
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      stream: _recorderService.isRecordingStream,
      builder: (context, snapshot) {
        final isRecording = snapshot.data ?? false;
        return AnimatedContainer(
          duration: ANIMATION_DURATION,
          width: isRecording ? 100 : 48,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              StreamBuilder<bool>(
                stream: _recorderService.isLockedSteam,
                builder: (context, snapshot) {
                  final lockFactor = snapshot.data ?? false ? 0.0 : 1.0;

                  return StreamBuilder<Offset>(
                    stream: _buttonOffset,
                    builder: (context, snapshot) {
                      final offset = snapshot.data ?? Offset.zero;

                      final opacity =
                          1 - ((min(offset.distance, 100) / 100) / 2);

                      return AnimatedOpacity(
                        duration: ANIMATION_DURATION,
                        opacity: (isRecording ? opacity : 0) * lockFactor,
                        child: AnimatedScale(
                          duration: ANIMATION_DURATION,
                          scale: (isRecording ? 1 : 0) * lockFactor,
                          child: AnimatedContainer(
                            duration: ANIMATION_DURATION,
                            width: (isRecording ? 30 : 0) * lockFactor,
                            height: (isRecording ? 50 : 0) * lockFactor,
                            transform: isRecording
                                ? Matrix4.translationValues(
                                    45,
                                    -100 + (offset.dy / 3),
                                    0,
                                  )
                                : Matrix4.identity(),
                            decoration: BoxDecoration(
                              borderRadius: mainBorder,
                              color: isRecording
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                            margin: isRecording
                                ? const EdgeInsets.only(right: 50)
                                : EdgeInsets.zero,
                            child: IconButton(
                              color: theme.colorScheme.onPrimary,
                              onPressed: () => {},
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.lock),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              StreamBuilder<Offset>(
                stream: _buttonOffset,
                builder: (context, snapshot) {
                  final offset = snapshot.data ?? Offset.zero;

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTapDown: (_) => _recorderService.checkPermission(),
                      onTapUp: (_) {
                        if (isRecording &&
                            (_recorderService.isLockedSteam.valueOrNull ??
                                false)) {
                          _recorderService.end();
                        }
                      },
                      onLongPressStart: (_) {
                        if (isRecording) {
                          return;
                        }
                        _recorderService.start(
                          onComplete: onComplete,
                          onCancel: onCancel,
                        );
                        _pointerOffset.add(Offset.zero);
                      },
                      onLongPressEnd: (_) {
                        if (!(_recorderService.isLockedSteam.valueOrNull ??
                            false)) {
                          if (_pointerOffset.value.dy.abs() < 30 &&
                              _pointerOffset.value.dx < -100) {
                            _recorderService.cancel();
                          } else {
                            _recorderService.end();
                          }
                        }
                      },
                      onLongPressMoveUpdate: (tg) =>
                          _pointerOffset.add(tg.offsetFromOrigin),
                      child: AnimatedContainer(
                        duration: ANIMATION_DURATION,
                        transform: isRecording
                            ? Matrix4.translationValues(
                                43 + min(offset.dx, 0),
                                min(offset.dy, 0),
                                0,
                              )
                            : Matrix4.identity(),
                        child: AnimatedScale(
                          duration: ANIMATION_DURATION,
                          scale: isRecording ? 2 : 1,
                          child: StreamBuilder<double>(
                            initialData: 1.0,
                            stream: _recorderService.recordingAmplitudeStream,
                            builder: (context, snapshot) {
                              final amplitude = 1.0 - (snapshot.data ?? 1);
                              return AnimatedContainer(
                                duration: ANIMATION_DURATION,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isRecording
                                      ? Color.lerp(
                                          theme.colorScheme.error,
                                          theme.colorScheme.errorContainer,
                                          amplitude / 1.8,
                                        )
                                      : Colors.transparent,
                                ),
                                width: 48,
                                height: 55,
                                margin: const EdgeInsets.only(right: 10),
                                child: StreamBuilder<bool>(
                                  stream: _recorderService.isLockedSteam,
                                  builder: (context, snapshot) {
                                    final showSendButtonInsteadOfMicrophone =
                                        isRecording && (snapshot.data ?? false);
                                    return Icon(
                                      showSendButtonInsteadOfMicrophone
                                          ? Icons.arrow_upward_rounded
                                          : Icons.mic,
                                      color: isRecording
                                          ? theme.colorScheme.onError
                                          : null,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
