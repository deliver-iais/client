// ignore_for_file: file_names, constant_identifier_names, avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/box/call_event.dart' as call_event;
import 'package:deliver/box/call_info.dart' as call_info;
import 'package:deliver/box/current_call_info.dart' as current_call_info;
import 'package:deliver/box/dao/call_info_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart' as call_pb;
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';

enum CallStatus {
  CREATED,
  IS_RINGING,
  DECLINED,
  BUSY,
  ENDED,
  NO_CALL,
  ACCEPTED,
  CONNECTING,
  RECONNECTING,
  CONNECTED,
  DISCONNECTED,
  FAILED,
  NO_ANSWER
}

class CallRepo {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _callService = GetIt.I.get<CallService>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _callListDao = GetIt.I.get<CallInfoDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

  final _candidateNumber = 10;
  final _candidateTimeLimit = 1000; // 1 sec

  late RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCVideoRenderer get getLocalRenderer => _localRenderer;

  RTCVideoRenderer get getRemoteRenderer => _remoteRenderer;

  bool get isSpeaker => _isSpeaker;

  bool get isMicMuted => _isMicMuted;
  MediaStream? _localStream;
  MediaStream? _localStreamShare;
  RTCRtpSender? _videoSender;

  // ignore: unused_field
  RTCRtpSender? _audioSender;
  RTCDataChannel? _dataChannel;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp = "";
  String _answerSdp = "";
  int _candidateStartTime = 0;

  RTCPeerConnection? _peerConnection;
  Map<String, dynamic> _sdpConstraints = {};

  bool _isSharing = false;
  bool _isCaller = false;
  bool _isVideo = false;
  bool _isConnected = false;
  bool _isSpeaker = false;
  bool _isMicMuted = false;
  bool _isInitRenderer = false;
  bool _isDCRecived = false;
  bool _reconnectTry = false;
  bool _isEnded = false;

  bool get isCaller => _isCaller;
  Uid? _roomUid;

  Uid? get roomUid => _roomUid;

  bool get isVideo => _isVideo;
  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;

  int? _startCallTime = 0;
  int? _callDuration = 0;
  int? _endCallTime = 0;

  int? get callDuration => _callDuration;
  Timer? timerDeclined;
  Timer? timerResendOffer;
  Timer? timerResendAnswer;
  Timer? timerConnectionFailed;
  Timer? timerDisconnected;
  Timer? timerEndCallDispose;
  BehaviorSubject<CallTimer> callTimer =
      BehaviorSubject.seeded(CallTimer(0, 0, 0));
  Timer? timer;

  ReceivePort? _receivePort;

