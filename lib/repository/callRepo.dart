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
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:wakelock/wakelock.dart';

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
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  final _logger = GetIt.I.get<Logger>();

  final _coreServices = GetIt.I.get<CoreServices>();
  final _callService = GetIt.I.get<CallService>();
  final _notificationForegroundService =
      GetIt.I.get<NotificationForegroundService>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

  final _callListDao = GetIt.I.get<CallInfoDao>();
  final _sharedDao = GetIt.I.get<SharedDao>();

  final _featureFlags = GetIt.I.get<FeatureFlags>();

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

  Map<int, String> _callEvents = {};
  StatsReport _selectedCandidate = StatsReport("id", "type", 0, {});

  bool _isSharing = false;
  bool _isCaller = false;
  bool _isVideo = false;
  bool _isConnected = false;
  bool _isMicMuted = false;
  bool _isDCReceived = false;
  bool _reconnectTry = false;
  bool _isEnded = false;
  bool _isEndedReceived = false;
  bool _isOfferReady = false;
  bool _isCallInitiated = false;
  bool _isCallFromDb = false;
  bool _isInitRenderer = false;
  bool _isAudioToggleOnCall = false;
  Uid? _roomUid;

  bool get isCaller => _isCaller;

  bool get isConnected => _isConnected;

  Uid? get roomUid => _roomUid;

  bool get isSharing => _isSharing;

  bool get isVideo => _isVideo;

  bool get isInitRenderer => _isInitRenderer;

  set setRenderer(bool isInit) => _isInitRenderer = isInit;

  StatsReport get selectedCandidate => _selectedCandidate;

  Map<int, String> get callEvents => _callEvents;

  List<MediaStreamTrack> get audioTracks => _localStream!.getAudioTracks();

  set selectAudioTrackById(String trackId) {
    final track = _localStream?.getTrackById(trackId);
    _audioSender!.replaceTrack(track);
  }

  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onAddRemoteStream;
  Function(MediaStream stream)? onRemoveRemoteStream;

  int? _startCallTime = 0;
  int? _callDuration = 0;
  int? _endCallTime = 0;
  int _shareDelay = 1;

  int? get callDuration => _callDuration;
  Timer? timerDeclined;
  Timer? timerResendOffer;
  Timer? timerResendAnswer;
  Timer? timerConnectionFailed;
  Timer? timerDisconnected;
  Timer? timerEndCallDispose;
  Timer? videoMotivation;
  BehaviorSubject<CallTimer> callTimer =
      BehaviorSubject.seeded(CallTimer(0, 0, 0));
  bool _isNotificationSelected = false;
  bool isAccepted = false;
  Timer? timer;
  StreamSubscription<PhoneStateStatus?>? _phoneStateStream;

  ReceivePort? _receivePort;

  CallRepo() {
    _callService.watchCurrentCall().listen((call) {
      if (call != null && !isDesktop) {
        if (call.expireTime > clock.now().millisecondsSinceEpoch &&
            _callService.getUserCallState == UserCallState.NO_CALL) {
          _isNotificationSelected = call.notificationSelected;
          isAccepted = call.isAccepted;
          _logger.i(
            "read call from DB notificationSelected : ${call.notificationSelected}",
          );
          _callService.callEvents.add(
            CallEvents.callEvent(
              call_pb.CallEvent()
                ..callStatus = _callService
                    .findCallEventStatusDB(call.callEvent.callStatus)
                ..callId = call.callEvent.id
                ..callDuration = Int64(call.callEvent.callDuration)
                ..callType = _callService
                    .findProtoCallEventType(call.callEvent.callType),
              roomUid: call.from.asUid(),
              callId: call.callEvent.id,
              time: call.expireTime - 60000,
            ),
          );
          _isCallFromDb = true;
        }
      }
    });
    _callService.callEvents.listen((event) {
      if (event.roomUid == null) {
        return;
      }
      if (_callService.checkIncomingCallIsRepeated(
        event.callId,
        event.roomUid!.asString(),
      )) {
        return;
      }
      final from = event.roomUid!.asString();
      final to = _authRepo.currentUserUid.asString();
      switch (event.callType) {
        case CallTypes.Answer:
          if (from == to || !isAccepted) {
            _dispose();
          } else {
            timerResendOffer!.cancel();
            _receivedCallAnswer(event.callAnswer!);
            _callEvents[clock.now().millisecondsSinceEpoch] = "Received Answer";
          }
          break;
        case CallTypes.Offer:
          if (from == to) {
            _dispose();
          } else {
            _receivedCallOffer(event.callOffer!);
            _callEvents[clock.now().millisecondsSinceEpoch] = "Received Offer";
          }
          break;
        case CallTypes.Event:
          final callEvent = event.callEvent;
          switch (callEvent!.callStatus) {
            case CallEvent_CallStatus.IS_RINGING:
              if (from != to) {
                _callEvents[event.time] = "IsRinging";
                if (_callService.getCallId == callEvent.callId) {
                  callingStatus.add(CallStatus.IS_RINGING);
                  if (_isCaller) {
                    try {
                      _audioService.playBeepSound();
                    } catch (e) {
                      _logger.e(e);
                    }
                  }
                }
              }
              break;
            case CallEvent_CallStatus.CREATED:
              _callEvents[event.time] = "Created";
              if (from == to) {
                _dispose();
              } else {
                if (_callService.getUserCallState == UserCallState.NO_CALL &&
                    checkCallExpireTimeValidation(event)) {
                  // final callStatus =
                  //     await FlutterForegroundTask.getData(key: "callStatus");
                  _roomUid = event.roomUid;
                  _callService
                    ..setUserCallState = UserCallState.IN_USER_CALL
                    ..setCallId = callEvent.callId;

                  if (callEvent.callType == CallEvent_CallType.VIDEO) {
                    _logger.i("VideoCall");
                    _isVideo = true;
                  } else {
                    _isVideo = false;
                  }

                  if (isAccepted) {
                    modifyRoutingByCallNotificationActionInBackgroundInAndroid
                        .add(
                      CallNotificationActionInBackground(
                        roomId: event.roomUid!.asString(),
                        isCallAccepted: true,
                        isVideo: _isVideo,
                      ),
                    );
                  } else {
                    if (!isDesktop && !_isCallFromDb) {
                      //get call Info and Save on DB
                      final currentCallEvent = call_event.CallEvent(
                        callDuration: callEvent.callDuration.toInt(),
                        callType: _callService.findCallEventType(
                          callEvent.callType,
                        ),
                        callStatus: _callService
                            .findCallEventStatusProto(callEvent.callStatus),
                        id: callEvent.callId,
                      );
                      final callInfo = current_call_info.CurrentCallInfo(
                        callEvent: currentCallEvent,
                        from: from,
                        to: to,
                        expireTime: event.time + 60000,
                        notificationSelected: _isNotificationSelected,
                        isAccepted: isAccepted,
                      );

                      _callService.saveCallOnDb(callInfo);
                      _logger.i("save call on db!");
                    }

                    _incomingCall(
                      event.roomUid!,
                      false,
                      _callService.writeCallEventsToJson(event),
                    );
                  }
                } else if (callEvent.callId != _callService.getCallId &&
                    checkCallExpireTimeValidation(event)) {
                  _busyCall(event, callEvent);
                }
              }
              break;
            case CallEvent_CallStatus.BUSY:
              _callEvents[event.time] = "Busy";
              if (_callService.getCallId == callEvent.callId &&
                  checkCallExpireTimeValidation(event)) {
                receivedBusyCall();
              }
              break;
            case CallEvent_CallStatus.DECLINED:
              _callEvents[event.time] = "Declined";
              if (_callService.getCallId == callEvent.callId &&
                  checkCallExpireTimeValidation(event)) {
                receivedDeclinedCall();
              }
              break;
            case CallEvent_CallStatus.ENDED:
              _callEvents[event.time] = "Ended";
              if (_callService.getCallId == callEvent.callId &&
                  checkCallExpireTimeValidation(event)) {
                receivedEndCall(callEvent.callDuration.toInt());
              }
              break;
          }
          break;
        case CallTypes.None:
          break;
      }
    });
  }

  void _busyCall(CallEvents event, call_pb.CallEvent callEvent) {
    final callData =
        CallData(event.callId, event.roomUid!.asString(), event.time + 100000);
    _callService.saveLastCallStatusOnSharedPrefCallSlot(callData);
    _messageRepo.sendCallMessage(
      CallEvent_CallStatus.BUSY,
      event.roomUid!,
      callEvent.callId,
      0,
      _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
    );
  }

  bool checkCallExpireTimeValidation(CallEvents event) {
    return ((event.time - clock.now().millisecondsSinceEpoch).abs()) < 60000;
  }

