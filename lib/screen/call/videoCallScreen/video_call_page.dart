import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/call_bottom_icons.dart';
import 'package:deliver/screen/call/call_status.dart';
import 'package:deliver/screen/call/center_avatar_image_in_call.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/animated_gradient.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class VideoCallScreen extends StatefulWidget {
  final Uid roomUid;
  final RTCVideoRenderer localRenderer;
  final CallStatus callStatus;
  final String callStatusOnScreen;
  final RTCVideoRenderer remoteRenderer;
  final void Function() hangUp;
  final bool isIncomingCall;

  const VideoCallScreen({
    super.key,
    required this.callStatus,
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
  final _uxService = GetIt.I.get<UxService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);

  Offset position = const Offset(20, 95);

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _logger.i("call dispose in start call status=${widget.callStatus}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(
        _uxService
            .getCorePalette()
            .primary
            .get(_uxService.themeIsDark ? 50 : 70),
      ),
      appBar: _buildAppBar(),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          const AnimatedGradient(),
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
                                          mirror: !_callRepo
                                              .incomingVideoSwitch.value,
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
                                          mirror: true,
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
                                    child: InteractiveViewer(
                                      // Set it to false to prevent panning.
                                      minScale: 0.5,
                                      maxScale: 4,
                                      child: RTCVideoView(
                                        snapshot.data!
                                            ? widget.localRenderer
                                            : widget.remoteRenderer,
                                        mirror: !(snapshot.data! &&
                                            _callRepo.switching.value),
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.3,
                                    ),
                                    child: SizedBox(
                                      width: x,
                                      height: y,
                                      child: CenterAvatarInCall(
                                        roomUid: widget.roomUid,
                                      ),
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
          CallBottomRow(
            hangUp: widget.hangUp,
            isIncomingCall: widget.isIncomingCall,
          ),
        ],
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
          child: Draggable(
            feedback: SizedBox(
              width: width,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: RTCVideoView(
                  switching.value
                      ? widget.remoteRenderer
                      : widget.localRenderer,
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
                    x - width - horizentalMargin,
                    y - height - verticalMargin,
                  );
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
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                              mirror: !(snapshot.data ?? false),
                            ),
                          )
                        : inComingVideo
                            ? InteractiveViewer(
                                // Set it to false to prevent panning.
                                minScale: 0.5,
                                maxScale: 4,
                                child: RTCVideoView(
                                  widget.remoteRenderer,
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
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: CallStatusWidget(
        callStatus: widget.callStatus,
        callStatusOnScreen: widget.callStatusOnScreen,
      ),
    );
  }
}
