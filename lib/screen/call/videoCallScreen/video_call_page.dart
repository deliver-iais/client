import 'package:deliver/models/call_timer.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import '../../../localization/i18n.dart';
import '../../../repository/authRepo.dart';
import '../../../repository/callRepo.dart';
import '../../../shared/methods/platform.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/dot_animation/dot_animation.dart';
import '../../../theme/theme.dart';
import '../call_bottom_icons.dart';
import '../center_avatar_image-in-call.dart';

class VideoCallScreen extends StatefulWidget {
  final Uid roomUid;
  late RTCVideoRenderer localRenderer;
  final String text;
  final String callStatusOnScreen;
  late RTCVideoRenderer remoteRenderer;
  final void Function() hangUp;
  final bool isIncomingCall;

  VideoCallScreen({
    super.key,
    required this.text,
    required this.roomUid,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.hangUp,
    required this.callStatusOnScreen,
    this.isIncomingCall = false,
  });

  @override
  VideoCallScreenState createState() => VideoCallScreenState();
}

class VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  final _logger = GetIt.I.get<Logger>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  late AnimationController _repeatEndCallAnimationController;
  late AnimationController animationController;
  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);

  Offset position = const Offset(20, 95);

  @override
  void initState() {
    _initRepeatEndCallAnimation();
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  Future<void> dispose() async {
    _repeatEndCallAnimationController.dispose();
    animationController.dispose();
    super.dispose();
    _logger.i("call dispose in start call status=${widget.text}");
  }

  void _initRepeatEndCallAnimation() {
    _repeatEndCallAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _repeatEndCallAnimationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedGradient(isConnected: _callRepo.isConnected),
          StreamBuilder<bool>(
            stream: MergeStream([
              _callRepo.incomingSharing,
              _callRepo.sharing,
              _callRepo.videoing,
              _callRepo.incomingVideo,
              _callRepo.desktopDualVideo,
            ]),
            builder: (c, s) {
              return isWindows && _callRepo.desktopDualVideo.value
                  ? OrientationBuilder(
                      builder: (context, orientation) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 2 / 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                if (_callRepo.incomingSharing.value)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(
                                        0.0,
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                          widget.remoteRenderer,
                                          filterQuality: FilterQuality.high,
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
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                          widget.remoteRenderer,
                                          mirror: true,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: CenterAvatarInCall(
                                      roomUid: widget.roomUid,
                                    ),
                                  ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: VerticalDivider(),
                                ),
                                if (_callRepo.sharing.value)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(
                                        0.0,
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                          widget.localRenderer,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  )
                                else if (_callRepo.videoing.value)
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(
                                        0.0,
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
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
                                          widget.localRenderer,
                                          mirror: true,
                                          filterQuality: FilterQuality.high,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: CenterAvatarInCall(
                                      roomUid: _authRepo.currentUserUid,
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
                        final width = (isAndroid || x < 600) ? 150.0 : x * 0.15;
                        final height =
                            (isAndroid || x < 600) ? 200.0 : y * 0.35;

                        return StreamBuilder<bool>(
                            initialData: false,
                            stream: switching,
                            builder: (context, snapshot) {
                              return Stack(
                                children: [
                                  if ((_callRepo.incomingSharing.value &&
                                          !snapshot.data!) ||
                                      (snapshot.data! &&
                                          _callRepo.sharing.value))
                                    SizedBox(
                                      width: x,
                                      height: y,
                                      child: InteractiveViewer(
                                        // Set it to false to prevent panning.
                                        minScale: 0.5,
                                        maxScale: 4,
                                        child: RTCVideoView(
                                          snapshot.data!
                                              ? widget.localRenderer
                                              : widget.remoteRenderer,
                                        ),
                                      ),
                                    )
                                  else if ((_callRepo.incomingVideo.value &&
                                          !snapshot.data!) ||
                                      (snapshot.data! &&
                                          _callRepo.videoing.value))
                                    SizedBox(
                                      width: x,
                                      height: y,
                                      child: InteractiveViewer(
                                        // Set it to false to prevent panning.
                                        minScale: 0.5,
                                        maxScale: 4,
                                        child: RTCVideoView(
                                          snapshot.data!
                                              ? widget.localRenderer
                                              : widget.remoteRenderer,
                                          mirror: true,
                                        ),
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                      ),
                                      child: CenterAvatarInCall(
                                        roomUid: widget.roomUid,
                                      ),
                                    ),
                                  if (_callRepo.videoing.value)
                                    userVideoWidget(
                                      x,
                                      y,
                                      width,
                                      height,
                                      isMirror:
                                          (_callRepo.incomingSharing.value &&
                                                  snapshot.data!)
                                              ? false
                                              : true,
                                      inComingVideo:
                                          _callRepo.incomingVideo.value ||
                                              _callRepo.incomingSharing.value,
                                    )
                                  else if (_callRepo.sharing.value)
                                    userVideoWidget(x, y, width, height,
                                        inComingVideo:
                                            _callRepo.incomingVideo.value ||
                                                _callRepo.incomingSharing.value,
                                        isMirror:
                                            (_callRepo.incomingVideo.value &&
                                                    snapshot.data!)
                                                ? true
                                                : false)
                                ],
                              );
                            });
                      },
                    );
            },
          ),
          CallBottomRow(
            hangUp: widget.hangUp,
            isIncomingCall: widget.isIncomingCall,
          ),
        ],
      ),
    );
  }

  Positioned userVideoWidget(
    double x,
    double y,
    double width,
    double height, {
    required bool isMirror,
    required bool inComingVideo,
  }) {
    return Positioned(
      left: position.dx,
      top: position.dy - (isAndroid ? 80 : 50),
      child: Draggable(
        feedback: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: RTCVideoView(
              switching.value ? widget.remoteRenderer : widget.localRenderer,
              mirror: isMirror,
            ),
          ),
        ),
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            final horizentalMargin = (isAndroid || x < 600) ? 20 : x * 0.22;
            final verticalMargin = isAndroid ? 95 : 110;
            if (offset.dx > x / 2 && offset.dy > y / 2) {
              position = Offset(
                  x - width - horizentalMargin, y - height - verticalMargin);
            }
            if (offset.dx < x / 2 && offset.dy > y / 2) {
              position = Offset(20, y - height - verticalMargin);
            }
            if (offset.dx > x / 2 && offset.dy < y / 2) {
              position = Offset(x - width - horizentalMargin, 95);
            }
            if (offset.dx < x / 2 && offset.dy < y / 2) {
              position = const Offset(20, 95);
            }
          });
        },
        childWhenDragging: Container(),
        child: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                child: !switching.value
                    ? InteractiveViewer(
                        // Set it to false to prevent panning.
                        minScale: 0.5,
                        maxScale: 4,
                        child: RTCVideoView(
                          widget.localRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: isMirror,
                        ),
                      )
                    : inComingVideo
                        ? InteractiveViewer(
                            // Set it to false to prevent panning.
                            minScale: 0.5,
                            maxScale: 4,
                            child: RTCVideoView(
                              widget.remoteRenderer,
                              mirror: isMirror,
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
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
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
        ),
      ),
    );
  }

  Row callTimerWidget(ThemeData theme, CallTimer callTimer,
      {required bool isEnd}) {
    var callHour = callTimer.hours.toString();
    var callMin = callTimer.minutes.toString();
    var callSecond = callTimer.seconds.toString();
    callHour = callHour.length != 2 ? '0$callHour' : callHour;
    callMin = callMin.length != 2 ? '0$callMin' : callMin;
    callSecond = callSecond.length != 2 ? '0$callSecond' : callSecond;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.phone_fill,
          size: 25,
          color: isEnd ? theme.errorColor : theme.primaryColor,
        ),
        Text(
          '$callHour:$callMin:$callSecond',
          style: theme.textTheme.titleLarge!.copyWith(
            color: isEnd ? theme.errorColor : theme.primaryColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Animatable<Color?> background = TweenSequence<Color?>([
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.blueAccent,
        end: Colors.greenAccent,
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Colors.greenAccent,
        end: Colors.blueAccent,
      ),
    ),
  ]);

  PreferredSize _buildAppBar() {
    final theme = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: AppBar(
        backgroundColor: background.evaluate(
          AlwaysStoppedAnimation(animationController.value),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.text == "Connected")
              StreamBuilder<CallTimer>(
                stream: _callRepo.callTimer,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return callTimerWidget(
                      theme,
                      snapshot.data!,
                      isEnd: false,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            else
              Directionality(
                textDirection:
                    _i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.text != "Ended")
                      Text(
                        widget.callStatusOnScreen,
                        style: theme.textTheme.titleLarge!
                            .copyWith(color: theme.primaryColor),
                      )
                    else
                      FadeTransition(
                        opacity: _repeatEndCallAnimationController,
                        child: (_callRepo.isConnected)
                            ? Directionality(
                                textDirection: TextDirection.ltr,
                                child: callTimerWidget(
                                  theme,
                                  _callRepo.callTimer.value,
                                  isEnd: true,
                                ),
                              )
                            : Text(
                                widget.callStatusOnScreen,
                                style: theme.textTheme.titleLarge!
                                    .copyWith(color: Colors.red),
                              ),
                      ),
                    if (widget.text == "Connecting" ||
                        widget.text == "Reconnecting" ||
                        widget.text == "Ringing" ||
                        widget.text == "Calling")
                      const DotAnimation()
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
