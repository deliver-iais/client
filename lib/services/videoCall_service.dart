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
  bool sharingScreen;
  Uid _roomUid ;
  String _offerSdp;
  RTCPeerConnection _peerConnection;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  final String _stunServerURL = "stun:stun.l.google.com:19302";
  List<String> _candidate = [];

  /*
  * initial Variable for Render Call Between 2 Client
  * */
  _initCall()async{
    _initRenderer();
    await _createPeerConnection().then((pc) {
      _peerConnection = pc;
    });
  }

  _initRenderer() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
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

    _localStream = await _getUserMedia(sharingScreen);

    RTCPeerConnection pc =
    await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream);

    pc.onIceConnectionState = (e) {
      _logger.e(e);
    };

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        _candidate.add(e.toString());
      }
    };

    pc.onIceGatheringState = (RTCIceGatheringState state) {
      if(state == RTCIceGatheringState.RTCIceGatheringStateComplete){
        _calculateCandidate();
      }
    };

    pc.onAddStream = (stream) {
      _logger.i('addStream: ' + stream.id);
      _remoteRenderer.srcObject = stream;
    };

    return pc;
  }

  /*
  * get Access from User for Camera and Microphone
  * */
  _getUserMedia(bool screenSharing) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': screenSharing ? false : true,
      'video': screenSharing
          ? true
          : {
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

    var stream = screenSharing
        ? await navigator.mediaDevices.getDisplayMedia(mediaConstraints)
        : await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = stream;

    return stream;
  }

  /*
  * For Close Microphone
  * */
  void muteMicrophone() {
    if (_localStream != null) {
      bool enabled = _localStream.getAudioTracks()[0].enabled;
      _localStream.getAudioTracks()[0].enabled = !enabled;
    }
  }

  /*
  * For Close Camera
  * */
  void muteCamera() {
    if (_localStream != null) {
      bool enabled = _localStream.getVideoTracks()[0].enabled;
      _localStream.getVideoTracks()[0].enabled = !enabled;
    }
  }


  void incomingCall(String offerSdp, Uid roomId){
    statusCall.add("incomingCall");
    if(!hasCall.hasValue) {
      _roomUid = roomId;
      _offerSdp = offerSdp;
      hasCall.add(roomId);
    }else{
      messageRepo.sendTextMessage(_roomUid, webRtcCallBusied);
      _dispose();
    }
  }

  void startShareScreen(Uid roomId){
    statusCall.add("startSharScreen");
    sharingScreen = true;
    _roomUid = roomId;
    _initCall();
    var offer = _createOffer();
    //Send offer as message to Receiver
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionOffer + offer);
  }

  void startCall(Uid roomId) async{
    statusCall.add("startCall");
    //Set Timer 44 sec for end call
    sharingScreen = false;
    _roomUid = roomId;
    hasCall.add(roomId);
    await _initCall();
    var offer = _createOffer();
    //Send offer as message to Receiver
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionOffer + offer.toString());
  }

  void acceptCall(){
    statusCall.add("acceptCall");
    var offerWithoutDetector = _offerSdp.split(webRtcDetectionOffer)[1];
    _setRemoteDescriptionOffer(offerWithoutDetector);
    var answer = _createAnswer();
    // Send Answer back to Sender
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionAnswer + answer);
  }

  void declineCall(){
    statusCall.add("declinedCall");
    messageRepo.sendTextMessage(_roomUid, webRtcCallDeclined);
    _dispose();
  }

  void receivedCallAnswer(String answerSdp){
    var answerWithoutDetector = answerSdp.split(webRtcDetectionAnswer)[1];
    _setRemoteDescriptionAnswer(answerWithoutDetector);
  }

  void receivedCallCandidate(String answerCandidate){
    var candidateWithoutDetector = answerCandidate.split(webRtcDetectionCandidate)[1];
    List<String> candidates = (json.decode(candidateWithoutDetector) as List)
        .map((data) => data)
        .toList();
    _setCandidate(candidates);
  }

  void receivedBusyCall(){
    statusCall.add("busy");
    _dispose();
  }

  void receivedDeclinedCall(){
    statusCall.add("declined");
    _dispose();
  }

  void receivedEndCall(){
    statusCall.add("end");
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

  _setCandidate(List<String> candidates) async {
    candidates.forEach((element) async {
      dynamic session = await jsonDecode(element);
      print(session['candidate']);
      dynamic candidate = RTCIceCandidate(
          session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
      await _peerConnection.addCandidate(candidate);
    });
  }

  _dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.dispose();
    _candidate = [];
    _localStream.dispose();
    _roomUid.clear();
    hasCall.add(null);
    statusCall.add(null);
    _offerSdp = null;
  }

  RTCVideoRenderer getLocalRenderer(){
    return _localRenderer;
  }

  RTCVideoRenderer getRemoteRenderer(){
    return _remoteRenderer;
  }

  BehaviorSubject<Uid> hasCall = BehaviorSubject.seeded(null);
  BehaviorSubject<String> statusCall = BehaviorSubject.seeded(null);
}