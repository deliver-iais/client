import 'dart:math';

import 'package:deliver/services/audio_modules/recorder_module.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class RecordAudioAnimation extends StatelessWidget {
  static final _recorderService = GetIt.I.get<RecorderModule>();
  final RecordOnCompleteCallback? onComplete;
  final RecordOnCancelCallback? onCancel;
  final Uid roomUid;
  bool _isCanceled = false;

  late final BehaviorSubject<Offset> _pointerOffset =
      BehaviorSubject.seeded(Offset.zero);
  late final BehaviorSubject<Offset> _buttonOffset =
      BehaviorSubject.seeded(Offset.zero);

  RecordAudioAnimation({
    super.key,
    this.onComplete,
    this.onCancel,
    required this.roomUid,
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
            if (value.dx < -100 && !_isCanceled) {
              _recorderService.cancel();
              _isCanceled = true;
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

    return StreamBuilder(
      stream: MergeStream([
        _recorderService.isRecordingStream,
        _recorderService.recordingRoomStream,
      ]),
      builder: (ctx, snapshot) {
        final isCurrentRoomUid = (_recorderService
                .recordingRoomStream.valueOrNull
                ?.isEqual(roomUid) ??
            true);
        final isRecording =
            _recorderService.isRecordingStream.value && isCurrentRoomUid;
        final isRecordingInOtherRoom =
            _recorderService.isRecordingStream.value && !isCurrentRoomUid;
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
                            height: (isRecording ? 46 : 0) * lockFactor,
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
                  return AnimatedContainer(
                    duration: ANIMATION_DURATION,
                    transform: isRecording
                        ? Matrix4.translationValues(
                            43 + min(offset.dx, 0),
                            min(offset.dy, 0),
                            0,
                          )
                        : Matrix4.identity(),
                    child: StreamBuilder<double>(
                      stream: _recorderService.recordingAmplitudeStream,
                      builder: (context, snapshot) {
                        final amplitude = (snapshot.data ?? 0) * 64.0;
                        final scale = (amplitude == 0)
                            ? 0.0
                            : isRecording
                                ? 1 + ((2.8 * amplitude / 64.0) + 1.0)
                                : 1.0;
                        return AnimatedScale(
                          duration: ANIMATION_DURATION * 0.5,
                          scale: scale,
                          child: AnimatedContainer(
                            duration: ANIMATION_DURATION * 0.5,
                            decoration: BoxDecoration(
                              color: isRecording
                                  ? theme.colorScheme.error.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  10.0 * Random().nextDouble() + 25 * scale / 2,
                                ),
                                topRight: Radius.circular(
                                  15.0 * Random().nextDouble() + 20 * scale / 2,
                                ),
                                bottomLeft: Radius.circular(
                                  15.0 * Random().nextDouble() + 20 * scale / 2,
                                ),
                                bottomRight:
                                    Radius.circular(25.0 + 10 * scale / 2),
                              ),
                            ),
                            // width: 40,
                            // height: 40,
                            child: StreamBuilder<bool>(
                              stream: _recorderService.isLockedSteam,
                              builder: (context, snapshot) {
                                final showSendButtonInsteadOfMicrophone =
                                    isRecording && (snapshot.data ?? false);
                                return IconButton(
                                  icon: Icon(
                                    showSendButtonInsteadOfMicrophone
                                        ? CupertinoIcons.arrow_up
                                        : CupertinoIcons.mic,
                                    color: isRecording
                                        ? theme.colorScheme.onError
                                        : Colors.transparent,
                                  ),
                                  onPressed: () {
                                    if (showSendButtonInsteadOfMicrophone) {
                                      _recorderService.end();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
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
                          roomUid: roomUid,
                        );
                        _pointerOffset.add(Offset.zero);
                      },
                      onLongPressEnd: (_) {
                        if (!(_recorderService.isLockedSteam.valueOrNull ??
                            false)) {
                          if (_pointerOffset.value.dy.abs() < 30 &&
                              _pointerOffset.value.dx < -100) {
                            if (!_isCanceled) {
                              _recorderService.cancel();
                            }
                          } else {
                            _recorderService.end();
                          }
                          _isCanceled = false;
                        }
                      },
                      onLongPressMoveUpdate: (tg) =>
                          _pointerOffset.add(tg.offsetFromOrigin),
                      child: Padding(
                        padding: isRecording
                            ? const EdgeInsets.only(left: 43)
                            : const EdgeInsets.only(),
                        child: AnimatedContainer(
                          duration: ANIMATION_DURATION,
                          transform: isRecording
                              ? Matrix4.translationValues(
                                  min(offset.dx, 0),
                                  min(offset.dy, 0),
                                  0,
                                )
                              : Matrix4.identity(),
                          child: StreamBuilder<double>(
                            stream: _recorderService.recordingAmplitudeStream,
                            builder: (context, snapshot) {
                              final amplitude = (snapshot.data ?? 0) * 64.0;
                              final scale = isRecording
                                  ? 0.9 + ((1.3 * amplitude / 64.0) + 1.0)
                                  : 1.0;
                              return AnimatedScale(
                                duration: ANIMATION_DURATION * 0.5,
                                scale: scale,
                                child: AnimatedContainer(
                                  duration: ANIMATION_DURATION * 0.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isRecording ||
                                            isRecordingInOtherRoom)
                                        ? Color.lerp(
                                            theme.colorScheme.error,
                                            theme.colorScheme.errorContainer,
                                            amplitude / 96,
                                          )
                                        : Colors.transparent,
                                  ),
                                  // width: 40,
                                  // height: 40,
                                  child: StreamBuilder<bool>(
                                    stream: _recorderService.isLockedSteam,
                                    builder: (context, snapshot) {
                                      final showSendButtonInsteadOfMicrophone =
                                          isRecording &&
                                              (snapshot.data ?? false);
                                      return IconButton(
                                        icon: Icon(
                                          showSendButtonInsteadOfMicrophone
                                              ? CupertinoIcons.arrow_up
                                              : CupertinoIcons.mic,
                                          color: isRecording
                                              ? theme.colorScheme.onError
                                              : null,
                                        ),
                                        onPressed: () {
                                          if (showSendButtonInsteadOfMicrophone) {
                                            _recorderService.end();
                                          }
                                        },
                                      );
                                    },
                                  ),
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