/*
  * initial Variable for Render Call Between 2 Client
  * */
  Future<void> initCall({bool isOffer = false}) async {
    await _createPeerConnection(isOffer).then((pc) {
      _peerConnection = pc;
    });

    if (isAndroid && await requestPhoneStatePermission()) {
      startListenToPhoneCallState();
    }

    if (isOffer) {
      _dataChannel = await _createDataChannel();
      _offerSdp = await _createOffer();
    }
  }

  Future<bool> requestPhoneStatePermission() async {
    final status = await Permission.phone.request();

    switch (status) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        return false;
      case PermissionStatus.granted:
        return true;
    }
  }

  void startListenToPhoneCallState() {
    _phoneStateStream = PhoneState.phoneStateStream.listen((event) {
      if (event != null) {
        if (event == PhoneStateStatus.CALL_STARTED) {
          _analyticsService.sendLogEvent(
            "callOnHold",
          );
          _logger.i("PhoneState.phoneStateStream=CALL_STARTED");
          if (_isConnected) {
            _dataChannel!.send(RTCDataChannelMessage(STATUS_CALL_ON_HOLD));
          }
        } else if (event == PhoneStateStatus.CALL_ENDED) {
          _logger.i("PhoneState.phoneStateStream=CALL_ENDED");
          if (_isConnected) {
            _dataChannel!
                .send(RTCDataChannelMessage(STATUS_CALL_ON_HOLD_ENDED));
          }
        }
      }
    });
  }

  Future<RTCPeerConnection> _createPeerConnection(bool isOffer) async {
    final stunLocal = await _sharedDao.getBoolean(
      "stun:217.218.7.16:3478",
      defaultValue: true,
    );
    final turnLocal = await _sharedDao
        .getBoolean("turn:217.218.7.16:3478?transport=udp", defaultValue: true);
    final stunGoogle =
        await _sharedDao.getBoolean("stun:stun.l.google.com:19302");
    final turnGoogle =
        await _sharedDao.getBoolean("turn:47.102.201.4:19303?transport=udp");

    final iceServers = <String, dynamic>{
      'iceServers': [
        if (stunLocal) {'url': STUN_SERVER_URL},
        if (turnLocal)
          {
            'url': TURN_SERVER_URL,
            'username': TURN_SERVER_USERNAME,
            'credential': TURN_SERVER_PASSWORD,
          },
        if (stunGoogle) {'url': STUN_SERVER_URL_2},
        if (turnGoogle)
          {
            'url': TURN_SERVER_URL_2,
            'username': TURN_SERVER_USERNAME_2,
            'credential': TURN_SERVER_PASSWORD_2,
          },
      ]
    };

    final config = <String, dynamic>{
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

    if (isVideo) {
      _localStream!.getVideoTracks()[0].enabled = false;
    }

    final pc = await createPeerConnection(iceServers, config);

    final camAudioTrack = _localStream!.getAudioTracks()[0];
    if (!isDesktop) {
      _audioService.turnDownTheCallVolume();
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
            onRTCPeerConnectionStateFailed();
            break;
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
            onRTCPeerConnectionConnected();
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
            onRTCPeerConnectionDisconnected();
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
            onRTCPeerConnectionConnected();
            if (!isWeb) {
              _startCallTimerAndChangeStatus();
            }
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            onRTCPeerConnectionDisconnected();
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            //Try reconnect
            onRTCPeerConnectionStateFailed();
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
            _calculateCandidate();
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
        _logger.i('addStream: ${stream.id}');
        onAddRemoteStream?.call(stream);
      }
      ..onRemoveStream = (stream) {
        onRemoveRemoteStream?.call(stream);
      }
      ..onDataChannel = (channel) {
        _logger.i("data Channel Received!!");
        _dataChannel = channel;
        //it means Connection is Connected
        _startCallTimerAndChangeStatus();
        _dataChannel!.onMessage = (data) {
          final status = data.text;
          _logger.i(status);
          // we need Decision making by state
          switch (status) {
            case STATUS_CAMERA_OPEN:
              incomingVideo.add(true);
              break;
            case STATUS_CAMERA_CLOSE:
              incomingVideo.add(false);
              break;
            case STATUS_CAMERA_SWITCH_ON:
              incomingVideoSwitch.add(true);
              break;
            case STATUS_CAMERA_SWITCH_OFF:
              incomingVideoSwitch.add(false);
              break;
            case STATUS_MIC_OPEN:
              break;
            case STATUS_MIC_CLOSE:
              break;
            case STATUS_SHARE_SCREEN:
              _analyticsService.sendLogEvent(
                "shareScreenOnVideoCall",
              );
              incomingSharing.add(true);
              break;
            case STATUS_CALL_ON_HOLD:
              incomingCallOnHold.add(true);
              break;
            case STATUS_CALL_ON_HOLD_ENDED:
              incomingCallOnHold.add(false);
              break;
            case STATUS_SHARE_VIDEO:
              incomingSharing.add(false);
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
                _reconnectTry = false;
              }
              break;
            case STATUS_CONNECTION_CONNECTING:
              callingStatus.add(CallStatus.CONNECTING);
              break;
            case STATUS_CONNECTION_ENDED:
              //received end from Callee
              receivedEndCall(0);
              break;
          }
        };
        _isDCReceived = true;
      };

    return pc;
  }

  void onRTCPeerConnectionDisconnected() {
    Timer(const Duration(seconds: 1), () {
      if (!_reconnectTry && !_isEnded && !_isEndedReceived) {
        if (_peerConnection!.connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          _reconnectTry = true;
          _reconnectingAfterFailedConnection();
          callingStatus.add(CallStatus.DISCONNECTED);
          timerDisconnected = Timer(const Duration(seconds: 12), () {
            if (callingStatus.value != CallStatus.CONNECTED) {
              _logger.i("Disconnected and Call End!");
              if (_isCaller) {
                endCall();
              } else {
                _dispose();
              }
            }
          });
        }
        try {} catch (e) {
          _logger.e(e);
        }
      }
    });
  }

  Future<void> onRTCPeerConnectionConnected() async {
    final stats = await _peerConnection!.getStats();
    var selectedCandidateId = "";
    for (final stat in stats) {
      if (stat.type == "candidate-pair" &&
          stat.values["state"] == "succeeded") {
        selectedCandidateId = stat.values["localCandidateId"];
      }
    }
    for (final stat in stats) {
      if (stat.id == selectedCandidateId) {
        _selectedCandidate = stat;
      }
    }
    await _analyticsService.sendLogEvent(
      "connectedCall",
    );
    callingStatus.add(CallStatus.CONNECTED);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Connected";
    await vibrate(duration: 50);

    if (_isVideo) {
      if (isAndroid) {
        await Wakelock.enable();
        _localStream!.getAudioTracks()[0].enableSpeakerphone(true);
        isSpeaker.add(true);
      }
    } else if (isAndroid) {
      _localStream!.getAudioTracks()[0].enableSpeakerphone(isSpeaker.value);
    }

    if (_reconnectTry) {
      _reconnectTry = false;
      timerDisconnected?.cancel();
    } else if (_isCaller) {
      timerResendAnswer!.cancel();
    }
  }

  void onRTCPeerConnectionStateFailed() {
    _callEvents[clock.now().millisecondsSinceEpoch] = "Failed";
    isConnectedSubject.add(false);
    _isConnected = false;
    if (!_reconnectTry && !_isEnded && !_isEndedReceived && !isConnected) {
      _reconnectTry = true;
      callingStatus.add(CallStatus.RECONNECTING);
      _reconnectingAfterFailedConnection();
      timerDisconnected = Timer(const Duration(seconds: 15), () async {
        if (callingStatus.value != CallStatus.CONNECTED) {
          callingStatus.add(CallStatus.FAILED);
          _logger.i("Disconnected and Call End!");
          await _analyticsService.sendLogEvent(
            "settingsPage_open",
          );
          endCall();
        }
      });
    }
  }

  Future<void> _reconnectingAfterFailedConnection() async {
    _callEvents[clock.now().millisecondsSinceEpoch] = "ReConnecting";
    if (!_isCaller) {
      callingStatus.add(CallStatus.RECONNECTING);
      _logger.i("try Reconnecting ...!");
      _offerSdp = await _createOffer();
    }
  }

  Future<void> _startCallTimerAndChangeStatus() async {
    startCallTimer();
    if (_startCallTime == 0) {
      _startCallTime = clock.now().millisecondsSinceEpoch;
    }
    if (_isDCReceived &&
        _dataChannel?.state == RTCDataChannelState.RTCDataChannelConnecting) {
      await _dataChannel!
          .send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTED));
    }
    _logger.i("Start Call $_startCallTime");
    callingStatus.add(CallStatus.CONNECTED);
    vibrate(duration: 50).ignore();
    if (timerConnectionFailed != null) {
      timerConnectionFailed!.cancel();
    }
    _isConnected = true;
    isConnectedSubject.add(true);
    await _ShareCameraStatusFromDataChannel();
    if (!isDesktop) {
      _localStream!.getAudioTracks()[0].enableSpeakerphone(false);
    }
  }

  Future<void> _ShareCameraStatusFromDataChannel() async {
    Timer(Duration(seconds: 1 * _shareDelay), () async {
      if (_isDCReceived) {
        if (sharing.value) {
          await _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
        } else if (videoing.value) {
          await _dataChannel!.send(RTCDataChannelMessage(STATUS_CAMERA_OPEN));
        }
        if (switching.value) {
          await _dataChannel!
              .send(RTCDataChannelMessage(STATUS_CAMERA_SWITCH_ON));
        }
      } else {
        _shareDelay = _shareDelay * 2;
        await _ShareCameraStatusFromDataChannel();
      }
    });
  }

  Future<RTCDataChannel> _createDataChannel() async {
    final dataChannelDict = RTCDataChannelInit()..maxRetransmits = 15;

    final dataChannel = await _peerConnection!
        .createDataChannel("stateTransfer", dataChannelDict);
    _isDCReceived = true;
    dataChannel.onMessage = (data) {
      final status = data.text;
      _logger.i(status);
      // we need Decision making by state
      switch (status) {
        case STATUS_CAMERA_OPEN:
          incomingVideo.add(true);
          break;
        case STATUS_CAMERA_CLOSE:
          incomingVideo.add(false);
          break;
        case STATUS_CAMERA_SWITCH_ON:
          incomingVideoSwitch.add(true);
          break;
        case STATUS_CAMERA_SWITCH_OFF:
          incomingVideoSwitch.add(false);
          break;
        case STATUS_MIC_OPEN:
          break;
        case STATUS_MIC_CLOSE:
          break;
        case STATUS_CALL_ON_HOLD:
          incomingCallOnHold.add(true);
          break;
        case STATUS_CALL_ON_HOLD_ENDED:
          incomingCallOnHold.add(false);
          break;
        case STATUS_SHARE_SCREEN:
          _analyticsService.sendLogEvent(
            "shareScreenOnVideoCall",
          );
          incomingSharing.add(true);
          break;
        case STATUS_SHARE_VIDEO:
          incomingSharing.add(false);
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
        case STATUS_CONNECTION_ENDED:
          // this case use for prevent from disconnected state
          _isEndedReceived = true;
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
    if (isDesktop) {
      mediaConstraints = {
        'video': _isVideo
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'maxWidth': '1024',
                  'minHeight': '480',
                  'maxHeight': '768',
                  'minFrameRate': '20',
                  'maxFrameRate': '30',
                  'aspectRatio:': ' 1.777777778',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
        'audio': {
          'sampleSize': '16',
          'channelCount': '2',
          'echoCancellation': 'true',
        }
      };
    } else {
      mediaConstraints = {
        'video': _isVideo
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'maxWidth': '1024',
                  'minHeight': '480',
                  'maxHeight': '768',
                  'minFrameRate': '20',
                  'maxFrameRate': '30',
                  'aspectRatio:': ' 1.777777778',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
        'audio': {
          'sampleSize': '16',
          'channelCount': '2',
          'echoCancellation': 'true',
          'latency': '0',
          'noiseSuppression': 'ture',
        }
      };
    }

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  Future<MediaStream> _getUserDisplay(DesktopCapturerSource? source) async {
    if (isDesktop) {
      final stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': source == null
            ? true
            : {
                'deviceId': {'exact': source.id},
                'mandatory': {'frameRate': 30.0}
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        _logger.i(
          'By adding a listener on onEnded you can: 1) catch stop video sharing on Web',
        );
      };

      return stream;
    } else {
      final mediaConstraints = <String, dynamic>{'audio': false, 'video': true};
      final stream =
          await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      return stream;
    }
  }

//https://github.com/flutter-webrtc/flutter-webrtc/issues/831 issue for Android
//https://github.com/flutter-webrtc/flutter-webrtc/issues/799 issue for Windows
  Future<void> shareScreen({
    DesktopCapturerSource? source,
  }) async {
    if (!_isSharing) {
      //before sharing if camera on make it off
      if (videoing.value) {
        muteCamera();
      }

      _localStreamShare = await _getUserDisplay(source);
      final screenVideoTrack = _localStreamShare!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(screenVideoTrack);
      onLocalStream?.call(_localStreamShare!);
      _isSharing = true;
      sharing.add(true);
      if (_isDCReceived) {
        return _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
      }
    } else {
      final camVideoTrack = _localStream!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(camVideoTrack);
      onLocalStream?.call(_localStream!);
      _isSharing = false;
      sharing.add(false);
      if (_isDCReceived) {
        return _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_VIDEO));
      }
    }
  }

// Future<void> _foregroundTaskInitializing() async {
//   if (isAndroid) {
//     await _initForegroundTask();
//     await _startForegroundTask();
//   }
// }
//
//
// Future<void> _initForegroundTask() async {
//   await FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'notification_channel_id',
//       channelName: 'Foreground Notification',
//       channelDescription:
//       'This notification appears when the foreground service is running.',
//       channelImportance: NotificationChannelImportance.HIGH,
//       priority: NotificationPriority.HIGH,
//       isSticky: false,
//       iconData: const NotificationIconData(
//         resType: ResourceType.mipmap,
//         resPrefix: ResourcePrefix.ic,
//         name: 'launcher',
//       ),
//       buttons: [
//         const NotificationButton(id: 'endCall', text: 'End Call'),
//       ],
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(),
//     foregroundTaskOptions: const ForegroundTaskOptions(
//       autoRunOnBoot: true,
//       allowWifiLock: true,
//     ),
//     printDevLog: true,
//   );
// }
//
// Future<bool> _startForegroundTask() async {
//   ReceivePort? receivePort;
//   if (await FlutterForegroundTask.isRunningService) {
//     receivePort = await FlutterForegroundTask.restartService();
//   } else {
//     receivePort = await FlutterForegroundTask.startService(
//       notificationTitle: '$APPLICATION_NAME Call on BackGround',
//       notificationText: 'Tap to return to the app',
//       callback: startCallback,
//     );
//   }
//
//   if (receivePort != null) {
//     _receivePort = receivePort;
//     _receivePort?.listen((message) {
//       if (message == "endCall") {
//         endCall();
//       } else if (message == 'onNotificationPressed') {
//         _routingService.openCallScreen(roomUid!);
//       } else {
//         _logger.i('receive callStatus: $message');
//       }
//     });
//     return true;
//   }
//
//   return false;
// }
//
// Future<bool> _stopForegroundTask() async =>
//     FlutterForegroundTask.stopService();

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

  /*
  * For Close Microphone
  * */
  bool enableMicrophone() {
    if (_localStream != null) {
      const enabled = true;
      if (_isConnected) {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_OPEN));
      }
      _localStream!.getAudioTracks()[0].enabled = enabled;
      _isMicMuted = false;
      return enabled;
    }
    return false;
  }

  bool enableSpeakerVoice() {
    if (_localStream != null && !isDesktop) {
      final camAudioTrack = _localStream!.getAudioTracks()[0];
      final speaker = isSpeaker.value;
      if (speaker) {
        if (_isConnected) {
          camAudioTrack.enableSpeakerphone(false);
        } else {
          _audioService.turnDownTheCallVolume();
        }
      } else {
        if (_isConnected) {
          camAudioTrack.enableSpeakerphone(true);
        } else {
          _audioService.turnUpTheCallVolume();
        }
      }
      isSpeaker.add(!speaker);
      return !speaker;
    }
    return false;
  }

  Future<bool> switchCamera() async {
    if (_localStream != null) {
      final isCameraSwitched =
          await Helper.switchCamera(_localStream!.getVideoTracks()[0]);
      switching.add(!isCameraSwitched);
      if (_isConnected) {
        if (!isCameraSwitched) {
          await _dataChannel!
              .send(RTCDataChannelMessage(STATUS_CAMERA_SWITCH_ON));
        } else {
          await _dataChannel!
              .send(RTCDataChannelMessage(STATUS_CAMERA_SWITCH_OFF));
        }
      }
      return isCameraSwitched;
    }
    return false;
  }

  bool toggleDesktopDualVideo() {
    final dualVideo = desktopDualVideo.value;
    desktopDualVideo.add(!dualVideo);
    return !dualVideo;
  }

