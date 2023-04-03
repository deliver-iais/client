import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/audio_modules/recorder_module.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class RecordAudioAnimation extends StatelessWidget {
  static final _audioService = GetIt.I.get<AudioService>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  final RecordOnCompleteCallback? onComplete;
  final RecordOnCancelCallback? onCancel;
  final Uid roomUid;

  final _isCanceled = BehaviorSubject.seeded(false);
  final _pointerOffset = BehaviorSubject.seeded(Offset.zero);
  final _buttonOffset = BehaviorSubject.seeded(Offset.zero);

  bool get _isRecordingInCurrentRoom =>
      _audioService.recordingRoom == roomUid.asString();

  RecordAudioAnimation({
    super.key,
    this.onComplete,
    this.onCancel,
    required this.roomUid,
  }) {
    _audioService.recorderIsRecording.listen((value) {
      if (!value) {
        _buttonOffset.add(Offset.zero);
      }
    });
    _pointerOffset.listen((value) {
      if (_audioService.recorderIsLocked.value) {
        _buttonOffset.add(Offset.zero);
      } else {
        if (value.dy < -110) {
          _audioService.lockRecorder();
          _buttonOffset.add(Offset.zero);
        } else {
          if (value.dy.abs() < 30) {
            if (value.dx < -100 && !_isCanceled.value) {
              _audioService.cancelRecording();
              _isCanceled.add(true);
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
      stream: _audioService.recorderIsRecording,
      builder: (ctx, snapshot) {
        final isRecording = snapshot.data ?? false;

        return AnimatedContainer(
          duration: AnimationSettings.normal,
          width: isRecording ? 100 : 40,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              StreamBuilder<bool>(
                stream: _audioService.recorderIsLocked,
                builder: (context, snapshot) {
                  final lockFactor = snapshot.data ?? false ? 0.0 : 1.0;

                  return StreamBuilder<Offset>(
                    stream: _buttonOffset,
                    builder: (context, snapshot) {
                      final offset = snapshot.data ?? Offset.zero;

                      final opacity =
                          1 - ((min(offset.distance, 100) / 100) / 2);

                      return AnimatedOpacity(
                        duration: AnimationSettings.normal,
                        opacity: (isRecording ? opacity : 0) * lockFactor,
                        child: AnimatedScale(
                          duration: AnimationSettings.normal,
                          scale: (isRecording ? 1 : 0) * lockFactor,
                          child: AnimatedContainer(
                            duration: AnimationSettings.normal,
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
                                ? const EdgeInsetsDirectional.only(end: 50)
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
                    duration: AnimationSettings.normal,
                    transform: isRecording
                        ? Matrix4.translationValues(
                            43 + min(offset.dx, 0),
                            min(offset.dy, 0),
                            0,
                          )
                        : Matrix4.identity(),
                    child: StreamBuilder<double>(
                      stream: _audioService.recordingAmplitude,
                      builder: (context, snapshot) {
                        final amplitude = (snapshot.data ?? 0) * 64.0;
                        final scale = (amplitude == 0)
                            ? 0.0
                            : isRecording
                                ? 1 + ((2.8 * amplitude / 64.0) + 1.0)
                                : 1.0;
                        return AnimatedScale(
                          duration: AnimationSettings.normal * 0.5,
                          scale: scale,
                          child: AnimatedContainer(
                            duration: AnimationSettings.normal * 0.5,
                            decoration: BoxDecoration(
                              color: isRecording
                                  ? theme.colorScheme.error.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(
                                  5.0 * Random().nextDouble() + 25 * scale / 2,
                                ),
                                topRight: Radius.circular(
                                  10.0 * Random().nextDouble() + 25 * scale / 2,
                                ),
                                bottomLeft: Radius.circular(
                                  10.0 * Random().nextDouble() + 25 * scale / 2,
                                ),
                                bottomRight:
                                    Radius.circular(25.0 + 10 * scale / 2),
                              ),
                            ),
                            // width: 40,
                            // height: 40,
                            child: StreamBuilder<bool>(
                              stream: _audioService.recorderIsLocked,
                              builder: (context, snapshot) {
                                final showSendButtonInsteadOfMicrophone =
                                    isRecording && (snapshot.data ?? false);
                                return IconButton(
                                  icon: Icon(
                                    showSendButtonInsteadOfMicrophone
                                        ? CupertinoIcons.arrow_up
                                        : CupertinoIcons.mic,
                                    color: Colors.transparent,
                                  ),
                                  onPressed: () {},
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
                      onLongPressStart: (_) {
                        if (isRecording) {
                          return;
                        }
                        _audioService.startRecording(
                          onComplete: onComplete,
                          onCancel: onCancel,
                          roomUid: roomUid.asString(),
                        );
                        _pointerOffset.add(Offset.zero);
                      },
                      onLongPressEnd: (_) {
                        if (!(_audioService.recorderIsLocked.valueOrNull ??
                            false)) {
                          if (_pointerOffset.value.dy.abs() < 30 &&
                              _pointerOffset.value.dx < -100) {
                            if (!_isCanceled.value) {
                              _audioService.cancelRecording();
                            }
                          } else if (_isRecordingInCurrentRoom) {
                            endRecording(context);
                          } else if (_audioService.recordingRoom == "") {
                            _audioService.cancelRecording();
                          }
                          _isCanceled.add(false);
                        }
                      },
                      onLongPressMoveUpdate: (tg) =>
                          _pointerOffset.add(tg.offsetFromOrigin),
                      child: Padding(
                        padding: isRecording
                            ? const EdgeInsetsDirectional.only(start: 43)
                            : const EdgeInsetsDirectional.only(),
                        child: AnimatedContainer(
                          duration: AnimationSettings.normal,
                          transform: isRecording
                              ? Matrix4.translationValues(
                                  min(offset.dx, 0),
                                  min(offset.dy, 0),
                                  0,
                                )
                              : Matrix4.identity(),
                          child: StreamBuilder<double>(
                            stream: _audioService.recordingAmplitude,
                            builder: (context, snapshot) {
                              final amplitude = (snapshot.data ?? 0) * 64.0;
                              final scale = isRecording
                                  ? 0.9 + ((1.3 * amplitude / 64.0) + 1.0)
                                  : 1.0;
                              return AnimatedScale(
                                duration: AnimationSettings.normal * 0.5,
                                scale: scale,
                                child: AnimatedContainer(
                                  duration: AnimationSettings.normal * 0.5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (isRecording)
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
                                    stream: _audioService.recorderIsLocked,
                                    builder: (context, snapshot) {
                                      final showSendButtonInsteadOfMicrophone =
                                          isRecording &&
                                              (snapshot.data ?? false);
                                      return IconButton(
                                        icon: Icon(
                                          _isRecordingInCurrentRoom &&
                                                  showSendButtonInsteadOfMicrophone
                                              ? CupertinoIcons.arrow_up
                                              : CupertinoIcons.mic,
                                          color: isRecording
                                              ? theme.colorScheme.onError
                                              : null,
                                        ),
                                        onPressed: () {
                                          if (isRecording &&
                                              !_isRecordingInCurrentRoom) {
                                            _routingService.openRoom(
                                              _audioService.recordingRoom,
                                            );
                                          } else if (showSendButtonInsteadOfMicrophone) {
                                            endRecording(context);
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

  Future<void> endRecording(BuildContext context) async {
    if (!await _audioService.endRecording()) {
      ToastDisplay.showToast(
        maxWidth: 500,
        toastText: _i18n.get("mic_problem"),
      );
    }
  }
}
