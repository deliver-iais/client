// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/dao/bot_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/markup.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart'
    as message_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class BotRepo {
  final _logger = GetIt.I.get<Logger>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _botDao = GetIt.I.get<BotDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _autRepo = GetIt.I.get<AuthRepo>();

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

  Future<CallbackQueryRes?> sendCallbackQuery({
    String data = "",
    int? id,
    required Uid to,
    String? pinCode,
    String? packetId,
  }) async {
    try {
      final callBackQueryResult = await _sdr.botServiceClient.callbackQuery(
        CallbackQueryReq()
          ..id = ""
          ..data = data
          ..bot = to
          ..pinCode = pinCode ?? ""
          ..messageId = Int64(id ?? 0)
          ..messagePacketId = packetId ?? "",
      );
      if (callBackQueryResult.hasText()) {
        if (callBackQueryResult.showAlert) {
          ToastDisplay.showToast(
            showWarningAnimation: callBackQueryResult.isError,
            toastText: callBackQueryResult.text,
          );
        } else {
          //show notification
          GetIt.I.get<NotificationServices>().notifyIncomingMessage(
                message_pb.Message(
                  text: (message_pb.Text()..text = callBackQueryResult.text),
                  id: Int64(id ?? 0),
                  from: to,
                  to: _autRepo.currentUserUid,
                ),
                to.asString(),
              );
        }
      } else if (callBackQueryResult.hasRedirectionUrl()) {
        unawaited(
          GetIt.I.get<UrlHandlerService>().onUrlTap(
                callBackQueryResult.redirectionUrl,
                sendDirectly: true,
              ),
        );
      }
      return callBackQueryResult;
    } catch (e) {
      _logger.e(e);
    }
    return null;
  }

  Future<void> handleInlineMarkUpMessageCallBack(
    Message message,
    InlineKeyboardButton button,
  ) async {
    final urlHandlerService = GetIt.I.get<UrlHandlerService>();

    if (button.hasUrl()) {
      await urlHandlerService.onUrlTap(button.url.url);
    } else if (button.hasCallback()) {
      unawaited(
        sendCallbackQuery(
          data: button.callback.data,
          id: message.id,
          to: message.from.asUid(),
          packetId: message.packetId,
        ),
      );
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
}
