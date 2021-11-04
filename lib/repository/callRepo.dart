import 'dart:async';
import 'dart:convert';

import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdp_transform/sdp_transform.dart';

enum CallStatus {
  CREATED , IS_RINGING , DECLINED , BUSY , ENDED , NO_CALL , ACCEPTED , IN_CALL
}

class CallRepo {

  final messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _coreServices = GetIt.I.get<CoreServices>();

  MediaStream _localStream;
  MediaStream _localStreamShare;
  RTCRtpSender _audioSender;
  RTCRtpSender _videoSender;
  List<Map<String, Object>> _candidate = [];

  String _offerSdp;
  String _answerSdp;
  String _callId;

  RTCPeerConnection _peerConnection;
  final String _stunServerURL = "stun:stun.l.google.com:19302";


  bool _onCalling = false;
  bool _isSharing = false;

  Uid _roomUid;
  Uid get roomUid => _roomUid;

  Function(MediaStream stream) onLocalStream;
  Function(MediaStream stream) onAddRemoteStream;
  Function(MediaStream stream) onRemoveRemoteStream;


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
              if(!_onCalling) {
                _callId = callEvent.id;
                incomingCall(event.roomUid);
              }else{
                messageRepo.sendCallMessage(
                    CallEvent_CallStatus.BUSY, event.roomUid,
                    callEvent.id);
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
          '960', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '45',
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

  void incomingCall(Uid roomId) {
    _onCalling = true;
    _roomUid = roomId;
    callingStatus.add(CallStatus.CREATED);
    messageRepo.sendCallMessage(
        CallEvent_CallStatus.IS_RINGING, _roomUid,
        _callId);
  }

  void startCall(Uid roomId) async {
    if(!_onCalling) {
      await initCall(false);
      callingStatus.add(CallStatus.CREATED);
      //Set Timer 44 sec for end call
      Timer(Duration(seconds: 44), () {
        callingStatus.add(CallStatus.ENDED);
        endCall();
      });
      _roomUid = roomId;
      _onCalling = true;
      _sendStartCallEvent();
    }else{
      _logger.i("User on Call ... !");
    }
  }

  _sendStartCallEvent(){
    _callIdGenerator();
    messageRepo.sendCallMessage(CallEvent_CallStatus.CREATED, _roomUid, _callId);
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
    _offerSdp = await _createOffer();
  }

  void declineCall() {
    callingStatus.add(CallStatus.DECLINED);
    messageRepo.sendCallMessage(CallEvent_CallStatus.DECLINED, _roomUid, _callId);
    _dispose();
  }

  void _receivedCallAnswer(CallAnswer callAnswer) async {

    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionAnswer(callAnswer.body);
    await _setCallCandidate(callAnswer.candidates);

    callingStatus.add(CallStatus.IN_CALL);
  }

  void _receivedCallOffer(CallOffer callOffer) async {
    //set Remote Descriptions and Candidate
    await _setRemoteDescriptionOffer(callOffer.body);
    await _setCallCandidate(callOffer.candidates);

    //And Create Answer for Calle
    _answerSdp = await _createAnswer();

    callingStatus.add(CallStatus.ACCEPTED);
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
    callingStatus.add(CallStatus.BUSY);
    _dispose();
  }

  void receivedDeclinedCall() {
    _logger.i("get declined");
    callingStatus.add(CallStatus.DECLINED);
    _dispose();
  }

  void receivedEndCall() {
    callingStatus.add(CallStatus.ENDED);
    _dispose();
  }

  endCall() async {
    messageRepo.sendCallMessage(CallEvent_CallStatus.ENDED, _roomUid, _callId);
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
    //w8 about 3 Sec for received Candidate
    await Future.delayed(Duration(seconds: 3));
    // Send Candidate to Receiver
    var jsonCandidates = jsonEncode(_candidate);
    //Send offer and Candidate as message to Receiver
    var callOfferByClient = (CallOfferByClient()
      ..id = _callId
      ..body = _offerSdp
      ..candidates = jsonCandidates
      ..to = _roomUid);
    _coreServices.sendCallOffer(callOfferByClient);
  }

  _calculateCandidateAndSendAnswer() async{
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
    _coreServices.sendCallAnswer(callAnswerByClient);
  }

  _setCandidate(List<RTCIceCandidate> candidates) async {
    candidates.forEach((candidate) async {
      await _peerConnection.addCandidate(candidate);
    });
  }

  _dispose() async {
    _logger.i("end call in service");
    await _cleanLocalStream();
    await _peerConnection?.dispose();
    _candidate = [];
    if (callingStatus.value == CallStatus.DECLINED || callingStatus.value == CallStatus.BUSY) {
      Timer(Duration(seconds: 4), () {
        callingStatus.add(CallStatus.ENDED);
      });
    }
    Timer(Duration(seconds: 2), () {
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
  }

  BehaviorSubject<CallStatus> callingStatus = BehaviorSubject.seeded(CallStatus.NO_CALL);
}
