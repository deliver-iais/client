// ignore_for_file: file_names, constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/models/call_timer.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
  CONNECTED,
  DISCONNECTED,
  FAILED
}

class CallRepo {
  final messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _coreServices = GetIt.I.get<CoreServices>();
  late RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCVideoRenderer get getLocalRenderer => _localRenderer;

  RTCVideoRenderer get getRemoteRenderer => _remoteRenderer;

  MediaStream? _localStream;
  MediaStream? _localStreamShare;
  RTCRtpSender? _videoSender;
  RTCRtpSender? _audioSender;
  RTCDataChannel? _dataChannel;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp = "";
  String _answerSdp = "";
  String _callId = "";

  RTCPeerConnection? _peerConnection;
  Map<String, dynamic> _sdpConstraints = {};

  bool _onCalling = false;
  bool _isSharing = false;
  bool _isCaller = false;
  bool _isVideo = false;
  bool _isConnected = false;
  bool _isSpeaker = false;
  bool _isInitRenderer = false;
  bool _isDCRecived = false;

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
  Timer? timerConnectionFailed;
  Timer? timerDisconnected;
  BehaviorSubject<CallTimer> callTimer =
      BehaviorSubject.seeded(CallTimer(0, 0, 0));
  Timer? timer;

  ReceivePort? _receivePort;

