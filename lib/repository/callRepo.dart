import 'dart:async';
import 'dart:convert';

import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
  CONNECTED
}

class CallRepo {
  final messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _coreServices = GetIt.I.get<CoreServices>();

  MediaStream _localStream;
  MediaStream _localStreamShare;
  RTCRtpSender _audioSender;
  RTCRtpSender _videoSender;
  RTCDataChannel _dataChannel;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp;
  String _answerSdp;
  String _callId;

  RTCPeerConnection _peerConnection;

  bool _onCalling = false;
  bool _isSharing = false;

  Uid _roomUid;

  Uid get roomUid => _roomUid;

  Function(MediaStream stream) onLocalStream;
  Function(MediaStream stream) onAddRemoteStream;
  Function(MediaStream stream) onRemoveRemoteStream;

  int startCallTime;
  int endCallTime;

  CallRepo() {
    _coreServices.callEvents.listen((event) async {
      switch (event?.callTypes) {
        case CallTypes.Answer:
          _receivedCallAnswer(event.callAnswer);
          break;
        case CallTypes.Offer:
          _receivedCallOffer(event.callOffer);
          break;
        case CallTypes.Event:
          var callEvent = event.callEvent;
          switch (callEvent.newStatus) {
            case CallEvent_CallStatus.IS_RINGING:
              callingStatus.add(CallStatus.IS_RINGING);
              break;
            case CallEvent_CallStatus.CREATED:
              if (!_onCalling) {
                _callId = callEvent.id;
                incomingCall(event.roomUid);
              } else {
                messageRepo.sendCallMessage(
                    CallEvent_CallStatus.BUSY, event.roomUid, callEvent.id, 0);
              }
              break;
            case CallEvent_CallStatus.BUSY:
              receivedBusyCall();
              break;
            case CallEvent_CallStatus.DECLINED:
              receivedDeclinedCall();
              break;
            case CallEvent_CallStatus.ENDED:
              receivedEndCall();
              break;
          }
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
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": STUN_SERVER_URL},
        {
          'url': TURN_SERVER_URL,
          'username': TURN_SERVER_USERNAME,
          'credential': TURN_SERVER_PASSWORD
        },
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    var camVideoTrack = _localStream.getVideoTracks()[0];
    var camAudioTrack = _localStream.getAudioTracks()[0];

    _videoSender = await pc.addTrack(camVideoTrack, _localStream);
    _audioSender = await pc.addTrack(camAudioTrack, _localStream);

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
          _dataChannel.send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTED));
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          //_dataChannel.send(RTCDataChannelMessage(STATUS_CONNECTION_CONNECTING));
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          _dataChannel.send(RTCDataChannelMessage(STATUS_CONNECTION_DISCONNECTED));
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          //_dataChannel.send(RTCDataChannelMessage(STATUS_CONNECTION_FAILED));
          break;
      }
    };

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _candidate.add({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMlineIndex,
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
      _dataChannel = channel;
      _dataChannel.onMessage = (RTCDataChannelMessage data) async {
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
            break;
          case STATUS_CONNECTION_CONNECTING:
            callingStatus.add(CallStatus.CONNECTING);
            break;
        }
      };
    };

