import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/notification_foreground_service.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/vibration.dart';
import 'package:deliver/utils/call_utils.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
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
  NO_ANSWER,
  WEAK_NETWORK
}

class CallRepo {
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

  final _logger = GetIt.I.get<Logger>();

  final _coreServices = GetIt.I.get<CoreServices>();
  final _callService = GetIt.I.get<CallService>();
  final _notificationForegroundService =
      GetIt.I.get<NotificationForegroundService>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _appLifecycleService = GetIt.I.get<AppLifecycleService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _audioService = GetIt.I.get<AudioService>();
  final _routingService = GetIt.I.get<RoutingService>();

  bool get isMicMuted => _isMicMuted;
  MediaStream? _localStream;
  MediaStream? _localStreamShare;
  RTCRtpSender? _videoSender;
  RTCRtpSender? _audioSender;
  RTCDataChannel? _dataChannel;
  String _callOfferBody = "";
  String _callOfferCandidate = "";
  List<Map<String, Object>> _candidate = [];
  CallEvents _lastCallEvent = CallEvents.none;

  String _offerSdp = "";
  String _answerSdp = "";
  int _candidateStartTime = 0;

  RTCPeerConnection? _peerConnection;

  Map<int, String> _callEvents = {};
  StatsReport _selectedCandidate = StatsReport("id", "type", 0, {});
  bool _isSharing = false;
  bool _isCaller = false;
  bool _isVideo = false;
  bool _isConnected = false;
  bool _isAnswerReceived = false;
  bool _isMicMuted = false;
  bool _isDCReceived = false;
  bool _reconnectTry = false;
  bool _isEnded = false;
  bool _isEndedReceived = false;
  bool _isOfferReady = false;
  bool _isCallInitiated = false;
  bool _isCallFromDb = false;
  bool _isCallFromNotActiveState = false;

  bool _isInitRenderer = false;
  bool _isAudioToggleOnCall = false;
  Uid? _roomUid;

  bool get isCaller => _isCaller;

  bool get isConnected => _isConnected;

  Uid? get roomUid => _roomUid;

  bool get isSharing => _isSharing;

  bool get isVideo => _isVideo;

  bool get isCallFromNotActiveState => _isCallFromNotActiveState;

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

  int _startCallTime = 0;
  int _callDuration = 0;
  int _endCallTime = 0;
  int _shareDelay = 1;

  int? get callDuration => _callDuration;

  bool get isAccepted => _isAccepted;
  Timer? timerDeclined;
  Timer? _timerRinging;
  Timer? timerResendEvent;
  Timer? timerConnectionFailed;
  Timer? timerDisconnected;
  Timer? timerEndCallDispose;
  Timer? videoMotivation;
  Timer? _timerStatReport;
  BehaviorSubject<CountTimer> callTimer =
      BehaviorSubject.seeded(CountTimer(0, 0, 0));
  bool _isNotificationSelected = false;
  bool _isAccepted = false;
  bool _notifyIncomingCall = false;
  Timer? timer;
  StreamSubscription<PhoneState?>? _phoneStateStream;

  ReceivePort? _receivePort;

  StreamSubscription? _callStreamSubscription;

  CallRepo() {
    _callStreamSubscription?.cancel();
    _listenBackgroundCall();
    _listenOnCallEvent();
  }

  void _listenOnCallEvent() {
    _callStreamSubscription =
        _callService.callEvents.distinct().listen((event) async {
      if (event.callEvent != null &&
          inComingAnswerForAnotherSessionCall(event)) {
        unawaited(_dispose());
      }
      if (event.callEvent == null ||
          checkCallExpireTimeFailed(event) ||
          checkSession(event)) {
        return;
      }
      final callEvent = event.callEvent!;
      final isRepeated = await _callService.checkIncomingCallIsRepeated(
        callEvent.id,
        callEvent.from.asString(),
      );
      if (isRepeated ?? false) {
        return;
      }
      final from = callEvent.from.asString();
      final currentUserUid = _authRepo.currentUserUid;
      switch (callEvent.whichType()) {
        case CallEventV2_Type.answer:
          if (from.isSameEntity(currentUserUid)) {
            unawaited(_dispose());
          } else if (!_isAnswerReceived) {
            unawaited(_receivedCallAnswer(callEvent.answer));
            _callEvents[clock.now().millisecondsSinceEpoch] = "Received Answer";
            _isAnswerReceived = true;
          }
          break;
        case CallEventV2_Type.offer:
          _callEvents[callEvent.time.toInt()] = "Created";
          if (from.isSameEntity(currentUserUid)) {
            unawaited(_dispose());
          } else {
            if (settings.localNetworkMessenger.value) {
              if (_callService.getCallId.isEmpty) {
                _callService.setCallId = callEvent.id;
              }
            }
            if (isCallIdEqualToCurrentCallId(event) && !_callOfferIsReady()) {
              _cancelTimerResendEvent();
              _callOfferBody = callEvent.offer.body;
              _callOfferCandidate = callEvent.offer.candidates;
              if (!isDesktopNative && !_isCallFromDb) {
                _saveOfferOnDB(
                  callEvent.offer.body,
                  callEvent.offer.candidates,
                );
              }
            } else if (callEvent.id != _callService.getCallId) {
              unawaited(_busyCall(event));
            }
          }
          break;
        case CallEventV2_Type.ringing:
          if (!from.isSameEntity(currentUserUid)) {
            if (!_callService.hasCall && !callEvent.ringing.fromAnswerSide) {
              _lastCallEvent = event;
              _logger.i(
                  "-----------------------------------${_callService.getUserCallState}",);
              _callService.setUserCallState = UserCallState.IN_USER_CALL;
              _handleIncomingCallOnReceiver(callEvent);
            } else if (_isCaller && isCallIdEqualToCurrentCallId(event)) {
              _cancelTimerResendEvent();
              if (_handleSynchronousCall()) {
                if (_synchronousCallSelect(event.callEvent!.from.toString(),
                    event.callEvent!.to.toString(),)) {
                  _callEvents[callEvent.time.toInt()] = "IsRinging";
                  unawaited(_sendOffer());
                  callingStatus.add(CallStatus.IS_RINGING);
                } else {
                  _handleOnSelectedInSynchronous();
                }
              } else {
                _callEvents[callEvent.time.toInt()] = "IsRinging";
                unawaited(_sendOffer());
                callingStatus.add(CallStatus.IS_RINGING);
              } try {
                _audioService.playBeepSound();
              } catch (e) {
                _logger.e(e);
              }
            } else if (!isCallIdEqualToCurrentCallId(event)) {
              unawaited(_busyCall(event));
            }
          }
          break;
        case CallEventV2_Type.busy:
          _callEvents[callEvent.time.toInt()] = "Busy";
          if (isCallIdEqualToCurrentCallId(event)) {
            unawaited(receivedBusyCall());
          }
          break;
        case CallEventV2_Type.decline:
          _callEvents[callEvent.time.toInt()] = "Declined";
          if (isCallIdEqualToCurrentCallId(event)) {
            unawaited(receivedDeclinedCall());
          }
          break;
        case CallEventV2_Type.end:
          _callEvents[callEvent.time.toInt()] = "Ended";
          if (isCallIdEqualToCurrentCallId(event)) {
            unawaited(receivedEndCall());
          }
          break;
        case CallEventV2_Type.notSet:
          break;
      }
    });
  }