/*
  * For Close Camera
  * */
  bool muteCamera() {
    if (_localStream != null) {
      if (sharing.value) {
        shareScreen();
      } else {
        final enabled = _localStream!.getVideoTracks()[0].enabled;
        videoing.add(!enabled);
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
    }
    return false;
  }

  Future<void> _incomingCall(
    Uid roomId,
    bool isDuplicated,
    String callEventJson,
  ) async {
    _audioToggleOnCall();
    if (_isNotificationSelected) {
      modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(
        CallNotificationActionInBackground(
          roomId: roomId.asString(),
          isCallAccepted: false,
          isVideo: _isVideo,
        ),
      );
    } else if (!isDuplicated) {
      if (_routingService.getCurrentRoomId() == roomId.asString()) {
        modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(
          CallNotificationActionInBackground(
            roomId: roomId.asString(),
            isCallAccepted: false,
            isVideo: _isVideo,
          ),
        );
      } else {
        await _notificationServices.notifyIncomingCall(
          roomId.asString(),
          callEventJson: callEventJson,
        );
        if (!isAndroid) {
          _audioService.playIncomingCallSound();
        }
      }
    }
    _roomUid = roomId;
    _logger.i(
      "incoming Call and Created!!! "
      "(isDuplicated:) $isDuplicated , (notificationSelected) : $_isNotificationSelected",
    );
    callingStatus.add(CallStatus.CREATED);
    await _callService.initRenderer();
    unawaited(
      _messageRepo.sendCallMessage(
        CallEvent_CallStatus.IS_RINGING,
        roomId,
        _callService.getCallId,
        0,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
      ),
    );
    Timer(const Duration(milliseconds: 500), () async {
      if (isAndroid) {
        if (!_isVideo && await Permission.microphone.status.isGranted) {
          if (await getDeviceVersion() >= 31) {
            _isCallInitiated = true;
            await initCall(isOffer: true);
          }
        }
      } else if (!_isVideo) {
        _isCallInitiated = true;
        await initCall(isOffer: true);
      }
    });
  }

  Future<void> startCall(Uid roomId, {bool isVideo = false}) async {
    try {
      if (_callService.getUserCallState == UserCallState.NO_CALL) {
        if (isVideo) {
          await _analyticsService.sendLogEvent(
            "startVideoCall",
          );
        } else {
          await _analyticsService.sendLogEvent(
            "startAudioCall",
          );
        }
        //can't call another ppl or received any call notification
        _callService.setUserCallState = UserCallState.IN_USER_CALL;
        _isCaller = true;
        _isVideo = isVideo;
        _roomUid = roomId;
        _isCallInitiated = true;
        await initCall();

        // change location of this line from mediaStream get to this line for prevent
        // exception on callScreen and increase call speed .
        onLocalStream?.call(_localStream!);

        _logger.i("Start Call and Created !!!");
        callingStatus.add(CallStatus.CREATED);
        _callService.setCallStart(callStart: true);
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
        if (isAndroid) {
          final foregroundStatus =
              await _notificationForegroundService.callForegroundServiceStart();
          if (foregroundStatus) {
            _receivePort = _notificationForegroundService.getReceivePort;
            _receivePort?.listen((message) {
              if (message == "endCall") {
                endCall();
              } else if (message == 'onNotificationPressed') {
                _routingService.openCallScreen(roomUid!, isVideoCall: isVideo);
              } else {
                _logger.i('receive callStatus: $message');
              }
            });
          }
        }
        //this delay because we want show video animation to user
        videoMotivation = Timer(MOTION_STANDARD_ANIMATION_DURATION, () {
          if (isVideo) {
            muteCamera();
          }
        });
      } else {
        _logger.i("User on Call ... !");
      }
    } catch (e) {
      _logger.e(e);
      await _dispose();
    }
  }

  void _sendStartCallEvent() {
    _messageRepo.sendCallMessage(
      CallEvent_CallStatus.CREATED,
      _roomUid!,
      _callService.getCallId,
      0,
      _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
    );
  }

  void _callIdGenerator() {
    final random = randomAlphaNumeric(10);
    final time = clock.now().millisecondsSinceEpoch;
    //call event id: (Epoch time milliseconds)-(Random String with alphabet and numerics with 10 characters length)
    final callId = "$time-$random";
    _callService.setCallId = callId;
  }

  Future<void> acceptCall(Uid roomId) async {
    try {
      if (isAndroid) {
        cancelVibration().ignore();
      }
      isAccepted = true;
      if (isDesktop) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }

      if (_roomUid == null || roomId.node != _roomUid!.node) {
        endCall();
      }

      callingStatus.add(CallStatus.CONNECTING);

      try {
        _audioService.stopCallAudioPlayer();
      } catch (e) {
        _logger.e(e);
      }

      //after accept Call w8 for 30 sec if don't connecting force end Call
      timerConnectionFailed = Timer(const Duration(seconds: 30), () {
        if (callingStatus.value != CallStatus.CONNECTED && !_reconnectTry) {
          try {
            _logger.i("Call Can't Connected !!");
            callingStatus.add(CallStatus.NO_ANSWER);
            unawaited(_increaseCandidateAndWaitingTime());
          } catch (e) {
            _logger.e(e);
          }
          endCall();
        }
      });
      //if call come from backGround doesn't init and should be initialize
      if (!_isCallInitiated) {
        await initCall(isOffer: true);
      }
      // change location of this line from mediaStream get to this line for prevent
      // exception on callScreen and increase call speed .
      onLocalStream?.call(_localStream!);
      _callService.setCallStart(callStart: true);
      unawaited(_sendOffer());
      if (isAndroid) {
        final foregroundStatus =
            await _notificationForegroundService.callForegroundServiceStart();
        if (foregroundStatus) {
          _receivePort = _notificationForegroundService.getReceivePort;
          _receivePort?.listen((message) {
            if (message == "endCall") {
              endCall();
            } else if (message == 'onNotificationPressed') {
              _routingService.openCallScreen(roomUid!, isVideoCall: isVideo);
            } else {
              _logger.i('receive callStatus: $message');
            }
          });
        }
      }
    } catch (e) {
      _logger.e(e);
      await _dispose();
    }
  }

  Future<void> declineCall() async {
    if (_callService.getUserCallState == UserCallState.IN_USER_CALL) {
      if (isDesktop) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      _logger.i("declineCall");
      callingStatus.add(CallStatus.DECLINED);
      unawaited(
        _messageRepo.sendCallMessage(
          CallEvent_CallStatus.DECLINED,
          _roomUid!,
          _callService.getCallId,
          0,
          _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
        ),
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
      try {
        _audioService.stopCallAudioPlayer();
      } catch (e) {
        _logger.e(e);
      }
    }
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(callOffer.body);
    await _setCallCandidate(callOffer.candidates);
    //And Create Answer for Calle
    if (!_reconnectTry) {
      _answerSdp = await _createAnswer();
      callingStatus.add(CallStatus.CONNECTING);
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
      _logger.i("Call Duration Received: $callDuration");
      if (isDesktop) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      if (_isCaller) {
        _callDuration = calculateCallEndTime();
        _logger.i("Call Duration on Caller(1): $_callDuration");
        unawaited(
          _messageRepo.sendCallMessage(
            CallEvent_CallStatus.ENDED,
            _roomUid!,
            _callService.getCallId,
            _callDuration!,
            _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO,
          ),
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
      cancelVibration().ignore();
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
      await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    } else if (isDesktop) {
      _notificationServices.cancelRoomNotifications(roomUid!.node);
    }
  }

// TODO(AmirHossein): removed Force End Call and we need Handle it with third-party Service.
  void endCall() {
    if (callingStatus.value != CallStatus.ENDED ||
        callingStatus.value != CallStatus.NO_CALL) {
      try {
        if (isDesktop) {
          _notificationServices.cancelRoomNotifications(roomUid!.node);
        }
        if (_callService.getUserCallState != CallStatus.NO_CALL) {
          if (_isDCReceived) {
            _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_ENDED));
          }
          if (_isCaller) {
            receivedEndCall(0);
          }
        }
      } catch (e) {
        _logger.e(e);
      } finally {
        if (!_isCaller) {
          timerEndCallDispose = Timer(const Duration(seconds: 4), () {
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
    _logger.i("Answer: \n$answerSdp");

    unawaited(_peerConnection!.setLocalDescription(description));

    return answerSdp;
  }

  Future<String> _createOffer() async {
    final description = await _peerConnection!.createOffer(_sdpConstraints);
    //get SDP as String
    final session = parse(description.sdp.toString());
    final offerSdp = json.encode(session);
    _logger.i("Offer: \n$offerSdp");
    unawaited(_peerConnection!.setLocalDescription(description));
    return offerSdp;
  }

  Future<void> _waitUntilCandidateConditionDone() async {
    late final int candidateNumber;
    late final int candidateTimeLimit;
    try {
      candidateNumber = _reconnectTry
          ? 20
          : int.parse(
              (await _sharedDao.get("ICECandidateNumbers")) ??
                  ICE_CANDIDATE_NUMBER.toInt().toString(),
            );
      candidateTimeLimit = _reconnectTry
          ? 3000
          : int.parse(
              (await _sharedDao.get("ICECandidateTimeLimit")) ??
                  ((_isVideo)
                      ? "2000"
                      : ICE_CANDIDATE_TIME_LIMIT.toInt().toString()),
            ); // 0.5 sec for audio and 1.0 for video
    } catch (e) {
      _logger.e(e);
      candidateNumber = ICE_CANDIDATE_NUMBER.toInt();
      candidateTimeLimit = ICE_CANDIDATE_TIME_LIMIT.toInt();
    }
    _logger.i(
      "candidateNumber:$candidateNumber",
      "candidateTimeLimit:$candidateTimeLimit",
    );

    return _WaitingTillCandidateExceed(
      candidateNumber,
      candidateTimeLimit,
    );
  }

  Future _WaitingTillCandidateExceed(
    int candidateNumber,
    int candidateTimeLimit,
  ) async {
    final completer = Completer();
    _logger.i(
      "Time for w8:${clock.now().millisecondsSinceEpoch - _candidateStartTime}",
    );
    if ((_candidate.length >= candidateNumber) ||
        (clock.now().millisecondsSinceEpoch - _candidateStartTime >
            candidateTimeLimit)) {
      completer.complete();
      _isOfferReady = true;
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
      return _WaitingTillCandidateExceed(candidateNumber, candidateTimeLimit);
    }
    return completer.future;
  }

  Future<void> _waitUntilOfferReady() async {
    final completer = Completer();
    if (_isOfferReady) {
      completer.complete();
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
      return _waitUntilOfferReady();
    }
    return completer.future;
  }

  Future<void> _calculateCandidate() async {
    _candidateStartTime = clock.now().millisecondsSinceEpoch;
    //w8 till candidate gathering conditions complete
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :${_candidate.length}");
  }

  Future<void> _sendOffer() async {
    //w8 till offer is Ready
    await _waitUntilOfferReady();
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
    _checkRetrySendOffer(callOfferByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Offer";
  }

  void _checkRetrySendOffer(CallOfferByClient callOffer) {
    timerResendOffer = Timer(const Duration(seconds: 5), () {
      _coreServices.sendCallOffer(callOffer);
      _callEvents[clock.now().millisecondsSinceEpoch] = "Retry Send Offer";
      _checkRetrySendOffer(callOffer);
    });
  }

  Future<void> _calculateCandidateAndSendAnswer() async {
    _candidateStartTime = clock.now().millisecondsSinceEpoch;
    await _waitUntilCandidateConditionDone();
    _logger.i("Candidate Number is :${_candidate.length}");
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
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Answer";

    _checkRetryAnswer(callAnswerByClient);

    if (_reconnectTry) {
      callingStatus.add(CallStatus.RECONNECTING);
    }

    //Set Timer 30 sec for end call if Call doesn't Connected
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED &&
          callingStatus.value != CallStatus.NO_CALL) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.NO_ANSWER);
        endCall();
      }
    });
  }

  void _checkRetryAnswer(CallAnswerByClient callAnswer) {
    timerResendAnswer = Timer(const Duration(seconds: 5), () {
      _callEvents[clock.now().millisecondsSinceEpoch] = "Retry Send Answer";
      _coreServices.sendCallAnswer(callAnswer);
      _checkRetryAnswer(callAnswer);
    });
  }

  Future<void> _setCandidate(List<RTCIceCandidate> candidates) async {
    for (final candidate in candidates) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

//Windows memory leak Warning!! https://github.com/flutter-webrtc/flutter-webrtc/issues/752
  Future<void> _dispose() async {
    _logger.i("!!!!Disposeeeee!!!!");
    try {
      await cancelCallNotification();
      if (isAndroid) {
        _localStream!.getAudioTracks()[0].enableSpeakerphone(false);
        _isNotificationSelected = false;
        modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(null);
        _receivePort?.close();
        await _notificationForegroundService.callForegroundServiceStop();
        if (!_isCaller) {
          await ConnectycubeFlutterCallKit.setOnLockScreenVisibility(
            isVisible: false,
          );
        }
      } else {
        try {
          _audioService.stopCallAudioPlayer();
        } catch (e) {
          _logger.e(e);
        }
      }

      if (_isConnected) {
        unawaited(_decreaseCandidateAndWaitingTime());
      }

      if (_isCaller) {
        if (_isConnected) {
          await _dataChannel?.close();
        }
      }

      callingStatus.add(CallStatus.ENDED);
      _logger.i("end call in service");

      await _cleanLocalStream();
      //await _cleanRtpSender();
      if (_peerConnection != null) {
        await _peerConnection?.close();
        await _peerConnection?.dispose();
        _peerConnection = null;
      }
      _candidate = [];
    } catch (e) {
      _logger.e(e);
    } finally {
      _roomUid = null;
      //End all Timers
      _cancelAllTimers();

      _callEvents[clock.now().millisecondsSinceEpoch] = "Dispose";
      //reset variable valeus
      _offerSdp = "";
      _answerSdp = "";
      isAccepted = false;
      _isSharing = false;
      _isMicMuted = false;
      _isCaller = false;
      _isOfferReady = false;
      _isDCReceived = false;
      _callDuration = 0;
      _startCallTime = 0;
      _callDuration = 0;
      _isCallFromDb = false;

      //reset BehaviorSubject values
      switching.add(false);
      sharing.add(false);
      incomingSharing.add(false);
      videoing.add(false);
      incomingVideo.add(false);
      incomingVideoSwitch.add(false);
      desktopDualVideo.add(true);
      incomingCallOnHold.add(false);
      isConnectedSubject.add(false);
      await _phoneStateStream?.cancel();
      isSpeaker.add(false);

      try {
        await _callService.clearCallData(
          forceToClearData: true,
          isSaveCallData: true,
        );
        await _callService.disposeCallData(forceToClearData: true);

        if (isAndroid) {
          await Wakelock.disable();
        }
      } catch (e) {
        _logger.e(e);
      }

      Timer(const Duration(milliseconds: 1000), () async {
        _logger.i("END!");
        if (_routingService.canPop() && _routingService.isInCallRoom()) {
          _routingService.pop();
        }

        if (_isConnected) {
          _audioService.playEndCallSound();
        }

        _isEnded = false;
        _isEndedReceived = false;
        _reconnectTry = false;
        _isConnected = false;
        _isVideo = false;
        _isCallInitiated = false;
        callTimer.add(CallTimer(0, 0, 0));
        _audioService
          ..turnUpTheCallVolume()
          ..stopCallAudioPlayer();
        _audioToggleOnCall();
        Timer(const Duration(milliseconds: 100), () async {
          callingStatus.add(CallStatus.NO_CALL);
        });
      });
    }
  }

  void _cancelAllTimers() {
    if (timerDisconnected != null) {
      timerDisconnected!.cancel();
    }
    if (timerResendOffer != null) {
      timerResendOffer!.cancel();
    }
    if (timerResendAnswer != null) {
      timerResendAnswer!.cancel();
    }
    if (timerConnectionFailed != null) {
      timerConnectionFailed!.cancel();
    }
    if (timerDeclined != null) {
      timerDeclined!.cancel();
    }
    if (timer != null) {
      timer!.cancel();
    }
    if (videoMotivation != null) {
      videoMotivation!.cancel();
    }
  }

  Future<void> reset() async {
    _callEvents = {};
    _selectedCandidate = StatsReport("id", "type", 0, {});
    await _dispose();
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

  // ignore: unused_element
  Future<void> _cleanRtpSender() async {
    if (_audioSender != null) {
      await _audioSender!.dispose();
    }
    if (_videoSender != null) {
      await _videoSender!.dispose();
    }
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

  void _audioToggleOnCall() {
    try {
      if (_audioService.playerState.value == AudioPlayerState.playing) {
        _audioService.pauseAudio();
        _isAudioToggleOnCall = true;
      } else if (_isAudioToggleOnCall) {
        _audioService.resumeAudio();
        _isAudioToggleOnCall = false;
      }
    } catch (e) {
      _logger.e(e);
    }
  }

// ignore: non_constant_identifier_names
  BehaviorSubject<CallStatus> callingStatus =
      BehaviorSubject.seeded(CallStatus.NO_CALL);
  BehaviorSubject<bool> switching = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> sharing = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> incomingSharing = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> videoing = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> incomingVideo = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> incomingVideoSwitch = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> desktopDualVideo = BehaviorSubject.seeded(true);
  BehaviorSubject<bool> isSpeaker = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> incomingCallOnHold = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> isConnectedSubject = BehaviorSubject.seeded(false);

  Future<void> fetchUserCallList(
    Uid roomUid,
  ) async {
    try {
      var date = clock.now();
      for (var i = 0; i < 6; i++) {
        final callLists = await _sdr.queryServiceClient.fetchUserCalls(
          FetchUserCallsReq()
            ..roomUid = roomUid
            ..limit = 200
            ..pointer = Int64(
              clock.now().millisecondsSinceEpoch,
            )
            ..fetchingDirectionType =
                FetchUserCallsReq_FetchingDirectionType.BACKWARD_FETCH
            ..month = date.month - 1
            ..year = date.year,
        );
        for (final call in callLists.cellEvents) {
          final callEvent = call_event.CallEvent(
            callDuration: call.callEvent.callDuration.toInt(),
            callType: _callService.findCallEventType(call.callEvent.callType),
            callStatus: _callService
                .findCallEventStatusProto(call.callEvent.callStatus),
            id: call.callEvent.callId,
          );
          final callList = call_info.CallInfo(
            callEvent: callEvent,
            from: call.from.asString(),
            to: call.to.asString(),
            time: call.time.toInt(),
          );
          await _callListDao.save(callList);
        }
        date = date.subtract(const Duration(days: 30));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _increaseCandidateAndWaitingTime() async {
    final candidateNumber = int.parse(
      await _sharedDao.get("ICECandidateNumbers") ??
          ICE_CANDIDATE_NUMBER.toInt().toString(),
    );
    if (candidateNumber <= ICE_CANDIDATE_NUMBER) {
      _featureFlags
        ..setICECandidateTimeLimit(2000)
        ..setICECandidateNumber(17);
    } else if (candidateNumber <= 17) {
      _featureFlags
        ..setICECandidateTimeLimit(3000)
        ..setICECandidateNumber(20);
    }
  }

  Future<void> _decreaseCandidateAndWaitingTime() async {
    final candidateNumber = int.parse(
      await _sharedDao.get("ICECandidateNumbers") ??
          ICE_CANDIDATE_NUMBER.toInt().toString(),
    );
    if (candidateNumber >= 19) {
      _featureFlags
        ..setICECandidateTimeLimit(2000)
        ..setICECandidateNumber(17);
    } else if (candidateNumber >= 17) {
      _featureFlags
        ..setICECandidateTimeLimit(ICE_CANDIDATE_TIME_LIMIT)
        ..setICECandidateNumber(ICE_CANDIDATE_NUMBER);
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

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/call-screen");
    sPort?.send('onNotificationPressed');
  }
}