  CallRepo() {
    _coreServices.callEvents.listen((event) async {
      switch (event.callType) {
        case CallTypes.Answer:
          callingStatus.add(CallStatus.IN_CALL);
          _receivedCallAnswer(event.callAnswer!);
          break;
        case CallTypes.Offer:
          _receivedCallOffer(event.callOffer!);
          break;
        case CallTypes.Event:
          var callEvent = event.callEvent;
          switch (callEvent!.newStatus) {
            case CallEvent_CallStatus.IS_RINGING:
              callingStatus.add(CallStatus.IS_RINGING);
              break;
            case CallEvent_CallStatus.CREATED:
              if (!_onCalling) {
                _callId = callEvent.id;
                if (callEvent.callType == CallEvent_CallType.VIDEO) {
                  _logger.i("VideoCall");
                  _isVideo = true;
                } else {
                  _isVideo = false;
                }
                incomingCall(event.roomUid!);
              } else {
                messageRepo.sendCallMessage(
                    CallEvent_CallStatus.BUSY,
                    event.roomUid!,
                    callEvent.id,
                    0,
                    _isVideo
                        ? CallEvent_CallType.VIDEO
                        : CallEvent_CallType.AUDIO);
              }
              break;
            case CallEvent_CallStatus.BUSY:
              receivedBusyCall();
              break;
            case CallEvent_CallStatus.DECLINED:
              receivedDeclinedCall();
              break;
            case CallEvent_CallStatus.ENDED:
              receivedEndCall(callEvent.callDuration.toInt());
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
  initCall(bool isOffer) async {
    await _createPeerConnection(isOffer).then((pc) {
      _peerConnection = pc;
    });
  }

  _createPeerConnection(bool isOffer) async {
    Map<String, dynamic> _iceServers = {
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

    final Map<String, dynamic> _config = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ]
    };

    _sdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": _isVideo ? true : false,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc = await createPeerConnection(_iceServers, _config);

    var camAudioTrack = _localStream!.getAudioTracks()[0];
    if (!isWindows()) {
      camAudioTrack.enableSpeakerphone(false);
    }
    _audioSender = await pc.addTrack(camAudioTrack, _localStream!);

    if (_isVideo) {
      var camVideoTrack = _localStream!.getVideoTracks()[0];
      _videoSender = await pc.addTrack(camVideoTrack, _localStream!);
    }

    pc.onIceConnectionState = (e) {
      _logger.i(e);
      // we can do special work on every change in candidate Connection State
      // switch(e){
      //   case RTCIceConnectionState.RTCIceConnectionStateFailed:
      //     break;
      //   case RTCIceConnectionState.RTCIceConnectionStateCompleted:
      //     //The ICE agent has finished gathering candidates, has checked all pairs against one another, and has found a connection for all components.
      //     break;
      //   case RTCIceConnectionState.RTCIceConnectionStateConnected:
      //     //A usable pairing of local and remote candidates has been found for all components of the connection, and the connection has been established. It is possible that gathering is still underway, and it is also possible that the ICE agent is still checking candidates against one another looking for a better connection to use.
      //     break;
      //   case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
      //     break;
      // }
    };

    //https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/connectionState
    pc.onConnectionState = (RTCPeerConnectionState state) async {
      _logger.i(state);
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
          _startCallTimerAndChangeStatus();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          callingStatus.add(CallStatus.DISCONNECTED);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          timerDisconnected = Timer(const Duration(seconds: 5), () {
            if (callingStatus.value == CallStatus.DISCONNECTED) {
              callingStatus.add(CallStatus.ENDED);
              _logger.i("Disconnected and Call End!");
              endCall();
            }
          });
          callingStatus.add(CallStatus.FAILED);
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
    };

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _candidate.add({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex!,
        });
      }
    };

    pc.onIceGatheringState = (RTCIceGatheringState state) {
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
    };

    pc.onAddStream = (stream) {
      _logger.i('addStream: ' + stream.id);
      onAddRemoteStream?.call(stream);
    };

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(stream);
    };

    pc.onDataChannel = (channel) {
      _logger.i("data Channel Received!!");
      _dataChannel = channel;
      _isDCRecived = true;
      //it means Connection is Connected
      _startCallTimerAndChangeStatus();
      _dataChannel!.onMessage = (RTCDataChannelMessage data) async {
        var status = data.text;
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
            _startCallTimerAndChangeStatus();
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

  void _startCallTimerAndChangeStatus() async {
    if (isAndroid()) {
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
    _isConnected = true;
  }

  _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 15;

    RTCDataChannel dataChannel = await _peerConnection!
        .createDataChannel("stateTransfer", dataChannelDict);

    dataChannel.onMessage = (RTCDataChannelMessage data) async {
      var status = data.text;
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
          callingStatus.add(CallStatus.CONNECTED);
          if (!isVideo) startCallTimer();
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
    if (isWindows()) {
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

    var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    onLocalStream?.call(stream);

    return stream;
  }

  _getUserDisplay() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false,
      'video': true
    };

    var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    return stream;
  }

  //https://github.com/flutter-webrtc/flutter-webrtc/issues/831 issue for Android
  //https://github.com/flutter-webrtc/flutter-webrtc/issues/799 issue for Windows
  shareScreen() async {
    if (!_isSharing) {
      _localStreamShare = await _getUserDisplay();
      var screenVideoTrack = _localStreamShare!.getVideoTracks()[0];
      await _videoSender!.replaceTrack(screenVideoTrack);
      onLocalStream?.call(_localStreamShare!);
      _isSharing = true;
      _dataChannel!.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
    } else {
      var camVideoTrack = _localStream!.getVideoTracks()[0];
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
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'endCall', text: 'End Call'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        autoRunOnBoot: true,
        allowWifiLock: true,
      ),
      printDevLog: true,
    );
  }

  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    await FlutterForegroundTask.saveData(key: 'callStatus', value: "Connected");

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

  Future<bool> _stopForegroundTask() async {
    return await FlutterForegroundTask.stopService();
  }

  /*
  * For Close Microphone
  * */
  bool muteMicrophone() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      if (enabled) {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_CLOSE));
      } else {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_MIC_OPEN));
      }
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  bool enableSpeakerVoice() {
    if (_localStream != null) {
      var camAudioTrack = _localStream!.getAudioTracks()[0];
      if (_isSpeaker) {
        camAudioTrack.enableSpeakerphone(false);
      } else {
        camAudioTrack.enableSpeakerphone(true);
      }
      _isSpeaker = !_isSpeaker;
      return _isSpeaker;
    }
    return false;
  }

  switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  /*
  * For Close Camera
  * */
  bool muteCamera() {
    if (_localStream != null) {
      bool enabled = _localStream!.getVideoTracks()[0].enabled;
      if (enabled) {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_CAMERA_CLOSE));
      } else {
        _dataChannel!.send(RTCDataChannelMessage(STATUS_CAMERA_OPEN));
      }
      _localStream!.getVideoTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  void incomingCall(Uid roomId) {
    _onCalling = true;
    _roomUid = roomId;
    callingStatus.add(CallStatus.CREATED);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.IS_RINGING,
        _roomUid!,
        _callId,
        0,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
  }

  startCall(Uid roomId, bool isVideo) async {
    _isCaller = true;
    _isVideo = isVideo;
    if (!_onCalling) {
      _roomUid = roomId;
      _onCalling = true;
      await initCall(false);
      callingStatus.add(CallStatus.CREATED);
      //Set Timer 50 sec for end call
      timerDeclined = Timer(const Duration(seconds: 50), () {
        if (callingStatus.value == CallStatus.IS_RINGING ||
            callingStatus.value == CallStatus.CREATED) {
          callingStatus.add(CallStatus.ENDED);
          _logger.i("User Can't Answer!");
          endCall();
        }
      });
      _sendStartCallEvent();
    } else {
      _logger.i("User on Call ... !");
    }
  }

  _sendStartCallEvent() {
    _callIdGenerator();
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.CREATED,
        _roomUid!,
        _callId,
        0,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
  }

  _callIdGenerator() {
    var random = randomAlphaNumeric(10);
    var time = DateTime.now().millisecondsSinceEpoch;
    //call event id: (Epoch time milliseconds)-(Random String with alphabet and numerics with 10 characters length)
    var callId = time.toString() + "-" + random;
    _callId = callId;
  }

  void acceptCall(Uid roomId) async {
    _roomUid = roomId;
    callingStatus.add(CallStatus.ACCEPTED);
    _dataChannel = await _createDataChannel();
    _offerSdp = await _createOffer();
  }

  void declineCall() {
    _logger.i("declineCall");
    callingStatus.add(CallStatus.DECLINED);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.DECLINED,
        _roomUid!,
        _callId,
        0,
        _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
    _dispose();
  }

  void _receivedCallAnswer(CallAnswer callAnswer) async {
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(callAnswer.body);
    await _setCallCandidate(callAnswer.candidates);
  }

  //here we have accepted Call
  void _receivedCallOffer(CallOffer callOffer) async {
    callingStatus.add(CallStatus.ACCEPTED);
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(callOffer.body);
    await _setCallCandidate(callOffer.candidates);

    //And Create Answer for Calle
    _answerSdp = await _createAnswer();
  }

  _setCallCandidate(String candidatesJson) async {
    List<RTCIceCandidate> candidates = (jsonDecode(candidatesJson) as List)
        .map((data) => RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMlineIndex']))
        .toList();
    await _setCandidate(candidates);
  }

  void receivedBusyCall() {
    callingStatus.add(CallStatus.BUSY);
    Timer(const Duration(seconds: 4), () {
      callingStatus.add(CallStatus.ENDED);
      _dispose();
    });
  }

  void receivedDeclinedCall() async {
    _logger.i("get declined");
    callingStatus.add(CallStatus.DECLINED);
    Timer(const Duration(seconds: 4), () {
      callingStatus.add(CallStatus.ENDED);
      _dispose();
    });
  }

  Future<void> receivedEndCall(int callDuration) async {
    _logger.i("Call Duration Received: " + callDuration.toString());
    String? sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
    ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
    if (_isCaller) {
      _callDuration = calculateCallEndTime();
      _logger.i("Call Duration on Caller(1): " + _callDuration.toString());
      messageRepo.sendCallMessage(
          CallEvent_CallStatus.ENDED,
          _roomUid!,
          _callId,
          _callDuration!,
          _isVideo ? CallEvent_CallType.VIDEO : CallEvent_CallType.AUDIO);
    } else {
      _callDuration = callDuration;
    }
    await _dispose();
  }

  endCall() async {
    if (_isCaller) {
      receivedEndCall(0);
    } else {
      _dataChannel!.send(RTCDataChannelMessage(STATUS_CONNECTION_ENDED));
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
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description = RTCSessionDescription(sdp, 'offer');

    await _peerConnection!.setRemoteDescription(description);
  }

  _setRemoteDescriptionAnswer(String remoteSdp) async {
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');

    await _peerConnection!.setRemoteDescription(description);
  }

  _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer(_sdpConstraints);

    var session = parse(description.sdp.toString());
    var answerSdp = json.encode(session);
    _logger.i("Answer: \n" + answerSdp);

    _peerConnection!.setLocalDescription(description);

    return answerSdp;
  }

  _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer(_sdpConstraints);
    //get SDP as String
    var session = parse(description.sdp.toString());
    var offerSdp = json.encode(session);
    _logger.i("Offer: \n" + offerSdp);
    _peerConnection!.setLocalDescription(description);
    return offerSdp;
  }

  _calculateCandidateAndSendOffer() async {
    //w8 about 3 Sec for received Candidate
    await Future.delayed(const Duration(seconds: 3));
    // Send Candidate to Receiver
    var jsonCandidates = jsonEncode(_candidate);
    //Send offer and Candidate as message to Receiver
    var callOfferByClient = (CallOfferByClient()
      ..id = _callId
      ..body = _offerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallOffer(callOfferByClient);
  }

  _calculateCandidateAndSendAnswer() async {
    //w8 about 3 Sec for received Candidate
    await Future.delayed(const Duration(seconds: 3));
    // Send Candidate back to Sender
    var jsonCandidates = jsonEncode(_candidate);
    //Send Answer and Candidate as message to Sender
    var callAnswerByClient = (CallAnswerByClient()
      ..id = _callId
      ..body = _answerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid!);
    _logger.i(_candidate);
    _coreServices.sendCallAnswer(callAnswerByClient);
    callingStatus.add(CallStatus.IN_CALL);
    //Set Timer 30 sec for end call if Call doesn't Connected
    timerConnectionFailed = Timer(const Duration(seconds: 30), () {
      if (callingStatus.value != CallStatus.CONNECTED) {
        _logger.i("Call Can't Connected !!");
        callingStatus.add(CallStatus.ENDED);
        endCall();
      }
    });
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    for (var candidate in candidates) {
      await _peerConnection!.addCandidate(candidate);
    }
  }

  //Windows memory leak Warning!! https://github.com/flutter-webrtc/flutter-webrtc/issues/752
  _dispose() async {
    if (isAndroid()) {
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
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    _candidate = [];
    callingStatus.add(CallStatus.ENDED);
    Timer(const Duration(seconds: 2), () {
      callingStatus.add(CallStatus.NO_CALL);
    });
    _offerSdp = "";
    _answerSdp = "";
    _callId = "";
    _roomUid = null;
    _onCalling = false;
    _isSharing = false;
    _isCaller = false;
    _isVideo = false;
    _isConnected = false;
    _callDuration = 0;
    _startCallTime = 0;
    _callDuration = 0;
    _sdpConstraints = {};
    callTimer.add(CallTimer(0, 0, 0));
  }

  initRenderer() async {
    if (!_isInitRenderer) {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      _logger.i("Initialize Renderers");
      _isInitRenderer = true;
    }
  }

  disposeRenderer() async {
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

  startCallTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer timer) {
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
}

// The callback function should always be a top-level function.
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  late final callStatus;
  late final sPort;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // You can use the getData function to get the data you saved.
    callStatus = await FlutterForegroundTask.getData<String>(key: 'callStatus');
    sPort = sendPort;
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    sendPort?.send(callStatus);
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
