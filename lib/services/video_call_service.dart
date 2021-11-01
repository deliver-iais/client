import 'dart:async';
import 'dart:convert';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/webRtcKeys.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';

class VideoCallService {
  var messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();

  MediaStream _localStream;
  MediaStream _localStreamShare;
  RTCRtpSender _audioSender;
  RTCRtpSender _videoSender;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp;
  String _answerSdp;
  String _offerSdpCandidate;

  RTCPeerConnection _peerConnection;
  final String _stunServerURL = "stun:stun.l.google.com:19302";


  int _time;
  bool _onCalling = false;
  bool _isSharing = false;

  Uid _roomUid;
  Uid get roomUid => _roomUid;

  Function(MediaStream stream) onLocalStream;
  Function(MediaStream stream) onAddRemoteStream;
  Function(MediaStream stream) onRemoveRemoteStream;

  /*
  * initial Variable for Render Call Between 2 Client
  * */
  initCall(bool isOffer) async {
    await _createPeerConnection(isOffer).then((pc) {
      _peerConnection = pc;
    });
    _onCalling = true;
  }

  _createPeerConnection(bool isOffer) async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": _stunServerURL},
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
        if(isOffer) {
          _calculateCandidateAndSendOffer();
        }else{
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

    return pc;
  }

  /*
  * get Access from User for Camera and Microphone
  * */
  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth':
              '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

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
    if(!_isSharing) {
      _localStreamShare = await _getUserDisplay();
      var screenVideoTrack = _localStreamShare.getVideoTracks()[0];
      _videoSender.replaceTrack(screenVideoTrack);
      onLocalStream?.call(_localStreamShare);
      _isSharing = true;
    }else{
      var camVideoTrack = _localStream.getVideoTracks()[0];
      _videoSender.replaceTrack(camVideoTrack);
      onLocalStream?.call(_localStream);
      _isSharing = false;
    }
  }

  /*
  * For Close Microphone
  * */
  bool muteMicrophone() {
    if (_localStream != null) {
      bool enabled = _localStream.getAudioTracks()[0].enabled;
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
      _localStream.getVideoTracks()[0].enabled = !enabled;
      return enabled;
    }
    return false;
  }

  void incomingCall(String offerSdpWithCandidate, Uid roomId) {
    if (!_onCalling) {
      callingStatus.add("incomingCall");
      _roomUid = roomId;
      _offerSdpCandidate = offerSdpWithCandidate;
      hasCall.add(roomId);
    } else {
      messageRepo.sendTextMessage(_roomUid, webRtcCallBusied);
      _dispose();
    }
  }

  void startCall(Uid roomId) async {
    _time = DateTime.now().millisecondsSinceEpoch;
    if(!_onCalling) {
      await initCall(true);
      callingStatus.add("startCall");
      //Set Timer 44 sec for end call
      _roomUid = roomId;
      hasCall.add(roomId);
      _offerSdp = await _createOffer();
    }else{
      _logger.i("User on Call ... !");
    }
  }

  void acceptCall(Uid roomId) async {
    _roomUid = roomId;
    callingStatus.add("acceptCall");
    var offerSdpWithCandidateWithoutDetector = _offerSdpCandidate.split(webRtcDetectionOffer)[1];
    var data = jsonDecode(offerSdpWithCandidateWithoutDetector);
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(data['offer']);
    await _setCallCandidate(data['candidate']);
    //CreateAnswer
    _answerSdp = await _createAnswer();
  }

  void declineCall() {
    callingStatus.add("declinedCall");
    messageRepo.sendTextMessage(_roomUid, webRtcCallDeclined);
    _dispose();
  }

  void receivedCallAnswer(String answerSdpWithCandidate) async {

    var answerSdpWithCandidateWithoutDetector = answerSdpWithCandidate.split(webRtcDetectionAnswer)[1];
    var data = jsonDecode(answerSdpWithCandidateWithoutDetector);
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(data['answer']);
    await _setCallCandidate(data['candidate']);

    callingStatus.add("answer");
  }

  _setCallCandidate(String candidatesJson) async {
    List<RTCIceCandidate> candidates =
        (jsonDecode(candidatesJson) as List)
            .map((data) => RTCIceCandidate(
                data['candidate'], data['sdpMid'], data['sdpMlineIndex']))
            .toList();
    await _setCandidate(candidates);
  }

  void receivedBusyCall() {
    callingStatus.add("busy");
    _dispose();
  }

  void receivedDeclinedCall() {
    callingStatus.add("declined");
    _dispose();
  }

  void receivedEndCall() {
    callingStatus.add("end");
    _dispose();
  }

  endCall() async {
    messageRepo.sendTextMessage(_roomUid, webRtcCallEnded);
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

  _calculateCandidateAndSendOffer() async{
    await Future.delayed(Duration(seconds: 3));
    // Send Candidate to Receiver
    var jsonCandidates = jsonEncode(_candidate);
    Map<String, String> offerWithCandidate = {
      "offer" : _offerSdp,
      "candidate": jsonCandidates
    };
    var offerWithCandidateJson = jsonEncode(offerWithCandidate);
    var callTime = DateTime.now().millisecondsSinceEpoch - _time;
    _logger.i("Time For Start Call:" + callTime.toString());
    //Send offer and Candidate as message to Receiver
    messageRepo.sendTextMessage(
        _roomUid, webRtcDetectionOffer + offerWithCandidateJson);
  }

  _calculateCandidateAndSendAnswer() {
    // Send Candidate back to Sender
    var jsonCandidates = jsonEncode(_candidate);
    Map<String, String> answerWithCandidate = {
      "answer" : _answerSdp,
      "candidate": jsonCandidates
    };
    var answerWithCandidateJson = jsonEncode(answerWithCandidate);
    //Send Answer and Candidate as message to Sender
    messageRepo.sendTextMessage(
        _roomUid, webRtcDetectionAnswer + answerWithCandidateJson);
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    candidates.forEach((candidate) async {
      await _peerConnection.addCandidate(candidate);
    });
  }

  _dispose() async {
    await _cleanLocalStream();
    await _peerConnection.dispose();
    _candidate = [];
    _roomUid.clear();
    hasCall.add(null);
    if (callingStatus.value == "declined" || callingStatus.value == "busy") {
      Timer(Duration(seconds: 4), () {
        callingStatus.add(null);
      });
    } else {
      callingStatus.add(null);
    }
    _offerSdp = null;
    bool _onCalling = false;
    bool _isSharing = false;
  }

  _cleanLocalStream() async {
    if (_localStream != null) {
      _localStream.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream.dispose();
      _localStream = null;
    }
  }

  BehaviorSubject<Uid> hasCall = BehaviorSubject.seeded(null);
  BehaviorSubject<String> callingStatus = BehaviorSubject.seeded(null);
}