  CallRepo() {
    _callService.watchCurrentCall().listen((call) {
      if (call != null) {
        _logger.i("read call from DB");
        if (call.expireTime > clock.now().millisecondsSinceEpoch &&
            _callService.getUserCallState == UserCallState.NOCALL) {
          _callService.callEvents.add(
            CallEvents.callEvent(
              call_pb.CallEvent()
                ..newStatus =
                    _callService.findCallEventStatusDB(call.callEvent.newStatus)
                ..id = call.callEvent.id
                ..callDuration = Int64(call.callEvent.callDuration)
                ..endOfCallTime = Int64(call.callEvent.endOfCallTime)
                ..callType = _callService
                    .findProtoCallEventType(call.callEvent.callType),
              roomUid: call.from.asUid(),
              callId: call.callEvent.id,
              time: call.expireTime - 60000,
            ),
          );
        }
      }
    });
    _callService.callEvents.listen((event) {
      switch (event.callType) {
        case CallTypes.Answer:
          timerResendOffer!.cancel();
          _receivedCallAnswer(event.callAnswer!);
          break;
        case CallTypes.Offer:
          _receivedCallOffer(event.callOffer!);
          break;
        case CallTypes.Event:
          final callEvent = event.callEvent;
          switch (callEvent!.newStatus) {
            case CallEvent_CallStatus.IS_RINGING:
              if (_callService.getCallId == callEvent.id) {
                callingStatus.add(CallStatus.IS_RINGING);
                if (_isCaller) {
                  _audioService.playBeepSound();
                }
              }
              break;
            case CallEvent_CallStatus.CREATED:
              if (_callService.getUserCallState == UserCallState.NOCALL
                  //&& (clock.now().millisecondsSinceEpoch - event.time < 50000)
                  ) {
                _callService.setUserCallState = UserCallState.INUSERCALL;
                //get call Info and Save on DB
                final currentCallEvent = call_event.CallEvent(
                  callDuration: callEvent.callDuration.toInt(),
                  endOfCallTime: callEvent.endOfCallTime.toInt(),
                  callType: _callService.findCallEventType(callEvent.callType),
                  newStatus: _callService
                      .findCallEventStatusProto(callEvent.newStatus),
                  id: callEvent.id,
                );
                final callInfo = current_call_info.CurrentCallInfo(
                  callEvent: currentCallEvent,
                  from: event.roomUid!.asString(),
                  to: _authRepo.currentUserUid.asString(),
                  expireTime: event.time + 60000,
                );

                _callService.saveCallOnDb(callInfo);
                _logger.i("save call on db!");

                _callService
                  ..setCallOwner = callEvent.memberOrCallOwnerPvp
                  ..setCallId = callEvent.id;

                if (callEvent.callType == CallEvent_CallType.VIDEO) {
                  _logger.i("VideoCall");
                  _isVideo = true;
                } else {
                  _isVideo = false;
                }
                _incomingCall(
                  event.roomUid!,
                  false,
                  _callService.writeCallEventsToJson(event),
                );
              } else if (event.roomUid == _roomUid) {
                _incomingCall(
                  event.roomUid!,
                  true,
                  _callService.writeCallEventsToJson(event),
                );
              } else if (callEvent.id != _callService.getCallId) {
                final endOfCallDuration = clock.now().millisecondsSinceEpoch;
                _messageRepo.sendCallMessage(
                  CallEvent_CallStatus.BUSY,
                  event.roomUid!,
                  callEvent.id,
                  0,
                  endOfCallDuration,
                  _isVideo
                      ? CallEvent_CallType.VIDEO
                      : CallEvent_CallType.AUDIO,
                );
              }
              break;
            case CallEvent_CallStatus.BUSY:
              if (_callService.getCallId == callEvent.id) {
                receivedBusyCall();
              }
              break;
            case CallEvent_CallStatus.DECLINED:
              if (_callService.getCallId == callEvent.id) {
                receivedDeclinedCall();
              }
              break;
            case CallEvent_CallStatus.ENDED:
              if (_callService.getCallId == callEvent.id) {
                receivedEndCall(callEvent.callDuration.toInt());
              }
              break;
            case CallEvent_CallStatus.JOINED:
              modifyRoutingByNotificationAcceptCallInBackgroundInAndroid
                  .add(event.roomUid!.asString());
              if (_callService.getUserCallState == UserCallState.NOCALL) {
                _callService
                  ..setUserCallState = UserCallState.INUSERCALL
                  ..setCallOwner = callEvent.memberOrCallOwnerPvp
                  ..setCallId = callEvent.id;

                if (callEvent.callType == CallEvent_CallType.VIDEO) {
                  _logger.i("VideoCall");
                  _isVideo = true;
                } else {
                  _isVideo = false;
                }
              }
              break;
            case CallEvent_CallStatus.INVITE:
            case CallEvent_CallStatus.KICK:
            case CallEvent_CallStatus.LEFT:
              _logger.w(
                "this case only for group call and it's a bug if happened on PvP call",
              );
              break;
          }
          break;
        case CallTypes.None:
          break;
      }
    });
  }

  /*
  * initial Variable for Render Call Between 2 Client
  * */
  Future<void> initCall({bool isOffer = false}) async {
    await _createPeerConnection(isOffer).then((pc) {
      _peerConnection = pc;
    });
  }

  Future<RTCPeerConnection> _createPeerConnection(bool isOffer) async {
    final _iceServers = <String, dynamic>{
      'iceServers': [
        {'url': STUN_SERVER_URL},
        {'url': STUN_SERVER_URL_2},
        {
          'url': TURN_SERVER_URL,
          'username': TURN_SERVER_USERNAME,
          'credential': TURN_SERVER_PASSWORD
        },
        {
          'url': TURN_SERVER_URL_2,
          'username': TURN_SERVER_USERNAME_2,
          'credential': TURN_SERVER_PASSWORD_2
        },
      ]
    };

    final _config = <String, dynamic>{
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ]
    };

    _sdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": _isVideo,
        "IceRestart": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    final pc = await createPeerConnection(_iceServers, _config);

    final camAudioTrack = _localStream!.getAudioTracks()[0];
    if (!isWindows) {
      camAudioTrack.enableSpeakerphone(false);
    }
    _audioSender = await pc.addTrack(camAudioTrack, _localStream!);

    if (_isVideo) {
      final camVideoTrack = _localStream!.getVideoTracks()[0];
      _videoSender = await pc.addTrack(camVideoTrack, _localStream!);
    }

