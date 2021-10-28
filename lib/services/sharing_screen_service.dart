import 'dart:convert';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/webRtcKeys.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:logger/logger.dart';

class SharingScreenService {

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
  _initSharingScreen()async{
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

    _localStream = await _getUserMediaDisplay();

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
  _getUserMediaDisplay() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false ,
      'video': true
    };

    var stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);

    onLocalStream?.call(stream);

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
  * For Close DisplayScreen
  * */
  void muteDisplayScreen() {
    if (_localStream != null) {
      bool enabled = _localStream.getVideoTracks()[0].enabled;
      _localStream.getVideoTracks()[0].enabled = !enabled;
    }
  }

  void startShareScreen(Uid roomId){
    sharingStatus.add("startSharScreen");
    _roomUid = roomId;
    _initSharingScreen();
    var offer = _createOffer();
    //Send offer as message to Receiver
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionOffer + offer);
  }

  void receivedSharingScreen(){
    sharingStatus.add("receivedSharingScreen");
    var offerWithoutDetector = _offerSdp.split(webRtcDetectionOffer)[1];
    _setRemoteDescriptionOffer(offerWithoutDetector);
    var answer = _createAnswer();
    // Send Answer back to Sender
    messageRepo.sendTextMessage(_roomUid, webRtcDetectionAnswer + answer);
  }

  void receivedSharingAnswer(String answerSdp){
    var answerWithoutDetector = answerSdp.split(webRtcDetectionAnswer)[1];
    _setRemoteDescriptionAnswer(answerWithoutDetector);
  }

  void receivedSharingCandidate(String answerCandidate){
    var candidateWithoutDetector = answerCandidate.split(webRtcDetectionCandidate)[1];
    List<RTCIceCandidate> candidates = (json.decode(candidateWithoutDetector) as List)
        .map((data) => data)
        .toList();
    _setCandidate(candidates);
  }

  void receivedEndSharing(){
    sharingStatus.add("end");
    _dispose();
  }

  void endSharing(){
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
    await _peerConnection.dispose();

    _candidate = [];
    _roomUid.clear();
    hasSharing.add(null);
    sharingStatus.add(null);
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

  BehaviorSubject<Uid> hasSharing = BehaviorSubject.seeded(null);
  BehaviorSubject<String> sharingStatus = BehaviorSubject.seeded(null);
}