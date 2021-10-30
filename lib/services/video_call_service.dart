import 'dart:async';
import 'dart:convert';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/webRtcKeys.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:logger/logger.dart';

class VideoCallService {

  var messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();

  MediaStream _localStream;
  Uid _roomUid ;
  String _offerSdp;
  RTCPeerConnection _peerConnection;
  final String _stunServerURL = "stun:stun.l.google.com:19302";
  List<RTCIceCandidate> _candidate = [];

  Function(MediaStream stream) onLocalStream;
  Function(MediaStream stream) onAddRemoteStream;
  Function(MediaStream stream) onRemoveRemoteStream;


  /*
  * initial Variable for Render Call Between 2 Client
  * */
  initCall()async{
    await _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
  }

  _createPeerConnection() async {
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

    pc.addStream(_localStream);

    pc.onIceConnectionState = (e) {
      _logger.e(e);
    };

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _candidate.add(e);
      }
    };

    pc.onIceGatheringState = (RTCIceGatheringState state) {
      if(state == RTCIceGatheringState.RTCIceGatheringStateComplete){
        _logger.i("onIceGatheringState");
        _calculateCandidate();
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


  void incomingCall(String offerSdp, Uid roomId){
    callingStatus.add("incomingCall");
    if(hasCall.hasValue) {
      _roomUid = roomId;
      _offerSdp = offerSdp;
      hasCall.add(roomId);
    }else{
      messageRepo.sendTextMessage(_roomUid, webRtcCallBusied);
      _dispose();
    }
  }

  void startCall(Uid roomId) async{
    callingStatus.add("startCall");
    //Set Timer 44 sec for end call
    _roomUid = roomId;
    hasCall.add(roomId);
    await initCall();
    var offer = await _createOffer();
    //Send offer as message to Receiver
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionOffer + offer);
  }

  void acceptCall(Uid roomId) async{
    _roomUid = roomId;
    callingStatus.add("acceptCall");
    var offerWithoutDetector = _offerSdp.split(webRtcDetectionOffer)[1];
    await _setRemoteDescriptionOffer(offerWithoutDetector);
    var answer = await _createAnswer();
    // Send Answer back to Sender
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionAnswer + answer);
  }

  void declineCall(){
    callingStatus.add("declinedCall");
    messageRepo.sendTextMessage(_roomUid, webRtcCallDeclined);
    _dispose();
  }

  void receivedCallAnswer(String answerSdp)async{
    var answerWithoutDetector = answerSdp.split(webRtcDetectionAnswer)[1];
    await _setRemoteDescriptionAnswer(answerWithoutDetector);
    callingStatus.add("answer");
  }

  void receivedCallCandidate(String answerCandidate){
    var candidateWithoutDetector = answerCandidate.split(webRtcDetectionCandidate)[1];
    List<RTCIceCandidate> candidates = (json.decode(candidateWithoutDetector) as List)
        .map((data) => data)
        .toList();
    _setCandidate(candidates);
  }

  void receivedBusyCall(){
    callingStatus.add("busy");
    _dispose();
  }

  void receivedDeclinedCall(){
    callingStatus.add("declined");
    _dispose();
  }

  void receivedEndCall(){
    callingStatus.add("end");
    _dispose();
  }

  void endCall(){
    messageRepo.sendTextMessage(_roomUid, webRtcCallEnded);
    _dispose();
  }

  _setRemoteDescriptionOffer(String remoteSdp) async {
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description =
    RTCSessionDescription(sdp, 'offer');

    await _peerConnection.setRemoteDescription(description);
  }

  _setRemoteDescriptionAnswer(String remoteSdp) async {
    dynamic session = await jsonDecode(remoteSdp);

    String sdp = write(session, null);

    RTCSessionDescription description =
    RTCSessionDescription(sdp, 'answer');

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

  _calculateCandidate(){
    // Send Candidate back to Sender
    var jsonCandidates = jsonEncode(_candidate);
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionCandidate + jsonCandidates);
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    candidates.forEach((candidate) async {
      await _peerConnection.addCandidate(candidate);
    });
  }

  _dispose() async{
    await _cleanLocalStream();
    await _peerConnection?.dispose();
    _candidate = [];
    _roomUid?.clear();
    hasCall.add(null);
    if(callingStatus.value=="declined"){
    Timer(Duration(seconds: 3), () {
      callingStatus.add(null);
    });}
    else
      callingStatus.add(null);
    _offerSdp = null;
  }

  _cleanLocalStream() async{
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