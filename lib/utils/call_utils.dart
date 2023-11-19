import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class CallUtils {
  static final _logger = GetIt.I.get<Logger>();
  static final _callService = GetIt.I.get<CallService>();

  static Map<String, dynamic> getIceServers() =>
      settings.localNetworkMessenger.value
          ? <String, dynamic>{
              'iceServers': [
                {'url': STUN_SERVER_URL_1}
              ]
            }
          : <String, dynamic>{
              "sdpSemantics": "plan-b", // Add this line
              'iceServers': [
                {'url': STUN_SERVER_URL_1},
                {
                  'url': TURN_SERVER_URL_1,
                  'username': TURN_SERVER_USERNAME_1,
                  'credential': TURN_SERVER_PASSWORD_1,
                },
                {'url': STUN_SERVER_URL_2},
                {
                  'url': TURN_SERVER_URL_2,
                  'username': TURN_SERVER_USERNAME_2,
                  'credential': TURN_SERVER_PASSWORD_2,
                },
                {'url': STUN_SERVER_URL_3},
              ],
            };

  static Map<String, dynamic> getConfig() => <String, dynamic>{
        'mandatory': {},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      };

  static Map<String, dynamic> getSdpConstraints({required bool isVideo}) => {
        "mandatory": {
          "OfferToReceiveAudio": true,
          "OfferToReceiveVideo": isVideo,
          "IceRestart": true,
        },
        "optional": [],
      };

  static Future<MediaStream> getUserMedia({bool isVideo = false}) async {
    // Provide your own width, height and frame rate here
    final VideoCallQualityDetails videoCallQualityDetails;
    if (settings.lowNetworkUsageVideoCall.value) {
      videoCallQualityDetails =
          _callService.getVideoCallQualityDetails(VideoCallQuality.MEDIUM);
    } else {
      videoCallQualityDetails = _callService
          .getVideoCallQualityDetails(settings.videoCallQuality.value);
    }
    Map<String, dynamic> mediaConstraints;

    final Map<String, String> audioConstrains;
    if (!isVideo && settings.highQualityCall.value) {
      audioConstrains = {
        'sampleSize': '24',
        'channelCount': '2',
        'echoCancellation': 'true',
        'latency': '0',
        'noiseSuppression': 'ture',
        'sampleRate': '96000',
      };
    } else if (settings.lowNetworkUsageVoiceCall.value) {
      audioConstrains = {
        'sampleSize': '12',
        'channelCount': '2',
        'sampleRate': '22400',
      };
    } else {
      audioConstrains = {
        'sampleSize': '16',
        'channelCount': '2',
        'echoCancellation': 'true',
        'latency': '0',
        'noiseSuppression': 'ture',
      };
    }
    mediaConstraints = {
      'video': isVideo
          ? {
              'mandatory': {
                'minWidth': videoCallQualityDetails.width.toString(),
                'minHeight': videoCallQualityDetails.height.toString(),
                'maxWidth': videoCallQualityDetails.width.toString(),
                'maxHeight': videoCallQualityDetails.height.toString(),
                'minFrameRate':
                    videoCallQualityDetails.getFrameRate().toString(),
                'maxFrameRate':
                    videoCallQualityDetails.getFrameRate().toString(),
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
      'audio': audioConstrains,
    };

    final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  static Future<MediaStream> getUserDisplay(
      DesktopCapturerSource? source) async {
    if (isDesktopNative) {
      final stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': source == null
            ? true
            : {
                'deviceId': {'exact': source.id},
                'mandatory': {'frameRate': 30.0},
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
}