    pc
      ..onIceConnectionState = (e) {
        _logger.i(e);
        // we can do special work on every change in candidate Connection State
        switch (e) {
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            if (!_reconnectTry) {
              _reconnectTry = true;
              callingStatus.add(CallStatus.RECONNECTING);
              _audioService.stopBeepSound();
              _reconnectingAfterFailedConnection();
              timerDisconnected = Timer(const Duration(seconds: 10), () {
                if (callingStatus.value == CallStatus.RECONNECTING) {
                  callingStatus.add(CallStatus.NO_ANSWER);
                  _logger.i("Disconnected and Call End!");
                  endCall();
                }
              });
            }
            break;
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
            callingStatus.add(CallStatus.CONNECTED);
            vibrate(duration: 50);
            _audioService.stopBeepSound();
            if (_reconnectTry) {
              _reconnectTry = false;
              timerDisconnected?.cancel();
            } else if (_isCaller) {
              timerResendAnswer!.cancel();
            }
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            Timer(const Duration(seconds: 1), () {
              if (!_reconnectTry && !_isEnded) {
                callingStatus.add(CallStatus.DISCONNECTED);
                _audioService.stopBeepSound();
              }
            });
            break;
          case RTCIceConnectionState.RTCIceConnectionStateNew:
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
          //The ICE agent has finished gathering candidates, has checked all pairs against one another, and has found a connection for all components.
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          case RTCIceConnectionState.RTCIceConnectionStateCount:
          case RTCIceConnectionState.RTCIceConnectionStateClosed:
            // this cases no matter and don't have impact on our Work
            break;
        }
      }

      //https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/connectionState
      ..onConnectionState = (state) {
        _logger.i("onConnectionState $state");
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            //when connection Connected Status we Set some limit on bitRate
            // var params = _videoSender.parameters;
            // if (params.encodings.isEmpty) {
            //   params.encodings = [];
            //   params.encodings.add(new RTCRtpEncoding());
            // }
            //
            // params.encodings[0].maxBitrate =
            //     WEBRTC_MAX_BITRATE; // 256 kbps and use less about 150-160 kbps
            // params.encodings[0].minBitrate = WEBRTC_MIN_BITRATE; // 128 kbps
            // params.encodings[0].maxFramerate = WEBRTC_MAX_FRAME_RATE;
            //     params.encodings[0].scaleResolutionDownBy = 2;
            // await _videoSender.setParameters(params);
            callingStatus.add(CallStatus.CONNECTED);
            vibrate(duration: 50);
            _audioService.stopBeepSound();
            if (_reconnectTry) {
              _reconnectTry = false;
              timerDisconnected?.cancel();
            } else if (_isCaller) {
              timerResendAnswer!.cancel();
            }
            if (!isWeb) {
              _startCallTimerAndChangeStatus();
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            Timer(const Duration(seconds: 1), () {
              if (!_reconnectTry && !_isEnded) {
                callingStatus.add(CallStatus.DISCONNECTED);
                _audioService.stopBeepSound();
              }
            });
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            //Try reconnect
            if (!_reconnectTry) {
              _reconnectTry = true;
              callingStatus.add(CallStatus.RECONNECTING);
              _audioService.stopBeepSound();
              _reconnectingAfterFailedConnection();
              timerDisconnected = Timer(const Duration(seconds: 15), () {
                if (callingStatus.value == CallStatus.RECONNECTING) {
                  callingStatus.add(CallStatus.NO_ANSWER);
                  _logger.i("Disconnected and Call End!");
                  endCall();
                }
              });
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            _logger.i("Call Peer Connection Closed Successfully");
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateNew:
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            // this cases no matter and don't have any impact on our work
            break;
        }
      }
      ..onIceCandidate = (e) {
        if (e.candidate != null) {
          _candidate.add({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex!,
          });
        }
      }
      ..onIceGatheringState = (state) {
        if (state == RTCIceGatheringState.RTCIceGatheringStateGathering) {
          //when we go on this stage after about 2 sec all candidate revived and we can sending them all
          _logger.i("RTCIceGatheringStateGathering");
          if (isOffer) {
            _calculateCandidateAndSendOffer();
          } else {
            _calculateCandidateAndSendAnswer();
          }
        }
        if (state == RTCIceGatheringState.RTCIceGatheringStateNew) {
          _logger.i("RTCIceGatheringStateNew");
        }
        if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
          //take too long about 40 sec to Enter on this stage
          //then we move calculate candidate and send them to RTCIceGatheringStateGathering stage
          _logger.i("RTCIceGatheringStateComplete");
        }
      }
      ..onAddStream = (stream) {
        _logger.i('addStream: ' + stream.id);
        onAddRemoteStream?.call(stream);
      }
      ..onRemoveStream = (stream) {
        onRemoveRemoteStream?.call(stream);
      }
      ..onDataChannel = (channel) {
        _logger.i("data Channel Received!!");
        _dataChannel = channel;
        _isDCRecived = true;
        //it means Connection is Connected
        _startCallTimerAndChangeStatus();
        _dataChannel!.onMessage = (data) {
          final status = data.text;
          _logger.i(status);
          // we need Decision making by state
          switch (status) {
            case STATUS_CAMERA_OPEN:
              mute_camera.add(true);
              break;
            case STATUS_CAMERA_CLOSE:
              mute_camera.add(false);
              break;
            case STATUS_MIC_OPEN:
              break;
            case STATUS_MIC_CLOSE:
              break;
            case STATUS_SHARE_SCREEN:
              break;
            case STATUS_SHARE_VIDEO:
              break;
            case STATUS_CONNECTION_FAILED:
              break;
            case STATUS_CONNECTION_DISCONNECTED:
              break;
            case STATUS_CONNECTION_CONNECTED:
              //when connection Connected Status we Set some limit on bitRate
              // var params = _videoSender.parameters;
              // if (params.encodings.isEmpty) {
              //   params.encodings = [];
              //   params.encodings.add(new RTCRtpEncoding());
              // }
              //
              // params.encodings[0].maxBitrate =
              //     WEBRTC_MAX_BITRATE; // 256 kbps and use less about 150-160 kbps
              // params.encodings[0].minBitrate = WEBRTC_MIN_BITRATE; // 128 kbps
              // params.encodings[0].maxFramerate = WEBRTC_MAX_FRAME_RATE;
              //     params.encodings[0].scaleResolutionDownBy = 2;
              // await _videoSender.setParameters(params);
              if (!_reconnectTry) {
                _startCallTimerAndChangeStatus();
              } else {
                callingStatus.add(CallStatus.CONNECTED);
                vibrate(duration: 50);
                _audioService.stopBeepSound();
                _reconnectTry = false;
              }
              break;
            case STATUS_CONNECTION_CONNECTING:
              callingStatus.add(CallStatus.CONNECTING);
              _audioService.stopBeepSound();
              break;
            case STATUS_CONNECTION_ENDED:
              //received end from Callee
              receivedEndCall(0);
              break;
          }
        };
      };

