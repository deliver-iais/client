import 'package:deliver/models/call_timer.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);

  final width = 150.0;
  final height = 200.0;
  Offset position = const Offset(20, 85);

  @override
  void initState() {
    _initRepeatEndCallAnimation();

    super.initState();
  }

  @override
  Future<void> dispose() async {
    _repeatEndCallAnimationController.dispose();
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
    final x = MediaQuery.of(context).size.width;
    final y = MediaQuery.of(context).size.height;

    return Scaffold(
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
            ]),
            builder: (c, s) {
              return isWindows
                  ? OrientationBuilder(
                      builder: (context, orientation) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.15,
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
                                      child: RTCVideoView(
                                        objectFit: RTCVideoViewObjectFit
                                            .RTCVideoViewObjectFitCover,
                                        widget.remoteRenderer,
                                        filterQuality: FilterQuality.high,
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
                                      child: RTCVideoView(
                                        objectFit: RTCVideoViewObjectFit
                                            .RTCVideoViewObjectFitCover,
                                        widget.remoteRenderer,
                                        mirror: true,
                                        filterQuality: FilterQuality.high,
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
                                      child: RTCVideoView(
                                        objectFit: RTCVideoViewObjectFit
                                            .RTCVideoViewObjectFitCover,
                                        widget.localRenderer,
                                        filterQuality: FilterQuality.high,
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
                                      child: RTCVideoView(
                                        objectFit: RTCVideoViewObjectFit
                                            .RTCVideoViewObjectFitCover,
                                        widget.localRenderer,
                                        mirror: true,
                                        filterQuality: FilterQuality.high,
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
                  : Stack(
                      children: [
                        if (_callRepo.incomingSharing.value ||
                            (switching.value && _callRepo.sharing.value))
                          SizedBox(
                            width: x,
                            height: y,
                            child: RTCVideoView(
                              switching.value
                                  ? widget.localRenderer
                                  : widget.remoteRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          )
                        else if (_callRepo.incomingVideo.value ||
                            (switching.value && _callRepo.videoing.value))
                          SizedBox(
                            width: x,
                            height: y,
                            child: RTCVideoView(
                              switching.value
                                  ? widget.localRenderer
                                  : widget.remoteRenderer,
                              mirror: true,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                          )
                        else
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.15,
                            ),
                            child: CenterAvatarInCall(
                              roomUid: widget.roomUid,
                            ),
                          ),
                        if (_callRepo.videoing.value)
                          userVideoWidget(x, y, isMirror: true)
                        else if (_callRepo.sharing.value)
                          userVideoWidget(x, y, isMirror: false)
                      ],
                    );
            },
          ),
          CallBottomRow(
            hangUp: widget.hangUp,
            isIncomingCall: widget.isIncomingCall,
          ),
          Positioned(
            top: 20,
            child: Column(
              children: [
                if (widget.text == "Connected")
                  StreamBuilder<CallTimer>(
                    stream: _callRepo.callTimer,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.07,
                          ),
                          child: callTimerWidget(
                            theme,
                            snapshot.data!,
                            isEnd: false,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  )
                else
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.07,
                    ),
                    child: Directionality(
                      textDirection: _i18n.isPersian
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.text != "Ended")
                            Text(
                              widget.callStatusOnScreen,
                              style: theme.textTheme.titleLarge!
                                  .copyWith(color: Colors.white70),
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Positioned userVideoWidget(double x, double y, {required bool isMirror}) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: RTCVideoView(
              switching.value ? widget.remoteRenderer : widget.localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: isMirror,
            ),
          ),
        ),
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            if (offset.dx > x / 2 && offset.dy > y / 2) {
              position = Offset(x - width - 20, y - height - 85);
            }
            if (offset.dx < x / 2 && offset.dy > y / 2) {
              position = Offset(20, y - height - 85);
            }
            if (offset.dx > x / 2 && offset.dy < y / 2) {
              position = Offset(x - width - 20, 85);
            }
            if (offset.dx < x / 2 && offset.dy < y / 2) {
              position = const Offset(20, 85);
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
                child: RTCVideoView(
                  switching.value
                      ? widget.remoteRenderer
                      : widget.localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: isMirror,
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
      children: [
        Icon(
          CupertinoIcons.phone_fill,
          size: 25,
          color: isEnd ? Colors.red : Colors.white54,
        ),
        Text(
          '$callHour:$callMin:$callSecond',
          style: theme.textTheme.titleLarge!.copyWith(
            color: isEnd ? Colors.red : Colors.white54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