  void _listenBackgroundCall() {
    _callService.watchCurrentCall().listen((call) {
      //check if there is call and user have mobile device
      if (call != null && !isDesktopNative) {
        if (call.expireTime > clock.now().millisecondsSinceEpoch &&
            _callService.getUserCallState == UserCallState.NO_CALL) {
          _isNotificationSelected = call.notificationSelected;
          _isAccepted = call.isAccepted;
          _isCallFromDb = true;
          _logger.i(
            "read call from DB notificationSelected : ${call.notificationSelected}",
          );
          _callOfferBody = call.offerBody;
          _callOfferCandidate = call.offerCandidate;
          _callService.callEvents.add(
            CallEvents.callEvent(
              call.callEvent,
            ),
          );
        }
      }
    });
  }
  bool _handleSynchronousCall() {
    if(_lastCallEvent != CallEvents.none && !_lastCallEvent.callEvent!.ringing.fromAnswerSide) {
      if(_authRepo.currentUserUid.toString() == _lastCallEvent.callEvent?.to.toString()) {
        return true;
      }
    }
    return false;
  }

  bool _synchronousCallSelect(String from, String to) {
    if(from.compareTo(to) < 0) {
      return false;
    }
    return true;
  }

  void _handleOnSelectedInSynchronous() {
    _isCaller = false;
    _callService..setCallId = _lastCallEvent.callEvent!.id
    ..setUserCallState = UserCallState.IN_USER_CALL;
    _handleIncomingCallOnReceiver(_lastCallEvent.callEvent!);
  }
  // it is used to detect audio track (probably)
  Future<void> _audioLevelDetection() async {
    _timerStatReport =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_isConnected) {
        //final audioTrack = _localStream!.getAudioTracks()[0];
        final stats = await _peerConnection!.getStats();
        for (final stat in stats) {
          if (stat.type == "media-source") {
            if (stat.values["audioLevel"] != null) {
              final double audioLevel = stat.values["audioLevel"];
              speakingAmplitude.add(audioLevel);
              if (_isDCReceived) {
                await _dataChannel!.send(
                  RTCDataChannelMessage(
                    "$STATUS_SPEAKING_AUDIO_LEVEL:$audioLevel",
                  ),
                );
              }
            }
          }
        }
      }
    });
  }

  // here we have function that is used to handle income call from another person and save it in DB (probably)
  void _handleIncomingCallOnReceiver(CallEventV2 callEvent) {
    _callEvents[callEvent.time.toInt()] = "IsRinging";
    // if (callingStatus.value != CallStatus.CONNECTING) {
    //   callingStatus.add(CallStatus.IS_RINGING);
    // }
    _roomUid = callEvent.from;
    _callService
      ..setCallId = callEvent.id
      ..setVideoCall = callEvent.isVideo
      ..setRoomUid = callEvent.from;

    _isVideo = callEvent.isVideo;
    // this if statement is used to check if user peak up the phone (probably)
    if (_isAccepted) {
      modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(
        CallNotificationActionInBackground(
          roomId: _roomUid!.asString(),
          isCallAccepted: true,
          isVideo: _isVideo,
        ),
      );
    } else {
      if (!isDesktopNative && !_isCallFromDb) {
        //get call Info and Save on DB
        _saveCallInfoOnDB(callEvent);
      }
      _incomingCall(
        _notifyIncomingCall,
        callEvent.writeToJson(),
      );
    }
  }

  // simple just save call info on DB
  void _saveCallInfoOnDB(CallEventV2 callEvent) {
    final from = callEvent.from.asString();
    final to = _authRepo.currentUserUid.asString();
    //get call Info and Save on DB
    final callInfo = CurrentCallInfo(
      callEvent: callEvent,
      from: from,
      to: to,
      expireTime: callEvent.time.toInt() + 60000,
      notificationSelected: _isNotificationSelected,
      isAccepted: _isAccepted,
    );

    _callService.saveCallOnDb(callInfo);
    _logger.i("save call on db!");
  }

  void _saveOfferOnDB(String offerBody, String offerCandidate) {
    _logger.i("save call offer on db!");
    _callService.saveCallOfferOnDb(offerBody, offerCandidate);
  }

  Future<void> _busyCall(CallEvents event) async {
    await _callService.saveCallStatusData();
    _sendBusy(event);
  }

  bool checkCallExpireTimeFailed(CallEvents event) {
    return ((event.callEvent!.time.toInt() - clock.now().millisecondsSinceEpoch)
            .abs()) >
        60000;
  }

  bool checkSession(CallEvents event) {
    return event.callEvent!.to.sessionId != "*" &&
        event.callEvent!.to.sessionId != _authRepo.currentUserUid.sessionId;
  }

