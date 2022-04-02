// ignore_for_file: file_names, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/box/call_event.dart' as call_event;
import 'package:deliver/box/call_info.dart' as call_info;
import 'package:deliver/box/call_status.dart' as call_status;
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/dao/call_info_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
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
  IN_CALL,
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

  final _candidateNumber = 10;
  final _candidateTimeLimit = 1000; // 1 sec

  late RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCVideoRenderer get getLocalRenderer => _localRenderer;

  RTCVideoRenderer get getRemoteRenderer => _remoteRenderer;

  MediaStream? _localStream;
  MediaStream? _localStreamShare;
  RTCRtpSender? _videoSender;

  // ignore: unused_field
  RTCRtpSender? _audioSender;
  RTCDataChannel? _dataChannel;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp = "";
  String _answerSdp = "";
  String _callId = "";
  int _candidateStartTime = 0;

  RTCPeerConnection? _peerConnection;
  Map<String, dynamic> _sdpConstraints = {};

  bool _isSharing = false;
  bool _isCaller = false;
  bool _isVideo = false;
  bool _isConnected = false;
  bool _isSpeaker = false;
  bool _isInitRenderer = false;
  bool _isDCRecived = false;
  bool _reconnectTry = false;

  bool get isCaller => _isCaller;
  Uid? _roomUid;
  Uid? _callOwner;

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
  Timer? timerResendCreate;
  Timer? timerResendOffer;
  Timer? timerResendAnswer;
  Timer? timerConnectionFailed;
  Timer? timerDisconnected;
  BehaviorSubject<CallTimer> callTimer =
      BehaviorSubject.seeded(CallTimer(0, 0, 0));
  Timer? timer;

  ReceivePort? _receivePort;

  CallRepo() {
    _callService.callEvents.listen((event) async {
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
              if (_callId == callEvent.id) {
                timerResendCreate!.cancel();
                callingStatus.add(CallStatus.IS_RINGING);
              }
              break;
            case CallEvent_CallStatus.CREATED:
              if (event.roomUid == _roomUid ||
                  _callService.getUserCallState == UserCallState.NOCALL) {
                _callService.setUserCallState = UserCallState.INUSERCALL;
                _callOwner = callEvent.memberOrCallOwnerPvp;
                _callId = callEvent.id;
                if (callEvent.callType == CallEvent_CallType.VIDEO) {
                  _logger.i("VideoCall");
                  _isVideo = true;
                } else {
                  _isVideo = false;
                }
                _incomingCall(event.roomUid!);
              } else {
                final endOfCallDuration = DateTime.now().millisecondsSinceEpoch;
                _messageRepo.sendCallMessage(
                    CallEvent_CallStatus.BUSY,
                    event.roomUid!,
                    callEvent.id,
                    0,
                    endOfCallDuration,
                    _isVideo
                        ? CallEvent_CallType.VIDEO
                        : CallEvent_CallType.AUDIO);
              }
              break;
            case CallEvent_CallStatus.BUSY:
              if (_callId == callEvent.id) {
                timerResendCreate!.cancel();
                receivedBusyCall();
              }
              break;
            case CallEvent_CallStatus.DECLINED:
              if (_callId == callEvent.id) {
                timerResendCreate!.cancel();
                receivedDeclinedCall();
              }
              break;
            case CallEvent_CallStatus.ENDED:
              if (_callId == callEvent.id) {
                receivedEndCall(callEvent.callDuration.toInt());
              }
              break;
            case CallEvent_CallStatus.INVITE:
            case CallEvent_CallStatus.JOINED:
            case CallEvent_CallStatus.KICK:
            case CallEvent_CallStatus.LEFT:
              // TODO: Handle this case.
              break;
          }
          break;
        case CallTypes.None:
          // TODO: Handle this case.
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

  _createPeerConnection(bool isOffer) async {
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
        "OfferToReceiveVideo": _isVideo ? true : false,
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
              _reconnectingAfterFailedConnection();
              timerDisconnected = Timer(const Duration(seconds: 10), () {
                if (callingStatus.value == CallStatus.RECONNECTING) {
                  callingStatus.add(CallStatus.NO_ANSWER);
                  _logger.i("Disconnected and Call End!");
                  endCall(isForced: true);
                }
              });
            }
            break;
          //   case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          //     //The ICE agent has finished gathering candidates, has checked all pairs against one another, and has found a connection for all components.
          //     break;
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
            callingStatus.add(CallStatus.CONNECTED);
            if (_reconnectTry) {
              _reconnectTry = false;
              timerDisconnected?.cancel();
            } else if (_isCaller) {
              timerResendAnswer!.cancel();
            }
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            if (!_reconnectTry) {
              callingStatus.add(CallStatus.DISCONNECTED);
            }
            break;
          case RTCIceConnectionState.RTCIceConnectionStateNew:
            // TODO: Handle this case.
            break;
          case RTCIceConnectionState.RTCIceConnectionStateChecking:
            // TODO: Handle this case.
            break;
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            // TODO: Handle this case.
            break;
          case RTCIceConnectionState.RTCIceConnectionStateCount:
            // TODO: Handle this case.
            break;
          case RTCIceConnectionState.RTCIceConnectionStateClosed:
            // TODO: Handle this case.
            break;
        }
      }

      //https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/connectionState
      ..onConnectionState = (state) async {
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
            if (!_reconnectTry) {
              callingStatus.add(CallStatus.DISCONNECTED);
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            //Try reconnect
            if (!_reconnectTry) {
              _reconnectTry = true;
              callingStatus.add(CallStatus.RECONNECTING);
              _reconnectingAfterFailedConnection();
              timerDisconnected = Timer(const Duration(seconds: 15), () {
                if (callingStatus.value == CallStatus.RECONNECTING) {
                  callingStatus.add(CallStatus.NO_ANSWER);
                  _logger.i("Disconnected and Call End!");
                  endCall(isForced: true);
                }
              });
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            // TODO: Handle this case.
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateNew:
            // TODO: Handle this case.
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
            // TODO: Handle this case.
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
        _dataChannel!.onMessage = (data) async {
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
                _reconnectTry = false;
              }
              break;
            case STATUS_CONNECTION_CONNECTING:
              callingStatus.add(CallStatus.CONNECTING);
              break;
            case STATUS_CONNECTION_ENDED:
              //received end from Calle
              //receivedEndCall(0);
              endCall();
              break;
          }
        };
      };

    return pc;
  }

  _reconnectingAfterFailedConnection() async {
    if (!_isCaller) {
      _logger.i("try Reconnecting ...!");
      _offerSdp = await _createOffer();
    }
  }

  Future<void> _startCallTimerAndChangeStatus() async {
    if (isAndroid) {
      await _initForegroundTask();
      await _startForegroundTask();
    }
    startCallTimer();
    if (_startCallTime == 0) {
      _startCallTime = DateTime.now().millisecondsSinceEpoch;
    }
    if (_isDCRecived) {
      _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTED));
    }
    _logger.i("Start Call " + _startCallTime.toString());
    callingStatus.add(CallStatus.CONNECTED);
    if (timerConnectionFailed != null) {
      timerConnectionFailed!.cancel();
    }
    _isConnected = true;
  }

  _createDataChannel() async {
    final dataChannelDict = RTCDataChannelInit()..maxRetransmits = 15;

    final dataChannel = await _peerConnection!
        .createDataChannel("stateTransfer", dataChannelDict);

    dataChannel.onMessage = (data) async {
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
          break;
      }
    };
    return dataChannel;
  }

  /*
  * get Access from User for Camera and Microphone
  * */
  _getUserMedia() async {
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

  _getUserDisplay() async {
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
      _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
    } else {
      final camVideoTrack = _localStream!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(camVideoTrack);
      onLocalStream?.call(_localStream!);
      _isSharing = false;
      _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_VIDEO));
    }
  }

  _initForegroundTask() async {
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

  void _incomingCall(Uid roomId) {
    _roomUid = roomId;
    callingStatus.add(CallStatus.CREATED);
    final endOfCallDuration = DateTime.now().millisecondsSinceEpoch;
    _messageRepo.sendCallMessage(
        CallEvent_CallStatus.IS_RINGING,
        _roomUid!,
        _callId,
        0,
        endOfCallDuration,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
  }

  Future<void> startCall(Uid roomId, {bool isVideo = false}) async {
    if (_callService.getUserCallState == UserCallState.NOCALL) {
      //can't call another ppl or received any call notification
      _callService
        ..setCallNotification = true
        ..setUserCallState = UserCallState.INUSERCALL;

      _isCaller = true;
      _isVideo = isVideo;
      _roomUid = roomId;
      await initCall();
      callingStatus.add(CallStatus.CREATED);
      //Set Timer 50 sec for end call
      timerDeclined = Timer(const Duration(seconds: 50), () {
        if (callingStatus.value == CallStatus.IS_RINGING ||
            callingStatus.value == CallStatus.CREATED) {
          callingStatus.add(CallStatus.NO_ANSWER);
          _logger.i("User Can't Answer!");
          endCall();
        }
      });
      _callIdGenerator();
      _sendStartCallEvent();
    } else {
      _logger.i("User on Call ... !");
    }
  }

  _sendStartCallEvent() {
    final endOfCallDuration = DateTime.now().millisecondsSinceEpoch;
    _messageRepo.sendCallMessageWithMemberOrCallOwnerPvp(
        CallEvent_CallStatus.CREATED,
        _roomUid!,
        _callId,
        0,
        endOfCallDuration,
        _authRepo.currentUserUid,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
    //Set Timer 10 sec for resend Call Created Event if user offline
    timerResendCreate = Timer(const Duration(seconds: 10), () {
      if (callingStatus.value == CallStatus.CREATED) {
        _sendStartCallEvent();
      }
    });
  }

  _callIdGenerator() {
    final random = randomAlphaNumeric(10);
    final time = DateTime.now().millisecondsSinceEpoch;
    //call event id: (Epoch time milliseconds)-(Random String with alphabet and numerics with 10 characters length)
    final callId = time.toString() + "-" + random;
    _callId = callId;
  }

  Future<void> acceptCall(Uid roomId) async {
    _roomUid = roomId;
    callingStatus.add(CallStatus.ACCEPTED);
    _dataChannel = await _createDataChannel();
    _offerSdp = await _createOffer();
    callingStatus.add(CallStatus.CONNECTING);

    //after accept Call w8 for 30 sec if don't connecting force end Call
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.NO_ANSWER);
        endCall(isForced: true);
      }
    });
  }

  Future<void> declineCall() async {
    _logger.i("declineCall");
    callingStatus.add(CallStatus.DECLINED);
    final endOfCallDuration = DateTime.now().millisecondsSinceEpoch;
    _messageRepo.sendCallMessage(
        CallEvent_CallStatus.DECLINED,
        _roomUid!,
        _callId,
        0,
        endOfCallDuration,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
    await _dispose();
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
    }
    //And Create Answer for Calle
    if (!_reconnectTry) {
      _answerSdp = await _createAnswer();
    }
  }

  _setCallCandidate(String candidatesJson) async {
    final candidates = (jsonDecode(candidatesJson) as List)
        .map((data) => RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMlineIndex']))
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

  Future<void> receivedEndCall(int callDuration,
      {bool isForced = false}) async {
    _logger.i("Call Duration Received: " + callDuration.toString());
    final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
    ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
    if (isWindows) {
      _notificationServices.cancelRoomNotifications(roomUid!.node);
    }
    if (isForced || (_isCaller && callDuration == 0)) {
      _callDuration = calculateCallEndTime();
      _logger.i("Call Duration on Caller(1): " + _callDuration.toString());
      final endOfCallDuration = DateTime.now().millisecondsSinceEpoch;
      if (callingStatus.value == CallStatus.NO_ANSWER && !_isConnected) {
        // it means call Not Answered
        _callDuration = -1;
      }
      if (isForced) {
        _logger.i("Call Force Ending ...");
        _messageRepo.sendCallMessageWithMemberOrCallOwnerPvp(
            CallEvent_CallStatus.ENDED,
            _roomUid!,
            _callId,
            _callDuration!,
            endOfCallDuration,
            _callOwner!,
            _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
      } else {
        _messageRepo.sendCallMessage(
            CallEvent_CallStatus.ENDED,
            _roomUid!,
            _callId,
            _callDuration!,
            endOfCallDuration,
            _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
      }
    } else {
      _callDuration = callDuration;
    }
    await _dispose();
  }

  Future<void> endCall({bool isForced = false}) async {
    if (_callService.getUserCallState != CallStatus.NO_CALL) {
      if (isForced || _isCaller) {
        receivedEndCall(0, isForced: isForced);
      } else {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_ENDED));
      }
    }
  }

  int calculateCallEndTime() {
    var time = 0;
    if (_startCallTime != null && _isConnected) {
      _endCallTime = DateTime.now().millisecondsSinceEpoch;
      time = _endCallTime! - _startCallTime!;
    }
    return time;
  }

  _setRemoteDescriptionOffer(String remoteSdp) async {
    final dynamic session = await jsonDecode(remoteSdp);

    final sdp = write(session, null);

    final description = RTCSessionDescription(sdp, 'offer');

    await _peerConnection!.setRemoteDescription(description);
  }

  _setRemoteDescriptionAnswer(String remoteSdp) async {
    final dynamic session = await jsonDecode(remoteSdp);

    final sdp = write(session, null);

    final description = RTCSessionDescription(sdp, 'answer');

    await _peerConnection!.setRemoteDescription(description);
  }

  _createAnswer() async {
    final description = await _peerConnection!.createAnswer(_sdpConstraints);

    final session = parse(description.sdp.toString());
    final answerSdp = json.encode(session);
    _logger.i("Answer: \n" + answerSdp);

    _peerConnection!.setLocalDescription(description);

    return answerSdp;
  }

  _createOffer() async {
    final description = await _peerConnection!.createOffer(_sdpConstraints);
    //get SDP as String
    final session = parse(description.sdp.toString());
    final offerSdp = json.encode(session);
    _logger.i("Offer: \n" + offerSdp);
    _peerConnection!.setLocalDescription(description);
    return offerSdp;
  }

  Future<void> _waitUntilCandidateConditionDone() async {
    final completer = Completer();
    _logger.i("Time for w8:" +
        (DateTime.now().millisecondsSinceEpoch - _candidateStartTime)
            .toString());
    if ((_candidate.length >= _candidateNumber) ||
        (DateTime.now().millisecondsSinceEpoch - _candidateStartTime >
            _candidateTimeLimit)) {
      completer.complete();
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
      return _waitUntilCandidateConditionDone();
    }
    return completer.future;
  }

  _calculateCandidateAndSendOffer() async {
    _candidateStartTime = DateTime.now().millisecondsSinceEpoch;
    //w8 till candidate gathering conditions complete
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :" + _candidate.length.toString());
    // Send Candidate to Receiver
    final jsonCandidates = jsonEncode(_candidate);
    //Send offer and Candidate as message to Receiver
    final callOfferByClient = (CallOfferByClient()
      ..id = _callId
      ..body = _offerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallOffer(callOfferByClient);
    timerResendOffer = Timer(const Duration(seconds: 8), () {
      _coreServices.sendCallOffer(callOfferByClient);
    });
  }

  _calculateCandidateAndSendAnswer() async {
    _candidateStartTime = DateTime.now().millisecondsSinceEpoch;
    //w8 till candidate gathering conditions complete
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :" + _candidate.length.toString());
    // Send Candidate back to Sender
    final jsonCandidates = jsonEncode(_candidate);
    //Send Answer and Candidate as message to Sender
    final callAnswerByClient = (CallAnswerByClient()
      ..id = _callId
      ..body = _answerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallAnswer(callAnswerByClient);
    if (_reconnectTry) {
      callingStatus.add(CallStatus.IN_CALL);
    }
    timerResendAnswer = Timer(const Duration(seconds: 8), () {
      _coreServices.sendCallAnswer(callAnswerByClient);
    });
    //Set Timer 30 sec for end call if Call doesn't Connected
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.NO_ANSWER);
        endCall();
      }
    });
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    for (final candidate in candidates) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

  //Windows memory leak Warning!! https://github.com/flutter-webrtc/flutter-webrtc/issues/752
  _dispose() async {
    if (isAndroid) {
      _receivePort?.close();
      await _stopForegroundTask();
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
    Timer(const Duration(seconds: 1), () async {
      await fetchUserCallList(
          _authRepo.currentUserUid, DateTime.now().month, DateTime.now().year);
      callingStatus.add(CallStatus.NO_CALL);
    });
    switching.add(false);
    _offerSdp = "";
    _answerSdp = "";
    _callId = "";
    _roomUid = null;
    _isSharing = false;
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
      _callService
        ..setUserCallState = UserCallState.NOCALL
        ..setCallNotification = false;
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
      callTimer.add(CallTimer(callTimer.value.seconds, callTimer.value.minutes,
          callTimer.value.hours));
    });
  }

  _cleanLocalStream() async {
    await _stopSharingStream();
    if (_localStream != null) {
      _localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
  }

  _stopSharingStream() async {
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
    int month,
    int year,
  ) async {
    try {
      final callLists =
          await _queryServiceClient.fetchUserCalls(FetchUserCallsReq()
            ..roomUid = roomUid
            ..limit = 200
            ..pointer = Int64(DateTime.now().millisecondsSinceEpoch)
            ..fetchingDirectionType =
                FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH
            ..month = month - 1
            ..year = year);
      for (final call in callLists.cellEvents) {
        final callEvent = call_event.CallEvent(
            callDuration: call.callEvent.callDuration.toInt(),
            endOfCallTime: call.callEvent.endOfCallTime.toInt(),
            callType: findCallEventType(call.callEvent.callType),
            newStatus: findCallEventStatus(call.callEvent.newStatus),
            id: call.callEvent.id);
        final callList = call_info.CallInfo(
            callEvent: callEvent,
            from: call.from.asString(),
            to: call.to.asString());
        await _callListDao.save(callList);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  call_status.CallStatus findCallEventStatus(
      CallEvent_CallStatus eventCallStatus) {
    switch (eventCallStatus) {
      case CallEvent_CallStatus.CREATED:
        return call_status.CallStatus.CREATED;
      case CallEvent_CallStatus.BUSY:
        return call_status.CallStatus.BUSY;
      case CallEvent_CallStatus.DECLINED:
        return call_status.CallStatus.DECLINED;
      case CallEvent_CallStatus.ENDED:
        return call_status.CallStatus.ENDED;
      case CallEvent_CallStatus.INVITE:
        return call_status.CallStatus.INVITE;
      case CallEvent_CallStatus.IS_RINGING:
        return call_status.CallStatus.IS_RINGING;
      case CallEvent_CallStatus.JOINED:
        return call_status.CallStatus.JOINED;
      case CallEvent_CallStatus.KICK:
        return call_status.CallStatus.KICK;
      case CallEvent_CallStatus.LEFT:
        return call_status.CallStatus.LEFT;
    }
    return call_status.CallStatus.ENDED;
  }

  CallType findCallEventType(CallEvent_CallType eventCallType) {
    switch (eventCallType) {
      case CallEvent_CallType.VIDEO:
        return CallType.VIDEO;
      case CallEvent_CallType.AUDIO:
        return CallType.AUDIO;
      case CallEvent_CallType.GROUP_AUDIO:
        return CallType.GROUP_AUDIO;
      case CallEvent_CallType.GROUP_VIDEO:
        return CallType.GROUP_VIDEO;
    }
    return CallType.AUDIO;
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
  Future<void> onDestroy(DateTime timestamp) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    if (id == "endCall") {
      sPort?.send("endCall");
    }
  }
}
