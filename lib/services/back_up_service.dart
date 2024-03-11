import 'dart:async';
import 'package:deliver/services/core_services.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart';
import 'package:get_it/get_it.dart';

class BackUpService {
  static bool isSender(String from, String to) {
    return from.compareTo(to) > 0;
  }

  static Future<void> sendMessage(LocalChatMessage localChatMessage) async {
      final coreServices = GetIt.I.get<CoreServices>();
      await coreServices.sendMessage(localChatMessage.messageByClient, forceToSendToServer: true);
  }
}