// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BotRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _botDao = GetIt.I.get<BotDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();

  Future<BotInfo> fetchBotInfo(Uid botUid) async {
    final result =
        await _sdr.botServiceClient.getInfo(GetInfoReq()..bot = botUid);
    final botInfo = BotInfo(
      description: result.description,
      uid: botUid.asString(),
      name: result.name,
      commands: result.commands,
      isOwner: result.isOwner,
    );

    unawaited(
      _uidIdNameDao.update(
        botUid.asString(),
        name: result.name,
        id: botUid.node,
      ),
    );

    var name = result.name;

    if (name.isEmpty) {
      name = botUid.node;
    }

    roomNameCache.set(botUid.asString(), name);

    unawaited(_botDao.save(botInfo));

    return botInfo;
  }

  Future<String?> sendCallbackQuery(
    String data,
    Message message,
  ) async {
    try {
      final botUid = message.from.asUid();
      final result = await _sdr.botServiceClient.callbackQuery(
        CallbackQueryReq()
          ..id = botUid.node
          ..data = data
          ..messageId = Int64(message.id ?? 0)
          ..messagePacketId = message.packetId,
      );

      if (result.text.isNotEmpty) {
        if (result.showAlert) {
          //show toast
          return result.text;
        } else {
          //show notification
          GetIt.I.get<NotificationServices>().notifyIncomingMessage(
                message_pb.Message(
                  text: (message_pb.Text()..text = result.text),
                  id: Int64(message.id ?? 0),
                  from: message.from.asUid(),
                  to: message.to.asUid(),
                ),
                botUid.asString(),
              );
        }
      }
      return null;
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }

  Future<void> handleInlineMarkUpMessageCallBack(
    Message message,
    BuildContext context,
    String jsonData,
  ) async {
    final urlHandlerService = GetIt.I.get<UrlHandlerService>();
    final json = jsonDecode(jsonData) as Map;
    final isUrlInlineKeyboardMarkup = json['url'] != null;
    if (isUrlInlineKeyboardMarkup) {
      await urlHandlerService.onUrlTap(
        json['url'],
        context,
      );
    } else if (json['data'] != null) {
      final result = await sendCallbackQuery(
        json['data'],
        message,
      );
      if (result != null) {
        ToastDisplay.showToast(
          toastContext: context,
          toastText: result,
        );
      }
    }
  }

  Future<BotInfo?> getBotInfo(Uid botUid) async {
    try {
      if (!botUid.isBot()) return null;
      final botInfo = await _botDao.get(botUid.asString());
      // TODO(hasan): add lastUpdate field in model and check it later in here!, https://gitlab.iais.co/deliver/wiki/-/issues/415
      if (botInfo != null) {
        return botInfo;
      }
      return await fetchBotInfo(botUid);
    } catch (_) {
      return null;
    }
  }

  Future<List<Uid>> searchBotByName(String name) async {
    if (name.isEmpty) {
      return [];
    }

    //Todo complete search in bot
    // var result = await _botServiceClient.searchByName(SearchByNameReq()..name = name);
    final searchInBots = <Uid>[];
    if (name.contains("father")) {
      final uid = Uid()
        ..category = Categories.BOT
        ..node = "father_bot";
      searchInBots.add(uid);
    }

    _logger.d(searchInBots.toString());
    // for(var bot in result.bot){
    //  searchInBots.add(bot.bot);
    // }
    return searchInBots;
  }
}
