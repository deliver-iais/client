import 'dart:async';

import 'package:animations/animations.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/screen/call/center_avatar_image_in_call.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class VideoCallScreen extends StatefulWidget {
  final Uid roomUid;
  final void Function() hangUp;
  final bool isIncomingCall;

  const VideoCallScreen({
    super.key,
    required this.roomUid,
    required this.hangUp,
    this.isIncomingCall = false,
  });

  @override
  VideoCallScreenState createState() => VideoCallScreenState();
}

class VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  final _logger = GetIt.I.get<Logger>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _callService = GetIt.I.get<CallService>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> showButtonRow = BehaviorSubject.seeded(true);

  Offset position = isWindows
      ? const Offset(20, 80)
      : const Offset(20, androidSmallCallWidgetVerticalMargin);

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _logger.i("call dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWindows ? grayColor : Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showButtonRow.add(!showButtonRow.value),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            //const AnimatedGradient(),
            StreamBuilder<bool>(
              stream: MergeStream([
                _callRepo.incomingSharing,
                _callRepo.sharing,
                _callRepo.videoing,
                _callRepo.incomingVideo,
                _callRepo.desktopDualVideo,
                _callRepo.incomingVideoSwitch,
              ]),
              builder: (c, s) {
                return isWindows && _callRepo.desktopDualVideo.value
                    ? OrientationBuilder(
                        builder: (context, orientation) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              top: 20,
                              bottom: 20,
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  if (_callRepo.incomingSharing.value)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: InteractiveViewer(
                                          // Set it to false to prevent panning.
                                          minScale: 0.5,
                                          maxScale: 4,
                                          child: RTCVideoView(
                                            _callService.getRemoteRenderer,
                                            mirror: !_callRepo
                                                .incomingVideoSwitch.value,
                                          ),
                                        ),
                                      ),
                                    )
                                  else if (_callRepo.incomingVideo.value)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: StreamBuilder<bool>(
                                          initialData: false,
                                          stream: _callService.isCallStart,
                                          builder: (context, snapshot2) {
                                            Widget renderer;
                                            if (snapshot2.hasData &&
                                                snapshot2.data!) {
                                              renderer = RTCVideoView(
                                                _callService.getRemoteRenderer,
                                                mirror: !_callRepo
                                                    .incomingVideoSwitch.value,
                                                objectFit: RTCVideoViewObjectFit
                                                    .RTCVideoViewObjectFitCover,
                                              );
                                            } else {
                                              renderer =
                                                  const SizedBox.shrink();
                                            }
                                            return PageTransitionSwitcher(
                                              transitionBuilder: (
                                                child,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return SharedAxisTransition(
                                                  fillColor: Colors.transparent,
                                                  animation: animation,
                                                  secondaryAnimation:
                                                      secondaryAnimation,
                                                  transitionType:
                                                      SharedAxisTransitionType
                                                          .vertical,
                                                  child: child,
                                                );
                                              },
                                              child: renderer,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: CenterAvatarInCall(
                                          roomUid: widget.roomUid,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  if (_callRepo.sharing.value)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: RTCVideoView(
                                          _callService.getLocalRenderer,
                                          mirror: true,
                                        ),
                                      ),
                                    )
                                  else if (_callRepo.videoing.value)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: StreamBuilder<bool>(
                                          initialData: false,
                                          stream: _callService.isCallStart,
                                          builder: (context, snapshot2) {
                                            Widget renderer;
                                            if (snapshot2.hasData &&
                                                snapshot2.data!) {
                                              renderer = InteractiveViewer(
                                                // Set it to false to prevent panning.
                                                minScale: 0.5,
                                                maxScale: 4,
                                                child: RTCVideoView(
                                                  _callService.getLocalRenderer,
                                                  mirror: true,
                                                  objectFit: RTCVideoViewObjectFit
                                                      .RTCVideoViewObjectFitCover,
                                                ),
                                              );
                                            } else {
                                              renderer =
                                                  const SizedBox.shrink();
                                            }

                                            return PageTransitionSwitcher(
                                              transitionBuilder: (
                                                child,
                                                animation,
                                                secondaryAnimation,
                                              ) {
                                                return SharedAxisTransition(
                                                  fillColor: Colors.transparent,
                                                  animation: animation,
                                                  secondaryAnimation:
                                                      secondaryAnimation,
                                                  transitionType:
                                                      SharedAxisTransitionType
                                                          .vertical,
                                                  child: child,
                                                );
                                              },
                                              child: renderer,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(
                                          0.0,
                                        ),
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: mainBorder,
                                          boxShadow: DEFAULT_BOX_SHADOWS,
                                        ),
                                        child: CenterAvatarInCall(
                                          roomUid: _authRepo.currentUserUid,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : OrientationBuilder(
                        builder: (context, orientation) {
                          final x = MediaQuery.of(context).size.width;
                          final y = MediaQuery.of(context).size.height;
                          final width =
                              (isAndroid || x < 600) ? 150.0 : x * 0.15;
                          final height =
                              (isAndroid || x < 600) ? 200.0 : y * 0.35;
                          return StreamBuilder<bool>(
                            initialData: false,
                            stream: switching,
                            builder: (context, snapshot) {
                              return Stack(
                                children: [
                                  if (((_callRepo.incomingSharing.value &&
                                              !snapshot.data!) ||
                                          (snapshot.data! &&
                                              _callRepo.sharing.value)) ||
                                      ((_callRepo.incomingVideo.value &&
                                              !snapshot.data!) ||
                                          (snapshot.data! &&
                                              _callRepo.videoing.value)))
                                    SizedBox(
                                      width: x,
                                      height: y,
                                      child: StreamBuilder<bool>(
                                        initialData: false,
                                        stream: _callService.isCallStart,
                                        builder: (context, snapshot2) {
                                          Widget renderer;
                                          if (snapshot2.hasData &&
                                              snapshot2.data!) {
                                            renderer = InteractiveViewer(
                                              // Set it to false to prevent panning.
                                              minScale: 0.5,
                                              maxScale: 4,
                                              child: RTCVideoView(
                                                snapshot.data!
                                                    ? _callService
                                                        .getLocalRenderer
                                                    : _callService
                                                        .getRemoteRenderer,
                                                objectFit: RTCVideoViewObjectFit
                                                    .RTCVideoViewObjectFitCover,
                                                mirror: !(snapshot.data! &&
                                                    _callRepo.switching.value),
                                              ),
                                            );
                                          } else {
                                            renderer = const SizedBox.shrink();
                                          }

                                          return PageTransitionSwitcher(
                                            transitionBuilder: (
                                              child,
                                              animation,
                                              secondaryAnimation,
                                            ) {
                                              return SharedAxisTransition(
                                                fillColor: Colors.transparent,
                                                animation: animation,
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                transitionType:
                                                    SharedAxisTransitionType
                                                        .vertical,
                                                child: child,
                                              );
                                            },
                                            child: renderer,
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    Container(
                                      width: x,
                                      height: y,
                                      margin: const EdgeInsets.all(
                                        0.0,
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        boxShadow: DEFAULT_BOX_SHADOWS,
                                      ),
                                      child: CenterAvatarInCall(
                                        roomUid: widget.roomUid,
                                      ),
                                    ),
                                  if ((!snapshot.data! &&
                                          _callRepo.videoing.value) ||
                                      (snapshot.data! &&
                                          _callRepo.incomingVideo.value))
                                    userVideoWidget(
                                      x,
                                      y,
                                      width,
                                      height,
                                      isMirror: (_callRepo.videoing.value &&
                                          !snapshot.data!),
                                      inComingVideo:
                                          _callRepo.incomingVideo.value ||
                                              _callRepo.incomingSharing.value,
                                    )
                                ],
                              );
                            },
                          );
                        },
                      );
              },
            ),
            SafeArea(
              child: Padding(
                padding: isWindows
                    ? const EdgeInsets.only(bottom: 40, right: 50, left: 50)
                    : const EdgeInsets.only(top: 8),
                child: Align(
                  alignment:
                      isWindows ? Alignment.bottomRight : Alignment.topCenter,
                  child: StreamBuilder<CallStatus>(
                    initialData: CallStatus.NO_CALL,
                    stream: _callRepo.callingStatus,
                    builder: (context, snapshot) {
                      return CallStatusWidget(
                        callStatus: snapshot.data!,
                        isIncomingCall: widget.isIncomingCall,
                      );
                    },
                  ),
                ),
              ),
            ),
            StreamBuilder<Object>(
              stream: MergeStream([
                _callRepo.callingStatus,
                showButtonRow,
              ]),
              builder: (context, snapshot) {
                Widget renderer;
                if (!_callService
                        .isHiddenCallBottomRow(_callRepo.callingStatus.value) ||
                    showButtonRow.value) {
                  renderer = CallBottomRow(
                    hangUp: widget.hangUp,
                    isIncomingCall: widget.isIncomingCall,
                    callStatus: _callRepo.callingStatus.value,
                  );
                } else {
                  renderer = const SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: (isAndroid && _callRepo.isAccepted) ? 100 : 200,
                    child: PageTransitionSwitcher(
                      duration: ULTRA_SLOW_ANIMATION_DURATION,
                      transitionBuilder: (
                        child,
                        animation,
                        secondaryAnimation,
                      ) {
                        return SharedAxisTransition(
                          fillColor: Colors.transparent,
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          child: child,
                        );
                      },
                      child: renderer,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<bool> userVideoWidget(
    double x,
    double y,
    double width,
    double height, {
    required bool isMirror,
    required bool inComingVideo,
  }) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: _callRepo.switching,
      builder: (context, snapshot) {
        return Positioned(
          left: position.dx,
          top: position.dy - (isAndroid ? 80 : 50),
          child: StreamBuilder<bool>(
            initialData: false,
            stream: _callService.isCallStart,
            builder: (context, snapshot2) {
              Widget renderer;
              if (snapshot2.hasData && snapshot2.data!) {
                if (isAndroid) {
                  renderer = Draggable(
                    feedback: SizedBox(
                      width: width,
                      height: height,
                      child: ClipRRect(
                        borderRadius: mainBorder,
                        clipBehavior: Clip.hardEdge,
                        child: RTCVideoView(
                          switching.value
                              ? _callService.getRemoteRenderer
                              : _callService.getLocalRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: isMirror,
                        ),
                      ),
                    ),
                    // onDragStarted: () => print("drag Start"),
                    onDraggableCanceled: (velocity, offset) {
                      setState(() {
                        final horizontalMargin =
                            (isAndroid || x < 600) ? 20 : x * 0.22;
                        final verticalMargin = isAndroid ? 65 : 80;
                        if (offset.dx > x / 2 && offset.dy > y / 2) {
                          position = Offset(
                            x - width - horizontalMargin,
                            y - height - verticalMargin,
                          );
                        }
                        if (offset.dx < x / 2 && offset.dy > y / 2) {
                          position = Offset(20, y - height - verticalMargin);
                        }
                        if (offset.dx > x / 2 && offset.dy < y / 2) {
                          position = Offset(
                            x - width - horizontalMargin,
                            androidSmallCallWidgetVerticalMargin,
                          );
                        }
                        if (offset.dx < x / 2 && offset.dy < y / 2) {
                          position = isWindows
                              ? const Offset(20, 80)
                              : const Offset(
                                  20,
                                  androidSmallCallWidgetVerticalMargin,
                                );
                        }
                      });
                    },
                    childWhenDragging: Container(),
                    child: smallUserWidget(
                      width,
                      height,
                      isSwitching: snapshot.data ?? false,
                      inComingVideo: inComingVideo,
                    ),
                  );
                } else {
                  renderer = smallUserWidget(
                    width,
                    height,
                    isSwitching: snapshot.data ?? false,
                    inComingVideo: inComingVideo,
                  );
                }
              } else {
                renderer = const SizedBox.shrink();
              }

              return PageTransitionSwitcher(
                transitionBuilder: (
                  child,
                  animation,
                  secondaryAnimation,
                ) {
                  return SharedAxisTransition(
                    fillColor: Colors.transparent,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.vertical,
                    child: child,
                  );
                },
                child: renderer,
              );
            },
          ),
        );
      },
    );
  }

  Widget smallUserWidget(
    double width,
    double height, {
    required bool isSwitching,
    required bool inComingVideo,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: mainBorder,
        clipBehavior: Clip.hardEdge,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: !switching.value
                ? InteractiveViewer(
                    // Set it to false to prevent panning.
                    minScale: 0.5,
                    maxScale: 4,
                    child: RTCVideoView(
                      _callService.getLocalRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: !isSwitching,
                    ),
                  )
                : inComingVideo
                    ? InteractiveViewer(
                        // Set it to false to prevent panning.
                        minScale: 0.5,
                        maxScale: 4,
                        child: RTCVideoView(
                          _callService.getRemoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: true,
                        ),
                      )
                    : Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              Colors.teal,
                              Colors.cyan,
                              Colors.greenAccent
                            ],
                          ),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                          borderRadius: mainBorder,
                          boxShadow: DEFAULT_BOX_SHADOWS,
                        ),
                        child: CenterAvatarInCall(
                          radius: 60,
                          roomUid: widget.roomUid,
                        ),
                      ),
            onTap: () {
              setState(() {
                switching.add(!switching.value);
              });
            },
          ),
        ),
      ),
    );
  }
}