    return pc;
  }

  Future<void> _reconnectingAfterFailedConnection() async {
    if (!_isCaller) {
      _logger.i("try Reconnecting ...!");
      _offerSdp = await _createOffer();
    }
  }

  Future<void> _foregroundTaskInitializing() async {
    if (isAndroid) {
      await _initForegroundTask();
      await _startForegroundTask();
    }
  }

  Future<void> _startCallTimerAndChangeStatus() async {
    startCallTimer();
    if (_startCallTime == 0) {
      _startCallTime = clock.now().millisecondsSinceEpoch;
    }
    if (_isDCRecived) {
      await _dataChannel!
          .send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTED));
    }
    _logger.i("Start Call " + _startCallTime.toString());
    callingStatus.add(CallStatus.CONNECTED);
    vibrate(duration: 50).ignore();
    _audioService.stopBeepSound();
    if (timerConnectionFailed != null) {
      timerConnectionFailed!.cancel();
    }
    _isConnected = true;
  }

  Future<RTCDataChannel> _createDataChannel() async {
    final dataChannelDict = RTCDataChannelInit()..maxRetransmits = 15;

    final dataChannel = await _peerConnection!
        .createDataChannel("stateTransfer", dataChannelDict);

    dataChannel.onMessage = (data) {
      final status = data.text;
      _logger.i(status);
      // we need Decision making by state
      switch (status) {
        case STATUS_CAMERA_OPEN:
          mute_camera.add(true);
          break;
        case STATUS_CAMERA_CLOSE:
          mute_camera.add(false);
          break;
        case STATUS_MIC_OPEN:
          break;
        case STATUS_MIC_CLOSE:
          break;
        case STATUS_SHARE_SCREEN:
          break;
        case STATUS_SHARE_VIDEO:
          break;
        case STATUS_CONNECTION_FAILED:
          break;
        case STATUS_CONNECTION_DISCONNECTED:
          break;
        case STATUS_CONNECTION_CONNECTED:
          //when connection Connected Status we Set some limit on bitRate
          // var params = _videoSender.parameters;
          // if (params.encodings.isEmpty) {
          //   params.encodings = [];
          //   params.encodings.add(new RTCRtpEncoding());
          // }
          //
          // params.encodings[0].maxBitrate =
          //     WEBRTC_MAX_BITRATE; // 256 kbps and use less about 150-160 kbps
          // params.encodings[0].minBitrate = WEBRTC_MIN_BITRATE; // 128 kbps
          // params.encodings[0].maxFramerate = WEBRTC_MAX_FRAME_RATE;
          //     params.encodings[0].scaleResolutionDownBy = 2;
          // await _videoSender.setParameters(params);
          if (!_isConnected) {
            _startCallTimerAndChangeStatus();
          }
          if (timerConnectionFailed != null) {
            timerConnectionFailed!.cancel();
          }
          break;
        case STATUS_CONNECTION_CONNECTING:
          callingStatus.add(CallStatus.CONNECTING);
          _audioService.stopBeepSound();
          break;
      }
    };
    return dataChannel;
  }

  /*
  * get Access from User for Camera and Microphone
  * */
  Future<MediaStream> _getUserMedia() async {
    // Provide your own width, height and frame rate here
    Map<String, dynamic> mediaConstraints;
    if (isWindows) {
      mediaConstraints = {
        'video': _isVideo
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'maxWidth': '720',
                  'minHeight': '360',
                  'maxHeight': '480',
                  'minFrameRate': '20',
                  'maxFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
        'audio': {
          'sampleSize': '16',
          'channelCount': '2',
        }
      };
    } else {
      mediaConstraints = {
        'video': _isVideo
            ? {
                'mandatory': {
                  'minWidth': '480',
                  'maxWidth': '640',
                  'minHeight': '320',
                  'maxHeight': '480',
                  'minFrameRate': '20',
                  'maxFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
        'audio': {
          'sampleSize': '16',
          'channelCount': '2',
        }
      };
    }

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    onLocalStream?.call(stream);

    return stream;
  }

  Future<MediaStream> _getUserDisplay() async {
    final mediaConstraints = <String, dynamic>{'audio': false, 'video': true};

    final stream =
        await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    return stream;
  }

  //https://github.com/flutter-webrtc/flutter-webrtc/issues/831 issue for Android
  //https://github.com/flutter-webrtc/flutter-webrtc/issues/799 issue for Windows
  Future<void> shareScreen() async {
    if (!_isSharing) {
      _localStreamShare = await _getUserDisplay();
      final screenVideoTrack = _localStreamShare!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(screenVideoTrack);
      onLocalStream?.call(_localStreamShare!);
      _isSharing = true;
      return _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
    } else {
      final camVideoTrack = _localStream!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(camVideoTrack);
      onLocalStream?.call(_localStream!);
      _isSharing = false;
      return _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_VIDEO));
    }
  }

  Future<void> _initForegroundTask() async {
    await FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'endCall', text: 'End Call'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    ReceivePort? receivePort;
    if (await FlutterForegroundTask.isRunningService) {
      receivePort = await FlutterForegroundTask.restartService();
    } else {
      receivePort = await FlutterForegroundTask.startService(
        notificationTitle: 'Deliver Call on BackGround',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message == "endCall") {
          endCall();
        } else {
          _logger.i('receive callStatus: $message');
        }
      });

      return true;
    }

    return false;
  }

  Future<bool> _stopForegroundTask() async =>
      FlutterForegroundTask.stopService();

  /*
  * For Close Microphone
  * */
  bool muteMicrophone() {
    if (_localStream != null) {
      final enabled = _localStream!.getAudioTracks()[0].enabled;
      if (_isConnected) {
        if (enabled) {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_CLOSE));
        } else {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_OPEN));
        }
      }
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      _isMicMuted = !_isMicMuted;
      return enabled;
    }
    return false;
  }

  bool enableSpeakerVoice() {
    if (_localStream != null) {
      final camAudioTrack = _localStream!.getAudioTracks()[0];
      if (_isSpeaker) {
        camAudioTrack.enableSpeakerphone(false);
      } else {
        camAudioTrack.enableSpeakerphone(true);
      }
      return _isSpeaker = !_isSpeaker;
    }
    return false;
  }

  void switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  /*
  * For Close Camera
  * */
  bool muteCamera() {
    if (_localStream != null) {
      final enabled = _localStream!.getVideoTracks()[0].enabled;
      if (_isConnected) {
        if (enabled) {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_CAMERA_CLOSE));
        } else {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_CAMERA_OPEN));
        }
      }
      _localStream!.getVideoTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  Future<void> _incomingCall(
    Uid roomId,
    bool isDuplicated,
    String callEventJson,
  ) async {
    if (!isDuplicated) {
      unawaited(
        _notificationServices.notifyIncomingCall(
          roomId.asString(),
          callEventJson: callEventJson,
        ),
      );
    }
    _roomUid = roomId;
    _logger.i("incoming Call and Created!!! - " + isDuplicated.toString());
    callingStatus.add(CallStatus.CREATED);
    final endOfCallDuration = clock.now().millisecondsSinceEpoch;
    await _messageRepo.sendCallMessage(
      CallEvent_CallStatus.IS_RINGING,
      _roomUid!,
      _callService.getCallId,
      0,
      endOfCallDuration,
      _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
    );
  }

  Future<void> startCall(Uid roomId, {bool isVideo = false}) async {
    if (_callService.getUserCallState == UserCallState.NOCALL) {
      //can't call another ppl or received any call notification
      _callService.setUserCallState = UserCallState.INUSERCALL;

      _isCaller = true;
      _isVideo = isVideo;
      _roomUid = roomId;
      await initCall();
      _logger.i("Start Call and Created !!!");
      callingStatus.add(CallStatus.CREATED);
      //Set Timer 50 sec for end call
      timerDeclined = Timer(const Duration(seconds: 50), () {
        if (callingStatus.value == CallStatus.IS_RINGING ||
            callingStatus.value == CallStatus.CREATED) {
          callingStatus.add(CallStatus.NO_ANSWER);
          _audioService.stopBeepSound();
          _logger.i("User Can't Answer!");
          endCall();
        }
      });
      _callIdGenerator();
      _sendStartCallEvent();
      await _foregroundTaskInitializing();
    } else {
      _logger.i("User on Call ... !");
    }
  }

  void _sendStartCallEvent() {
    // TODO(AmirHossein): handle recivied Created on fetchMessage when User offline then go online
    final endOfCallDuration = clock.now().millisecondsSinceEpoch;
    _messageRepo.sendCallMessageWithMemberOrCallOwnerPvp(
      CallEvent_CallStatus.CREATED,
      _roomUid!,
      _callService.getCallId,
      0,
      endOfCallDuration,
      _authRepo.currentUserUid,
      _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
    );
  }

  void _callIdGenerator() {
    final random = randomAlphaNumeric(10);
    final time = clock.now().millisecondsSinceEpoch;
    //call event id: (Epoch time milliseconds)-(Random String with alphabet and numerics with 10 characters length)
    final callId = time.toString() + "-" + random;
    _callService.setCallId = callId;
  }

  Future<void> acceptCall(Uid roomId) async {
    if (isWindows) {
      _notificationServices.cancelRoomNotifications(roomUid!.node);
    }
    _roomUid = roomId;
    callingStatus.add(CallStatus.ACCEPTED);
    _dataChannel = await _createDataChannel();
    _offerSdp = await _createOffer();
    callingStatus.add(CallStatus.CONNECTING);
    _audioService.stopBeepSound();

    //after accept Call w8 for 30 sec if don't connecting force end Call
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED && !_reconnectTry) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.NO_ANSWER);
        _audioService.stopBeepSound();
        endCall();
      }
    });
    await _foregroundTaskInitializing();
  }

  Future<void> declineCall() async {
    if (_callService.getUserCallState == UserCallState.INUSERCALL) {
      if (isWindows) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      _logger.i("declineCall");
      callingStatus.add(CallStatus.DECLINED);
      final endOfCallDuration = clock.now().millisecondsSinceEpoch;
      await _messageRepo.sendCallMessage(
        CallEvent_CallStatus.DECLINED,
        _roomUid!,
        _callService.getCallId,
        0,
        endOfCallDuration,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
      );
      await _dispose();
    }
  }

  Future<void> _receivedCallAnswer(CallAnswer callAnswer) async {
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(callAnswer.body);
    await _setCallCandidate(callAnswer.candidates);
  }

  //here we have accepted Call
  Future<void> _receivedCallOffer(CallOffer callOffer) async {
    if (!_reconnectTry) {
      callingStatus.add(CallStatus.ACCEPTED);
    }
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(callOffer.body);
    await _setCallCandidate(callOffer.candidates);
    if (!_reconnectTry) {
      callingStatus.add(CallStatus.CONNECTING);
      _audioService.stopBeepSound();
    }
    //And Create Answer for Calle
    if (!_reconnectTry) {
      _answerSdp = await _createAnswer();
    }
  }

  Future<void> _setCallCandidate(String candidatesJson) async {
    final candidates = (jsonDecode(candidatesJson) as List)
        .map(
          (data) => RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMlineIndex'],
          ),
        )
        .toList();
    await _setCandidate(candidates);
  }

  Future<void> receivedBusyCall() async {
    callingStatus.add(CallStatus.BUSY);
    await _dispose();
  }

  Future<void> receivedDeclinedCall() async {
    _logger.i("get declined");
    callingStatus.add(CallStatus.DECLINED);
    await _dispose();
  }

  Future<void> receivedEndCall(int callDuration) async {
    if (!_isEnded) {
      _isEnded = true;
      _logger.i("Call Duration Received: " + callDuration.toString());
      await cancelCallNotification();
      if (isWindows) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      if (_isCaller) {
        _callDuration = calculateCallEndTime();
        _logger.i("Call Duration on Caller(1): " + _callDuration.toString());
        final endOfCallDuration = clock.now().millisecondsSinceEpoch;
        await _messageRepo.sendCallMessage(
          CallEvent_CallStatus.ENDED,
          _roomUid!,
          _callService.getCallId,
          _callDuration!,
          endOfCallDuration,
          _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
        );
      } else {
        if (timerEndCallDispose != null) {
          timerEndCallDispose!.cancel();
        }
        _callDuration = callDuration;
      }
      await _dispose();
    }
  }

  Future<void> cancelCallNotification() async {
    if (isAndroid && !_isCaller) {
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
      await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    }
  }

  // TODO(AmirHossein): removed Force End Call and we need Handle it with third-party Service.
  void endCall() {
    if (callingStatus.value != CallStatus.ENDED) {
      if (isWindows) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      if (_callService.getUserCallState != CallStatus.NO_CALL) {
        if (_isCaller) {
          receivedEndCall(0);
        } else {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_ENDED));
          timerEndCallDispose = Timer(const Duration(seconds: 8), () {
            // if don't received EndCall from callee we force to end call
            _dispose();
          });
        }
      }
    }
  }

  int calculateCallEndTime() {
    var time = 0;
    if (_startCallTime != null && _isConnected) {
      _endCallTime = clock.now().millisecondsSinceEpoch;
      time = _endCallTime! - _startCallTime!;
    }
    return time;
  }

  Future<void> _setRemoteDescriptionOffer(String remoteSdp) async {
    final dynamic session = await jsonDecode(remoteSdp);

    final sdp = write(session, null);

    final description = RTCSessionDescription(sdp, 'offer');

    await _peerConnection!.setRemoteDescription(description);
  }

  Future<void> _setRemoteDescriptionAnswer(String remoteSdp) async {
    final dynamic session = await jsonDecode(remoteSdp);

    final sdp = write(session, null);

    final description = RTCSessionDescription(sdp, 'answer');

    await _peerConnection!.setRemoteDescription(description);
  }

  Future<String> _createAnswer() async {
    final description = await _peerConnection!.createAnswer(_sdpConstraints);

    final session = parse(description.sdp.toString());
    final answerSdp = json.encode(session);
    _logger.i("Answer: \n" + answerSdp);

    unawaited(_peerConnection!.setLocalDescription(description));

    return answerSdp;
  }

  Future<String> _createOffer() async {
    final description = await _peerConnection!.createOffer(_sdpConstraints);
    //get SDP as String
    final session = parse(description.sdp.toString());
    final offerSdp = json.encode(session);
    _logger.i("Offer: \n" + offerSdp);
    unawaited(_peerConnection!.setLocalDescription(description));
    return offerSdp;
  }

  Future<void> _waitUntilCandidateConditionDone() async {
    final completer = Completer();
    _logger.i(
      "Time for w8:" +
          (clock.now().millisecondsSinceEpoch - _candidateStartTime).toString(),
    );
    if ((_candidate.length >= _candidateNumber) ||
        (clock.now().millisecondsSinceEpoch - _candidateStartTime >
            _candidateTimeLimit)) {
      completer.complete();
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
      return _waitUntilCandidateConditionDone();
    }
    return completer.future;
  }

  Future<void> _calculateCandidateAndSendOffer() async {
    _candidateStartTime = clock.now().millisecondsSinceEpoch;
    //w8 till candidate gathering conditions complete
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :" + _candidate.length.toString());
    // Send Candidate to Receiver
    final jsonCandidates = jsonEncode(_candidate);
    //Send offer and Candidate as message to Receiver
    final callOfferByClient = (CallOfferByClient()
      ..id = _callService.getCallId
      ..body = _offerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallOffer(callOfferByClient);
    timerResendOffer = Timer(const Duration(seconds: 8), () {
      _coreServices.sendCallOffer(callOfferByClient);
    });
  }

  Future<void> _calculateCandidateAndSendAnswer() async {
    _candidateStartTime = clock.now().millisecondsSinceEpoch;
    //w8 till candidate gathering conditions complete
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :" + _candidate.length.toString());
    // Send Candidate back to Sender
    final jsonCandidates = jsonEncode(_candidate);
    //Send Answer and Candidate as message to Sender
    final callAnswerByClient = (CallAnswerByClient()
      ..id = _callService.getCallId
      ..body = _answerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallAnswer(callAnswerByClient);

    if (_reconnectTry) {
      callingStatus.add(CallStatus.RECONNECTING);
      _audioService.stopBeepSound();
    }

    timerResendAnswer = Timer(const Duration(seconds: 8), () {
      _coreServices.sendCallAnswer(callAnswerByClient);
    });

    //Set Timer 30 sec for end call if Call doesn't Connected
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.NO_ANSWER);
        _audioService.stopBeepSound();
        endCall();
      }
    });
  }

  Future<void> _setCandidate(List<RTCIceCandidate> candidates) async {
    for (final candidate in candidates) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

  //Windows memory leak Warning!! https://github.com/flutter-webrtc/flutter-webrtc/issues/752
  Future<void> _dispose() async {
    if (isAndroid) {
      _receivePort?.close();
      await _stopForegroundTask();
      if (!_isCaller) {
        await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
          isVisible: false,
        );
      }
    }
    if (timer != null) {
      _logger.i("timer canceled");
      timer!.cancel();
    }

    if (_isCaller) {
      if (_isConnected) {
        await _dataChannel?.close();
        timerConnectionFailed!.cancel();
      }
      timerDeclined!.cancel();
    }

    _logger.i("end call in service");
    await _cleanLocalStream();
    //await _cleanRtpSender();
    if (_peerConnection != null) {
      await _peerConnection?.close();
      await _peerConnection?.dispose();
    }
    _candidate = [];
    callingStatus.add(CallStatus.ENDED);
    Timer(const Duration(milliseconds: 1500), () async {
      if (_routingService.canPop()) {
        _routingService.pop();
      }
      _roomUid = null;
      callingStatus.add(CallStatus.NO_CALL);
    });
    _audioService.stopBeepSound();
    // Timer(const Duration(seconds: 2), () async {
    //  callingStatus.add(CallStatus.NO_CALL);
    // });
    switching.add(false);
    _offerSdp = "";
    _answerSdp = "";
    _isSharing = false;
    _isMicMuted = false;
    _isSpeaker = false;
    _isCaller = false;
    _isVideo = false;
    _isConnected = false;
    _reconnectTry = false;
    _callDuration = 0;
    _startCallTime = 0;
    _callDuration = 0;
    callTimer.add(CallTimer(0, 0, 0));
    Timer(const Duration(seconds: 2), () async {
      if (_isInitRenderer) {
        await disposeRenderer();
      }
      await _callService.clearCallData(forceToClearData: true);
      _isEnded = false;
    });
  }

  Future<void> initRenderer() async {
    if (!_isInitRenderer) {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _logger.i("Initialize Renderers");
      _isInitRenderer = true;
    }
  }

  Future<void> disposeRenderer() async {
    _logger.i("Dispose!");
    if (_isInitRenderer) {
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
      _isInitRenderer = false;
      _logger.i("Dispose Renderers");
      _localRenderer = RTCVideoRenderer();
      _remoteRenderer = RTCVideoRenderer();
    }
  }

  void startCallTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      callTimer.value.seconds = callTimer.value.seconds + 1;
      if (callTimer.value.seconds > 59) {
        callTimer.value.minutes += 1;
        callTimer.value.seconds = 0;
        if (callTimer.value.minutes > 59) {
          callTimer.value.hours += 1;
          callTimer.value.minutes = 0;
        }
      }
      callTimer.add(
        CallTimer(
          callTimer.value.seconds,
          callTimer.value.minutes,
          callTimer.value.hours,
        ),
      );
    });
  }

  Future<void> _cleanLocalStream() async {
    await _stopSharingStream();
    if (_localStream != null) {
      _localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
  }

  Future<void> _stopSharingStream() async {
    if (_localStreamShare != null) {
      _localStreamShare!.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStreamShare!.dispose();
      _localStreamShare = null;
    }
  }

  // ignore: non_constant_identifier_names
  BehaviorSubject<bool> mute_camera = BehaviorSubject.seeded(true);
  BehaviorSubject<CallStatus> callingStatus =
      BehaviorSubject.seeded(CallStatus.NO_CALL);
  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);

  Future<void> fetchUserCallList(
    Uid roomUid,
  ) async {
    try {
      var date = clock.now();
      for (var i = 0; i < 6; i++) {
        final callLists = await _queryServiceClient.fetchUserCalls(
          FetchUserCallsReq()
            ..roomUid = roomUid
            ..limit = 200
            ..pointer = Int64(clock.now().millisecondsSinceEpoch)
            ..fetchingDirectionType =
                FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH
            ..month = date.month - 1
            ..year = date.year,
        );
        for (final call in callLists.cellEvents) {
          final callEvent = call_event.CallEvent(
            callDuration: call.callEvent.callDuration.toInt(),
            endOfCallTime: call.callEvent.endOfCallTime.toInt(),
            callType: _callService.findCallEventType(call.callEvent.callType),
            newStatus:
                _callService.findCallEventStatusProto(call.callEvent.newStatus),
            id: call.callEvent.id,
          );
          final callList = call_info.CallInfo(
            callEvent: callEvent,
            from: call.from.asString(),
            to: call.to.asString(),
          );
          await _callListDao.save(callList);
        }
        date = date.subtract(const Duration(days: 30));
      }
    } catch (e) {
      _logger.e(e);
    }
  }
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  // ignore: prefer_typing_uninitialized_variables
  late final SendPort? sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    sPort = sendPort;
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    if (id == "endCall") {
      sPort?.send("endCall");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }
}