/*
  * initial Variable for Render Call Between 2 Client
  * */
  Future<void> initCall({bool isOffer = false}) async {
    _peerConnection = await _createPeerConnection(isOffer);
    if (isMobileNative && await requestPhoneStatePermission()) {
      _startListenToPhoneCallState();
    }

    if (isOffer) {
      _dataChannel = await _createDataChannel();
      _offerSdp = await _createOffer();
    }
  }

  Future<bool> requestPhoneStatePermission() async {
    try {
      final status = await Permission.phone.request();

      switch (status) {
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.limited:
        case PermissionStatus.permanentlyDenied:
          return false;
        case PermissionStatus.provisional:
        case PermissionStatus.granted:
          return true;
      }
    } catch (e) {
      _logger.e(e);
    }
    return false;
  }

  void _startListenToPhoneCallState() {
    _phoneStateStream = PhoneState.stream.listen((event) {
      if (event.status == PhoneStateStatus.CALL_STARTED) {
        _analyticsService.sendLogEvent(
          "callOnHold",
        );
        _logger.i("PhoneState.phoneStateStream=CALL_STARTED");
        if (_isDCReceived) {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_CALL_ON_HOLD));
        }
      } else if (event.status == PhoneStateStatus.CALL_ENDED) {
        _logger.i("PhoneState.phoneStateStream=CALL_ENDED");
        if (_isDCReceived) {
          _dataChannel!.send(RTCDataChannelMessage(STATUS_CALL_ON_HOLD_ENDED));
        }
      }
    });
  }

  // This function use for setting up and managing the real-time communication between two peers.
  Future<RTCPeerConnection> _createPeerConnection(bool isOffer) async {
    // maybe this line is what i'm looking for (createPeerConnection)
    final pc = await createPeerConnection(
      CallUtils.getIceServers(),
      CallUtils.getConfig(),
    );
    _localStream = await CallUtils.getUserMedia(isVideo: _isVideo);
    final camAudioTrack = _localStream!.getAudioTracks()[0];
    if (!isDesktopNative) {
      _audioService.turnDownTheCallVolume();
    }
    _audioSender = await pc.addTrack(camAudioTrack, _localStream!);

    if (_isVideo) {
      _localStream!.getVideoTracks()[0].enabled = false;
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
            isConnectedSubject.add(true);
            //onRTCPeerConnectionConnected();
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
            _logger.e("");
            // this cases no matter and don't have impact on our Work
            break;
        }
      }

      //https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/connectionState
      ..onConnectionState = (state) async {
        _logger.i("onConnectionState $state");
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            await onRTCPeerConnectionConnected();
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            onRTCPeerConnectionDisconnected();
            break;
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            //Try reconnect
            await onRTCPeerConnectionStateFailed();
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
          if (!settings.localNetworkMessenger.value || _candidate.isEmpty) {
            _candidate.add({
              'candidate': e.candidate.toString(),
              'sdpMid': e.sdpMid.toString(),
              'sdpMlineIndex': e.sdpMLineIndex!,
            });

            if (_isAccepted) {
              _calculateCandidateAndSendAnswer();
            }
          }
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
        if (isWeb || isMacOSNative) {
          onAddRemoteStream?.call(stream);
        }
      }
      ..onAddTrack = (stream, track) {
        _logger.i('addTrack: ${stream.id} - ${track.label} - ${track.kind}');
        //stream.addTrack(track);
        if (track.kind == "video") {
          onAddRemoteStream?.call(stream);
        }
      }
      ..onRemoveTrack = (stream, track) {
        // stream.removeTrack(track);
        // onAddRemoteStream?.call(stream);
      }
      ..onRemoveStream = (stream) {
        //onRemoveRemoteStream?.call(stream);
      }
      // ..onRenegotiationNeeded = () async {
      //   _logger.i("onRenegotiationNeeded");
      //   final offer = await _createOffer();
      //   await _sendOfferRenegotiation(offer);
      // }
      ..onDataChannel = (channel) {
        _dataChannel = channel;
        _dataChannel!
          ..onDataChannelState = (state) {
            if (state == RTCDataChannelState.RTCDataChannelOpen) {
              _logger.i("data Channel Received!!");
              _isDCReceived = true;
            }
          }
          ..onMessage = (data) async {
            final status = data.text.split(":");
            // we need Decision making by state
            switch (status[0]) {
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
                incomingAudioMuted.add(false);
                break;
              case STATUS_MIC_CLOSE:
                incomingAudioMuted.add(true);
                break;
              case STATUS_SHARE_SCREEN:
                unawaited(
                  _analyticsService.sendLogEvent(
                    "shareScreenOnVideoCall",
                  ),
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
                if (!_reconnectTry && !_isConnected) {
                  await _startCallTimerAndChangeStatus();
                } else {
                  callingStatus.add(CallStatus.CONNECTED);
                  _reconnectTry = false;
                }
                if (timerConnectionFailed != null) {
                  timerConnectionFailed!.cancel();
                }
                break;
              case STATUS_CONNECTION_CONNECTING:
                callingStatus.add(CallStatus.CONNECTING);
                break;
              case STATUS_CONNECTION_ENDED:
                //received end
                _isEndedReceived = true;
                unawaited(receivedEndCall());
                break;
              case STATUS_SPEAKING_AUDIO_LEVEL:
                incomingSpeakingAmplitude.add(double.parse(status[1]));
                break;
            }
          };
      };

    return pc;
  }

  Future<void> setConnectionQualityAndLimitationParamsForAudio() async {
    //when connection Connected Status we Set some limit on bitRate
    try {
      final RTCRtpParameters params;
      params = _audioSender!.parameters;
      if (params.encodings!.isEmpty) {
        params.encodings = [];
        params.encodings!.add(RTCRtpEncoding());
      }

      params.encodings![0].active = true;
      if (settings.highQualityCall.value) {
        params.encodings![0].minBitrate =
            WEBRTC_MIN_BITRATE_HIGH_QUALITY_AUDIO_CALL; // 320 kbps and use less about 150-160 kbps
      } else if (settings.lowNetworkUsageVoiceCall.value) {
        params.encodings![0].maxBitrate =
            WEBRTC_MAX_BITRATE_LOW_AUDIO_CALL; // 32 kbps
      } else {
        params.encodings![0].maxBitrate =
            WEBRTC_MAX_BITRATE_NORMAL_AUDIO_CALL; // 64 kbps
      }
      final paramSetResult = await _audioSender!.setParameters(params);
      _logger.i("Set Param result AudioSender is : $paramSetResult");
    } catch (e) {
      _logger.w(e);
    }
  }

  Future<void> setConnectionQualityAndLimitationParamsForVideo() async {
    //when connection Connected Status we Set some limit on bitRate
    try {
      final RTCRtpParameters params;
      params = _videoSender!.parameters;
      if (params.encodings!.isEmpty) {
        params.encodings = [];
        params.encodings!.add(RTCRtpEncoding());
      }

      params.encodings![0].active = true;
      if (_videoSender != null) {
        if (settings.lowNetworkUsageVideoCall.value) {
          params.encodings![0].maxBitrate =
              WEBRTC_MAX_BITRATE_LOW_VIDEO_CALL; // 256 kbps
        } else {
          params.encodings![0].maxBitrate =
              WEBRTC_MAX_BITRATE_NORMAL_VIDEO_CALL; // 512 kbps
        }
        params.encodings![0].maxFramerate = _callService
            .getVideoCallQualityDetails(settings.videoCallQuality.value)
            .getFrameRate();
        params.encodings![0].scaleResolutionDownBy = 2;
        final paramSetResult = await _videoSender!.setParameters(params);
        _logger.i("Set Param result VideoSender is : $paramSetResult");
      }
      final paramSetResult = await _audioSender!.setParameters(params);
      _logger.i("Set Param result AudioSender is : $paramSetResult");
    } catch (e) {
      _logger.w(e);
    }
  }

  void onRTCPeerConnectionDisconnected() {
    try {
      _callEvents[clock.now().millisecondsSinceEpoch] = "disConnected";
      isConnectedSubject.add(false);
      Timer(const Duration(seconds: 1), () {
        if (!_reconnectTry && !_isEnded && !_isEndedReceived) {
          if (_peerConnection!.connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
            _reconnectTry = true;
            _reconnectingAfterFailedConnection();
            callingStatus.add(CallStatus.DISCONNECTED);
            timerDisconnected = Timer(const Duration(seconds: 12), () {
              if (callingStatus.value != CallStatus.CONNECTED) {
                _logger.i("Disconnected and Call Ended!");
                endCall();
              }
            });
          }
        }
      });
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> onRTCPeerConnectionConnected() async {
    try {
      await _startCallTimerAndChangeStatus();
      _logger.i("Call Connected");
      timerConnectionFailed?.cancel();
      _cancelTimerResendEvent();

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

      if (!_reconnectTry) {
        unawaited(
          _analyticsService.sendLogEvent(
            "connectedCall",
          ),
        );
        lightVibrate().ignore();
      }

      callingStatus.add(CallStatus.CONNECTED);
      _callEvents[clock.now().millisecondsSinceEpoch] = "Connected";

      if (_isVideo) {
        if (hasSpeakerCapability) {
          try {
            await Wakelock.enable();
          } catch (e) {
            _logger.e(e);
          }
          _localStream!.getAudioTracks()[0].enableSpeakerphone(true);
          isSpeaker.add(true);
        }
      } else if (hasSpeakerCapability) {
        _localStream!.getAudioTracks()[0].enableSpeakerphone(isSpeaker.value);
      }

      if (_reconnectTry) {
        _reconnectTry = false;
        timerDisconnected?.cancel();
      } else if (_isCaller) {
        timerResendEvent!.cancel();
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> onRTCPeerConnectionStateFailed() async {
    try {
      await _peerConnection?.restartIce();
      _callEvents[clock.now().millisecondsSinceEpoch] = "Failed";
      if (!_reconnectTry && !_isEnded && !_isEndedReceived && !isConnected) {
        _reconnectTry = true;
        callingStatus.add(CallStatus.RECONNECTING);
        await _reconnectingAfterFailedConnection();
        timerDisconnected = Timer(const Duration(seconds: 15), () async {
          if (callingStatus.value != CallStatus.CONNECTED) {
            callingStatus.add(CallStatus.FAILED);
            _logger.i("Disconnected and Call End!");
            await _analyticsService.sendLogEvent(
              "failedCall",
            );
            endCall();
          }
        });
      }
    } catch (e) {
      _logger.e(e);
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
    //when connection Connected Status we Set some limit on bitRate
    await setConnectionQualityAndLimitationParamsForAudio();
    unawaited(lightVibrate());
    startCallTimer();
    _isConnected = true;
    if (_startCallTime == 0 && _isConnected) {
      _startCallTime = clock.now().millisecondsSinceEpoch;
    }
    if (_isDCReceived &&
        _dataChannel?.state == RTCDataChannelState.RTCDataChannelConnecting) {
      try {
        await _dataChannel!
            .send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTED));
      } catch (e) {
        _logger.e(e);
      }
    }
    _logger.i("Start Call $_startCallTime");
    callingStatus.add(CallStatus.CONNECTED);
    lightVibrate().ignore();
    isConnectedSubject.add(true);
    if (isVideo) {
      await _ShareCameraStatusFromDataChannel();
    }
    if (hasSpeakerCapability) {
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
        if (_isMicMuted) {
          await _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_CLOSE));
        }
      } else {
        _shareDelay = _shareDelay * 2;
        await _ShareCameraStatusFromDataChannel();
      }
    });
  }

  Future<RTCDataChannel> _createDataChannel() async {
    final dataChannelDict = RTCDataChannelInit()..maxRetransmits = 30;
    final dataChannel = await _peerConnection!
        .createDataChannel("stateTransfer", dataChannelDict);
    dataChannel
      ..onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          _logger.i("data Channel Received!!");
          _isDCReceived = true;
        }
      }
      ..onMessage = (data) async {
        final status = data.text.split(":");
        // we need Decision making by state
        switch (status[0]) {
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
            incomingAudioMuted.add(false);
            break;
          case STATUS_MIC_CLOSE:
            incomingAudioMuted.add(true);
            break;
          case STATUS_CALL_ON_HOLD:
            incomingCallOnHold.add(true);
            break;
          case STATUS_CALL_ON_HOLD_ENDED:
            incomingCallOnHold.add(false);
            break;
          case STATUS_SHARE_SCREEN:
            unawaited(
              _analyticsService.sendLogEvent(
                "shareScreenOnVideoCall",
              ),
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
            if (!_reconnectTry && !_isConnected) {
              await _startCallTimerAndChangeStatus();
            } else {
              callingStatus.add(CallStatus.CONNECTED);
              _reconnectTry = false;
            }
            if (timerConnectionFailed != null) {
              timerConnectionFailed!.cancel();
            }
            break;
          case STATUS_CONNECTION_CONNECTING:
            callingStatus.add(CallStatus.CONNECTING);
            break;
          case STATUS_SPEAKING_AUDIO_LEVEL:
            incomingSpeakingAmplitude.add(double.parse(status[1]));
            break;
          case STATUS_CONNECTION_ENDED:
            // this case use for prevent from disconnected state
            _isEndedReceived = true;
            unawaited(receivedEndCall());
            break;
        }
      };
    return dataChannel;
  }