    return pc;
  }

  _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 15;

    RTCDataChannel dataChannel = await _peerConnection.createDataChannel(
        "stateTransfer", dataChannelDict);

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
        'video': {
          'mandatory': {
            'minWidth': '640',
            'maxWidth': '720',
            'minHeight': '360',
            'maxHeight': '405',
            'minFrameRate': '15',
            'maxFrameRate': '25',
          },
          'facingMode': 'user',
          'optional': [],
        },
        'audio': {
          'sampleSize': '16',
          'channelCount': '2',
        }
      };
    } else {
      mediaConstraints = {
        'video': {
          'mandatory': {
            'minWidth': '480',
            'maxWidth': '640',
            'minHeight': '270',
            'maxHeight': '360',
            'minFrameRate': '15',
            'maxFrameRate': '25',
          },
          'facingMode': 'user',
          'optional': [],
        },
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

  shareScreen() async {
    if (!_isSharing) {
      _localStreamShare = await _getUserDisplay();
      var screenVideoTrack = _localStreamShare.getVideoTracks()[0];
      _videoSender.replaceTrack(screenVideoTrack);
      onLocalStream?.call(_localStreamShare);
      _isSharing = true;
      _dataChannel.send(RTCDataChannelMessage(STATUS_SHARE_SCREEN));
    } else {
      var camVideoTrack = _localStream.getVideoTracks()[0];
      _videoSender.replaceTrack(camVideoTrack);
      onLocalStream?.call(_localStream);
      _isSharing = false;
      _dataChannel.send(RTCDataChannelMessage(STATUS_SHARE_VIDEO));
    }
  }

  /*
  * For Close Microphone
  * */
  bool muteMicrophone() {
    if (_localStream != null) {
      bool enabled = _localStream.getAudioTracks()[0].enabled;
      if (enabled) {
        _dataChannel.send(RTCDataChannelMessage(STATUS_MIC_CLOSE));
      } else {
        _dataChannel.send(RTCDataChannelMessage(STATUS_MIC_OPEN));
      }
      _localStream.getAudioTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  switchCamera() {
    if (_localStream != null) {
      Helper.switchCamera(_localStream.getVideoTracks()[0]);
    }
  }

  /*
  * For Close Camera
  * */
  bool muteCamera() {
    if (_localStream != null) {
      bool enabled = _localStream.getVideoTracks()[0].enabled;
      if (enabled) {
        _dataChannel.send(RTCDataChannelMessage(STATUS_CAMERA_CLOSE));
      } else {
        _dataChannel.send(RTCDataChannelMessage(STATUS_CAMERA_OPEN));
      }
      _localStream.getVideoTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  void incomingCall(Uid roomId) {
    _onCalling = true;
    _roomUid = roomId;
    callingStatus.add(CallStatus.CREATED);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.IS_RINGING, _roomUid, _callId, 0);
  }

  void startCall(Uid roomId) async {
    if (!_onCalling) {
      await initCall(false);
      callingStatus.add(CallStatus.CREATED);
      //Set Timer 50 sec for end call
      Timer(Duration(seconds: 50), () {
        if (callingStatus.value == CallStatus.IS_RINGING) {
          callingStatus.add(CallStatus.ENDED);
          endCall();
        }
      });
      _roomUid = roomId;
      _onCalling = true;
      _sendStartCallEvent();
    } else {
      _logger.i("User on Call ... !");
    }
  }

  _sendStartCallEvent() {
    _callIdGenerator();
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.CREATED, _roomUid, _callId, 0);
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
    startCallTime = DateTime.now().millisecondsSinceEpoch;
  }

  void declineCall() {
    _logger.i("declineCall");
    callingStatus.add(CallStatus.DECLINED);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.DECLINED, _roomUid, _callId, 0);
    _dispose();
  }

  void _receivedCallAnswer(CallAnswer callAnswer) async {
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(callAnswer.body);
    await _setCallCandidate(callAnswer.candidates);

    callingStatus.add(CallStatus.IN_CALL);
  }

  //here we have accepted Call
  void _receivedCallOffer(CallOffer callOffer) async {
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(callOffer.body);
    await _setCallCandidate(callOffer.candidates);

    //And Create Answer for Calle
    _answerSdp = await _createAnswer();

    callingStatus.add(CallStatus.ACCEPTED);
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
    Timer(Duration(seconds: 4), () {
      callingStatus.add(CallStatus.ENDED);
      _dispose();
    });
  }

  void receivedDeclinedCall() async {
    _logger.i("get declined");
    callingStatus.add(CallStatus.DECLINED);
    Timer(Duration(seconds: 4), () {
      callingStatus.add(CallStatus.ENDED);
      _dispose();
    });
  }

  Future<void> receivedEndCall() async {
    String sessionId = await ConnectycubeFlutterCallKit.getLastCallId();
    ConnectycubeFlutterCallKit.reportCallEnded(sessionId: sessionId);
    ConnectycubeFlutterCallKit.setOnLockScreenVisibility(isVisible: true);
    callingStatus.add(CallStatus.ENDED);
    _dispose();
  }

  endCall() async {
    // endCallTime= DateTime.now().millisecondsSinceEpoch;
    // var time = endCallTime - startCallTime;
    //print(time);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.ENDED, _roomUid, _callId, 0);
    await _dispose();
  }

  _setRemoteDescriptionOffer(String remoteSdp) async {
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description = RTCSessionDescription(sdp, 'offer');

    await _peerConnection.setRemoteDescription(description);
  }

  _setRemoteDescriptionAnswer(String remoteSdp) async {
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description = RTCSessionDescription(sdp, 'answer');

    await _peerConnection.setRemoteDescription(description);
  }

  _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    var answerSdp = json.encode(session);
    _logger.i("Answer: \n" + answerSdp);

    _peerConnection.setLocalDescription(description);

    return answerSdp;
  }

  _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    //get SDP as String
    var session = parse(description.sdp.toString());
    var offerSdp = json.encode(session);
    _logger.i("Offer: \n" + offerSdp);
    _peerConnection.setLocalDescription(description);
    return offerSdp;
  }

  _calculateCandidateAndSendOffer() async {
    //w8 about 3 Sec for received Candidate
    await Future.delayed(Duration(seconds: 3));
    // Send Candidate to Receiver
    var jsonCandidates = jsonEncode(_candidate);
    _logger.i(_candidate.length);
    //Send offer and Candidate as message to Receiver
    var callOfferByClient = (CallOfferByClient()
      ..id = _callId
      ..body = _offerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid);
    _logger.i(_candidate);
    _coreServices.sendCallOffer(callOfferByClient);
  }

  _calculateCandidateAndSendAnswer() async {
    //w8 about 3 Sec for received Candidate
    await Future.delayed(Duration(seconds: 3));
    // Send Candidate back to Sender
    var jsonCandidates = jsonEncode(_candidate);
    //Send Answer and Candidate as message to Sender
    var callAnswerByClient = (CallAnswerByClient()
      ..id = _callId
      ..body = _answerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid);
    _logger.i(_candidate);
    _coreServices.sendCallAnswer(callAnswerByClient);
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    candidates.forEach((candidate) async {
      await _peerConnection.addCandidate(candidate);
    });
  }

  _dispose() async {
    _logger.i("end call in service");
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    await _cleanLocalStream();
    _candidate = [];
    Timer(Duration(seconds: 3), () {
      callingStatus.add(CallStatus.NO_CALL);
    });
    _offerSdp = null;
    _answerSdp = null;
    _callId = null;
    _roomUid = null;
    _onCalling = false;
    _isSharing = false;
  }

  _cleanLocalStream() async {
    if (_localStream != null) {
      _localStream.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream.dispose();
      _localStream = null;
    }
    if (_localStreamShare != null) {
      _localStreamShare.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStreamShare.dispose();
      _localStreamShare = null;
    }
  }

  BehaviorSubject<bool> mute_camera = BehaviorSubject.seeded(true);
  BehaviorSubject<CallStatus> callingStatus =
      BehaviorSubject.seeded(CallStatus.NO_CALL);
}