/*
  * get Access from User for Camera and Microphone
  * */

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

      _localStreamShare = await CallUtils.getUserDisplay(source);
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

/*
  * For Close Microphone
  * */
  bool muteMicrophone() {
    if (_localStream != null) {
      final enabled = _localStream!.getAudioTracks()[0].enabled;
      if (_isDCReceived) {
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
      if (_isDCReceived) {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_OPEN));
      }
      _localStream!.getAudioTracks()[0].enabled = enabled;
      _isMicMuted = false;
      return enabled;
    }
    return false;
  }

  bool enableSpeakerVoice() {
    if (_localStream != null && !isDesktopNative) {
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
        if (_isDCReceived) {
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

  Future<bool> _requiredPermissionIsGranted() async =>
      (await getDeviceVersion() < 31 ||
          await Permission.systemAlertWindow.status.isGranted);

  Future<void> _incomingCall(
    bool isDuplicated,
    String callEventJson,
  ) async {
    try {
      _audioToggleOnCall();
      _notifyIncomingCall = true;
      if (_isNotificationSelected) {
        modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(
          CallNotificationActionInBackground(
            roomId: _roomUid!.asString(),
            isCallAccepted: false,
            isVideo: _isVideo,
          ),
        );
      } else if (!isDuplicated) {
        _isCallFromNotActiveState = _appLifecycleService.isActive;
        if ((await _checkForegroundStatus()) &&
            (_appLifecycleService.isActive &&
                    _routingService.isInRoom(_roomUid!.asString()) ||
                (isAndroidNative && !(await _requiredPermissionIsGranted())))) {
          modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(
            CallNotificationActionInBackground(
              roomId: _roomUid!.asString(),
              isCallAccepted: false,
              isVideo: _isVideo,
            ),
          );
        } else {
          await _notificationServices.notifyIncomingCall(
            _roomUid!.asString(),
            callEventJson: callEventJson,
          );
          if (!isAndroidNative) {
            _audioService.playIncomingCallSound();
          }
        }
      }
      _logger.i(
        "incoming Call and Created!!! "
        "(isDuplicated:) $isDuplicated , (notificationSelected) : $_isNotificationSelected",
      );
      if (callingStatus.value != CallStatus.CONNECTING) {
        callingStatus.add(CallStatus.IS_RINGING);
      }

      _sendRinging(fromAnswerSide: true);
      Timer(const Duration(milliseconds: 400), () async {
        if (isAndroidNative) {
          if (!_isVideo && await Permission.microphone.status.isGranted) {
            if (await getDeviceVersion() >= 31) {
              await initCall();
              _isCallInitiated = true;
            }
          }
        } else if (!_isVideo) {
          await initCall();
          _isCallInitiated = true;
        }
      });
    } catch (e) {
      _logger.e(e);
      await _dispose();
    }
  }

  Future<bool> _checkForegroundStatus() async =>
      settings.localNetworkMessenger.value &&
      (await FlutterForegroundTask.isAppOnForeground);

  Future<void> startCall(Uid roomId, {bool isVideo = false}) async {
    try {
      if (!_callService.hasCall) {
        unawaited(_sendLog(isVideo));
        //can't call another ppl or received any call notification
        _callService
          ..setUserCallState = UserCallState.IN_USER_CALL
          ..setRoomUid = roomId
          ..setVideoCall = isVideo;
        _isCaller = true;
        _isVideo = isVideo;
        _roomUid = roomId;
        _isCallInitiated = true;
        await initCall(isOffer: true);
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
        _generateNewCallId();
        _sendRinging();
        unawaited(_audioLevelDetection());
        if (hasForegroundServiceCapability) {
          final foregroundStatus =
              await _notificationForegroundService.callForegroundServiceStart();
          if (foregroundStatus) {
            _receivePort = _notificationForegroundService.getReceivePort;
            _receivePort?.listen((message) {
              if (message == ForeGroundConstant.STOP_CALL) {
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
        videoMotivation = Timer(AnimationSettings.standard, () async {
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

  Future<void> _sendLog(bool isVideo) async {
    if (isVideo) {
      await _analyticsService.sendLogEvent(
        "startVideoCall",
      );
    } else {
      await _analyticsService.sendLogEvent(
        "startAudioCall",
      );
    }
  }

  void _generateNewCallId() {
    final random = randomAlphaNumeric(10);
    final time = clock.now().millisecondsSinceEpoch;
    //call event id: (Epoch time milliseconds)-(Random String with alphabet and numerics with 10 characters length)
    final callId = "$time-$random";
    _callService.setCallId = callId;
  }

  void hangUp() {
    _logger.i("Call hang Up ...!");
    _audioService.stopCallAudioPlayer();
    if (!_callService.isHangedUp) {
      endCall();
      _callService.setCallHangedUp = true;
    }
  }

  Future<void> acceptCall(Uid roomId) async {
    try {
      _cancelTimerResendEvent();
      if (hasVibrationCapability) {
        cancelVibration().ignore();
      }
      _isAccepted = true;
      if (isDesktopNative) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }

      if (_roomUid == null || roomId.node != _roomUid!.node) {
        endCall();
      }

      callingStatus.add(CallStatus.CONNECTING);
      _audioService.stopCallAudioPlayer();
      _timerRinging?.cancel();

      //after accept Call w8 for 30 sec if don't connecting force end Call
      timerConnectionFailed = _startFailCallTimer();
      //if call come from backGround doesn't init and should be initialize
      if (!_isCallInitiated) {
        await initCall();
      }
      _localStream ??= await CallUtils.getUserMedia(isVideo: _isVideo);
      // change location of this line from mediaStream get to this line for prevent
      // exception on callScreen and increase call speed .
      onLocalStream?.call(_localStream!);
      _callService.setCallStart(callStart: true);
      //when call accepted
      unawaited(_receivedCallOffer());
      unawaited(_audioLevelDetection());
      _callEvents[clock.now().millisecondsSinceEpoch] = "Accept Call";
      if (hasForegroundServiceCapability) {
        final foregroundStatus =
            await _notificationForegroundService.callForegroundServiceStart();
        if (foregroundStatus) {
          _receivePort = _notificationForegroundService.getReceivePort;
          _receivePort?.listen((message) {
            if (message == ForeGroundConstant.STOP_CALL) {
              endCall();
            } else if (message == 'onNotificationPressed') {
              _routingService.openCallScreen(roomUid!, isVideoCall: isVideo);
            } else {
              _logger.i('receive callStatus: $message');
            }
          });
        }
      }
    } catch (e, es) {
      _logger
        ..e(es)
        ..e(e);
      await _dispose();
    }
  }

  Timer _startFailCallTimer() {
    return Timer(const Duration(seconds: 30), () {
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
  }

  Future<void> declineCall() async {
    if (_callService.getUserCallState == UserCallState.IN_USER_CALL) {
      if (isDesktopNative) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      _logger.i("declineCall");
      callingStatus.add(CallStatus.DECLINED);
      _sendDeclined();
      await _callService.saveCallStatusData();
      await _dispose();
    }
  }

  Future<void> _receivedCallAnswer(CallEventAnswer callAnswer) async {
    _isAccepted = true;
    _cancelTimerResendEvent();
    if (!_reconnectTry) {
      callingStatus.add(CallStatus.ACCEPTED);
      try {
        _audioService.stopCallAudioPlayer();
      } catch (e) {
        _logger.e(e);
      }
    }
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(callAnswer.body);
    await _setCallCandidate(callAnswer.candidates);
  }

//here we have accepted Call
  Future<void> _receivedCallOffer() async {
    Timer(const Duration(milliseconds: 500), () async {
      await _checkCallOfferIsReady();
    });
  }

  Future<void> _checkCallOfferIsReady() async {
    if (_callOfferIsReady()) {
      //set Remote Descriptions and Candidate
      await _setRemoteDescriptionOffer(_callOfferBody);
      await _setCallCandidate(_callOfferCandidate);
      //And Create Answer for Callee
      if (!_reconnectTry) {
        _answerSdp = await _createAnswer();
      }
    } else {
      await _receivedCallOffer();
    }
  }

  bool _callOfferIsReady() => _callOfferBody != "" && _callOfferCandidate != "";

  Future<void> _setCallCandidate(String candidatesJson) async {
    final candidates =
        (jsonDecode(candidatesJson) as List<dynamic>).map((element) {
      final data = element as Map<String, dynamic>;
      return RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMlineIndex'],
      );
    }).toList();
    await _setCandidate(candidates);
  }

  Future<void> receivedBusyCall() async {
    callingStatus.add(CallStatus.BUSY);
    await _callService.saveCallStatusData();
    await _dispose();
  }

  Future<void> receivedDeclinedCall() async {
    _logger.i("get declined");
    callingStatus.add(CallStatus.DECLINED);
    await _callService.saveCallStatusData();
    await _dispose();
  }

  Future<void> receivedEndCall() async {
    if (!_isEnded) {
      await _callService.saveCallStatusData();
      _isEnded = true;
      if (isDesktopNative) {
        _notificationServices.cancelRoomNotifications(roomUid!.node);
      }
      _callDuration = calculateCallEndTime();
      _sendEndCall(_callDuration);
      _logger.i("Call Duration : $_callDuration");
      await _dispose();
    }
  }

  Future<void> cancelCallNotification() async {
    if (isMobileNative && !_isCaller) {
      cancelVibration().ignore();
      final sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
      await ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    } else if (isDesktopNative) {
      _notificationServices.cancelRoomNotifications(roomUid!.node);
    }
  }

  void endCall() {
    if (!_isEnded) {
      try {
        if (callingStatus.value != CallStatus.NO_CALL) {
          if (isDesktopNative) {
            _notificationServices.cancelRoomNotifications(roomUid!.node);
          }
          if (_isDCReceived) {
            _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_ENDED));
          }
        }
      } catch (e) {
        _logger.e(e);
      } finally {
        receivedEndCall();
      }
    }
  }

  int calculateCallEndTime() {
    var time = 0;
    if (_startCallTime != 0 && _isConnected) {
      _endCallTime = clock.now().millisecondsSinceEpoch;
      time = _endCallTime - _startCallTime;
    }
    return max(time, 0);
  }

  Future<void> _setRemoteDescriptionOffer(String remoteSdp) async {
    try {
      final dynamic session = await jsonDecode(remoteSdp);

      final sdp = write(session, null);

      final description = RTCSessionDescription(sdp, 'offer');

      unawaited(_peerConnection!.setRemoteDescription(description));
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> _setRemoteDescriptionAnswer(String remoteSdp) async {
    try {
      final dynamic session = await jsonDecode(remoteSdp);

      final sdp = write(session, null);

      final description = RTCSessionDescription(sdp, 'answer');
      await _peerConnection!.setRemoteDescription(description);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<String> _createAnswer({bool retry = true}) async {
    try {
      final description = await _peerConnection!
          .createAnswer(CallUtils.getSdpConstraints(isVideo: _isVideo));
      final session = parse(description.sdp.toString());
      final answerSdp = json.encode(session);
      _logger.i("Answer: \n$answerSdp");

      await _peerConnection!.setLocalDescription(description);
      return answerSdp;
    } catch (e) {
      _logger.e(e);
      if (retry) {
        return _createAnswer(retry: false);
      }
      return "";
    }
  }

  // this function use instead of RTCPeerConnection.createOffer()
  Future<String> _createOffer() async {
    final description = await _peerConnection!
        .createOffer(CallUtils.getSdpConstraints(isVideo: _isVideo));
    //get SDP as String
    final session = parse(description.sdp.toString());
    final offerSdp = json.encode(session);
    _logger.i("Offer: \n$offerSdp");
    unawaited(_peerConnection!.setLocalDescription(description));
    return offerSdp;
  }

  Future<void> _waitUntilCandidateConditionDone({bool isAnswer = false}) async {
    int candidateNumber;
    int candidateTimeLimit;
    try {
      candidateNumber = _reconnectTry ? 20 : settings.iceCandidateNumbers.value;
      candidateTimeLimit =
          _reconnectTry ? 3000 : settings.iceCandidateTimeLimit.value;
    } catch (e) {
      _logger.e(e);
      candidateNumber = ICE_CANDIDATE_NUMBER;
      candidateTimeLimit = ICE_CANDIDATE_TIME_LIMIT;
    }
    _logger.i(
      "candidateNumber:$candidateNumber",
      error: "candidateTimeLimit:$candidateTimeLimit",
    );
    if (isAnswer) {
      candidateNumber = (candidateNumber / 2).floor();
      candidateTimeLimit = (candidateTimeLimit / 2).floor();
    }

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
    if(_handleSynchronousCall()) {
      if(_synchronousCallSelect(_authRepo.currentUserUid.asString(), _roomUid!.asString())) {
        await _createSendOffer();
      } else {
        _handleOnSelectedInSynchronous();
      }
    } else {
      await _createSendOffer();
    }
  }

  Future<void> _createSendOffer() async {
    //wait till offer is Ready
    await _waitUntilOfferReady();
    // Send Candidate to Receiver
    final jsonCandidates = jsonEncode(_candidate);
    //Send offer and Candidate as message to Receiver
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = _callService.getCallId
      ..to = _roomUid!
      ..isVideo = _isVideo
      ..offer = (CallEventOffer()
        ..body = _offerSdp
        ..candidates = jsonCandidates));
    _coreServices.sendCallEvent(callEventV2ByClient);
    _sendCallOffer(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Created";
  }

  void _sendCallOffer(CallEventV2ByClient callEventV2ByClient) {
    if (settings.localNetworkMessenger.value) {
      Timer(const Duration(milliseconds: 700), () {
        if (callingStatus.value == CallStatus.IS_RINGING) {
          _coreServices.sendCallEvent(callEventV2ByClient);
          _sendCallOffer(callEventV2ByClient);
        }
      });
    } else {
      _coreServices.sendCallEvent(callEventV2ByClient);
    }
  }

  void _sendRinging({
    bool isRetry = true,
    bool fromAnswerSide = false,
  }) {
    //Send Ringing means received Call Event With Offer
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = _callService.getCallId
      ..to = _roomUid!
      ..isVideo = _isVideo
      ..ringing = CallEventRinging(fromAnswerSide: fromAnswerSide));
    _coreServices.sendCallEvent(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Ringing";
    _checkRetryCallEvent(callEventV2ByClient, isRetry: isRetry);
  }

  void _sendBusy(CallEvents event) {
    //Send Busy
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = event.callEvent!.id
      ..to = event.callEvent!.from
      ..isVideo = event.callEvent!.isVideo
      ..busy = CallEventBusy());
    _coreServices.sendCallEvent(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Busy";
    _checkRetryCallEvent(callEventV2ByClient);
  }

  void _sendDeclined() {
    //Send Declined
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = _callService.getCallId
      ..to = _roomUid!
      ..isVideo = _isVideo
      ..decline = CallEventDecline());
    _coreServices.sendCallEvent(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Decline";
    _checkRetryCallEvent(callEventV2ByClient);
  }

  void _sendEndCall(int callDuration) {
    //Send End Call
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = _callService.getCallId
      ..to = _roomUid!
      ..isVideo = _isVideo
      ..end = CallEventEnd(callDuration: Int64(callDuration) , isCaller: _isCaller));
    _coreServices.sendCallEvent(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send EndCall";
    _checkRetryCallEvent(callEventV2ByClient);
  }

  Future<void> _calculateCandidateAndSendAnswer() async {
    _candidateStartTime = clock.now().millisecondsSinceEpoch;
    await _waitUntilCandidateConditionDone(isAnswer: true);
    _logger.i("Candidate Number is :${_candidate.length}");
    // Send Candidate back to Sender
    final jsonCandidates = jsonEncode(_candidate);
    //Send Answer and Candidate as message to Sender
    final callEventV2ByClient = (CallEventV2ByClient()
      ..id = _callService.getCallId
      ..to = _roomUid!
      ..isVideo = _isVideo
      ..answer = (CallEventAnswer()
        ..body = _answerSdp
        ..candidates = jsonCandidates));
    _logger.i(_candidate);
    _coreServices.sendCallEvent(callEventV2ByClient);
    _callEvents[clock.now().millisecondsSinceEpoch] = "Send Answer";

    unawaited(_checkRetryCallEvent(callEventV2ByClient));

    if (_reconnectTry) {
      callingStatus.add(CallStatus.RECONNECTING);
    }
  }

  Future<void> _checkRetryCallEvent(
    CallEventV2ByClient callEvent, {
    bool isRetry = true,
  }) async {
    _cancelTimerResendEvent();

    final isRepeated = await _callService.checkIncomingCallIsRepeated(
          callEvent.id,
          callEvent.to.asString(),
        ) ??
        false;
    if (isRepeated) {
      _logger.i("Repeated Call Event");
    } else {
      timerResendEvent = Timer(const Duration(seconds: 5), () {
        _callEvents[clock.now().millisecondsSinceEpoch] = "Retry Send Event";
        _coreServices.sendCallEvent(callEvent);
        if (timerResendEvent != null && isRetry) {
          _checkRetryCallEvent(callEvent);
          _logger.i("retry send Call Event");
        }
      });
    }
  }

  Future<void> _setCandidate(List<RTCIceCandidate> candidates) async {
    for (final candidate in candidates) {
      try {
        unawaited(_peerConnection!.addCandidate(candidate));
      } catch (e) {
        _logger.e(e);
      }
    }
  }

//Windows memory leak Warning!! https://github.com/flutter-webrtc/flutter-webrtc/issues/752
  Future<void> _dispose() async {
    _logger.i("!!!!Disposed!!!!");
    unawaited(_resetVariables());
    try {
      if (_timerStatReport != null) {
        _timerStatReport!.cancel();
      }
      if (_isAccepted && !_isConnected) {
        await _analyticsService.sendLogEvent(
          "non-connectedCall",
        );
      }
      await cancelCallNotification();
      if (hasSpeakerCapability && _localStream != null) {
        _localStream!.getAudioTracks()[0].enableSpeakerphone(false);
      }
      if (hasForegroundServiceCapability) {
        await _notificationForegroundService.foregroundServiceStop();
        if (settings.localNetworkMessenger.value) {
          await _notificationForegroundService
              .localNetworkForegroundServiceStart();
        }
      }
      if (isAndroidNative) {
        _isNotificationSelected = false;
        modifyRoutingByCallNotificationActionInBackgroundInAndroid.add(null);
        _receivePort?.close();
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
        try {
          var byteSend = 0;
          var byteReceived = 0;
          if (_videoSender != null) {
            final videoSender = await _videoSender!.getStats();
            for (final stat in videoSender) {
              if (stat.type == "transport") {
                _logger.i(stat.values);
                byteSend += stat.values["bytesSent"] as int;
                byteReceived += stat.values["bytesReceived"] as int;
              }
            }
          }
          if (_audioSender != null) {
            final videoSender = await _audioSender!.getStats();
            for (final stat in videoSender) {
              if (stat.type == "transport") {
                _logger.i(stat.values);
                byteSend += stat.values["bytesSent"] as int;
                byteReceived += stat.values["bytesReceived"] as int;
              }
            }
          }
          await _callService.saveCallDataUsage(byteSend, byteReceived);
        } catch (e) {
          _logger.e(e);
        }
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
      _candidate = [];
    } catch (e) {
      _logger.e(e);
    } finally {
      try {
        if (_peerConnection != null) {
          await _peerConnection?.close();
          await _peerConnection?.dispose();
          _peerConnection = null;
        }
      } catch (e) {
        _logger.e(e);
      }

      _roomUid = null;
      //End all Timers
      try {
        _cancelAllTimers();
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
        callTimer.add(CountTimer(0, 0, 0));
        _audioService
          ..turnUpTheCallVolume()
          ..stopCallAudioPlayer();
        _audioToggleOnCall();

        try {
          await _callService.disposeCallData(forceToClearData: true);
          await _callService.clearCallData(
            forceToClearData: true,
            isSaveCallData: true,
          );
          if (isMobileDevice) {
            try {
              await Wakelock.disable();
            } catch (e) {
              _logger.e(e);
            }
          }
        } catch (e) {
          _logger.e(e);
        }

        Timer(const Duration(milliseconds: 100), () async {
          callingStatus.add(CallStatus.NO_CALL);
        });
      });
    }
  }

  Future<void> _resetVariables() async {
    _callEvents[clock.now().millisecondsSinceEpoch] = "Dispose";
    //reset variable valeus
    _offerSdp = "";
    _answerSdp = "";
    _isAccepted = false;
    _isSharing = false;
    _isMicMuted = false;
    _isCaller = false;
    _isOfferReady = false;
    _isDCReceived = false;
    _isAnswerReceived = false;
    _callDuration = 0;
    _startCallTime = 0;
    _callDuration = 0;
    _isCallFromDb = false;
    _notifyIncomingCall = false;
    _callOfferBody = "";
    _callOfferCandidate = "";

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
    incomingAudioMuted.add(false);
    speakingAmplitude.add(0.0);
    incomingSpeakingAmplitude.add(0.0);
    await _phoneStateStream?.cancel();
    isSpeaker.add(false);
  }

  void _cancelAllTimers() {
    if (_timerRinging != null) {
      _timerRinging!.cancel();
    }
    if (timerDisconnected != null) {
      timerDisconnected!.cancel();
    }
    _cancelTimerResendEvent();
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

  void _cancelTimerResendEvent() {
    if (timerResendEvent != null) {
      timerResendEvent!.cancel();
    }
    _logger.i("timerResendEvent: ${timerResendEvent?.isActive}");
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
        CountTimer(
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

  final callingStatus = BehaviorSubject.seeded(CallStatus.NO_CALL);
  final switching = BehaviorSubject.seeded(false);
  final sharing = BehaviorSubject.seeded(false);
  final incomingSharing = BehaviorSubject.seeded(false);
  final videoing = BehaviorSubject.seeded(false);
  final incomingVideo = BehaviorSubject.seeded(false);
  final incomingVideoSwitch = BehaviorSubject.seeded(false);
  final incomingAudioMuted = BehaviorSubject.seeded(false);
  final desktopDualVideo = BehaviorSubject.seeded(true);
  final isSpeaker = BehaviorSubject.seeded(false);
  final incomingCallOnHold = BehaviorSubject.seeded(false);
  final isConnectedSubject = BehaviorSubject.seeded(false);
  final speakingAmplitude = BehaviorSubject.seeded(0.0);
  final incomingSpeakingAmplitude = BehaviorSubject.seeded(0.0);

  Future<void> _increaseCandidateAndWaitingTime() async {
    final candidateNumber = settings.iceCandidateNumbers.value;
    if (candidateNumber <= ICE_CANDIDATE_NUMBER) {
      settings
        ..iceCandidateTimeLimit.set(2000)
        ..iceCandidateNumbers.set(17);
    } else if (candidateNumber <= 17) {
      settings
        ..iceCandidateTimeLimit.set(3000)
        ..iceCandidateNumbers.set(20);
    }
  }

  Future<void> _decreaseCandidateAndWaitingTime() async {
    final candidateNumber = settings.iceCandidateTimeLimit.value;
    if (candidateNumber >= 19) {
      settings
        ..iceCandidateTimeLimit.set(2000)
        ..iceCandidateNumbers.set(17);
    } else if (candidateNumber >= 17) {
      settings
        ..iceCandidateTimeLimit.set(ICE_CANDIDATE_TIME_LIMIT)
        ..iceCandidateNumbers.set(ICE_CANDIDATE_NUMBER);
    }
  }

  void openCallScreen(
    Uid room, {
    bool isVideoCall = false,
  }) {
    if (!_callService.hasCall) {
      _routingService.openCallScreen(
        room,
        isVideoCall: isVideoCall,
      );
    } else {
      if (room == roomUid) {
        _routingService.openCallScreen(
          room,
          isCallInitialized: true,
          isVideoCall: isVideoCall,
        );
      } else {
        showDialog(
          context: settings.appContext,
          builder: (context) => AlertDialog(
            content: Text(
              _i18n.get("you_already_in_call"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(_i18n.get("ok")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  bool inComingAnswerForAnotherSessionCall(CallEvents event) {
    return (isEndingEvent(event.callEvent!) &&
            isCallIdEqualToCurrentCallId(event)) ||
        (event.callEvent!.hasAnswer() &&
            isCallIdEqualToCurrentCallId(event) &&
            event.callEvent!.to.sessionId !=
                _authRepo.currentUserUid.sessionId);
  }

  bool isCallIdEqualToCurrentCallId(CallEvents event) {
    if(event.callEvent!.id == _callService.getCallId) {
      return true;
    }
    if(_handleSynchronousCall())  {
      return true;
    }
    return false;
  }

  bool isEndingEvent(CallEventV2 callEventV2) =>
      callEventV2.hasEnd() || callEventV2.hasBusy() || callEventV2.hasDecline();
}

class Bandwidth {
  final int screen;
  final int audio;
  final int video;

  Bandwidth({
    required this.screen,
    required this.audio,
    required this.video,
  });
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  late final SendPort? sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    sPort = sendPort;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/call-screen");
    sPort?.send('onNotificationPressed');
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    return Future.value();
  }
}
