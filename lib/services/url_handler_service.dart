import 'dart:async';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

String buildShareUserUrl(
  int countryCode,
  int nationalNumber,
  String firstName,
  String lastName,
) =>
    "https://$APPLICATION_DOMAIN/ac?cc=$countryCode&nn=$nationalNumber&fn=$firstName&ln=$lastName";

String buildInviteLinkForBot(String botId) =>
    "https://$APPLICATION_DOMAIN/text?botId=$botId&text=/start";

//https://wemessenger.ir/text?botId="bdff_bot" & text="/start"
class UrlHandlerService {
  final _mucDao = GetIt.I.get<MucDao>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _logger = GetIt.I.get<Logger>();

  void handleApplicationUri(
    String url,
    BuildContext context, {
    bool shareTextMessage = false,
  }) {
    if (shareTextMessage && !url.contains(APPLICATION_DOMAIN)) {
      _routingService.openShareInput(text: url);
    } else {
      final uri = Uri.parse(url);

      if (uri.host != APPLICATION_DOMAIN) {
        return;
      }

      final segments =
          uri.pathSegments.where((e) => e != APPLICATION_DOMAIN).toList();

      if (segments.first == ADD_CONTACT_URL) {
        handleAddContact(
          context: context,
          countryCode: int.parse(uri.queryParameters["cc"]!),
          nationalNumber: int.parse(uri.queryParameters["nn"]!),
          firstName: uri.queryParameters["fn"],
          lastName: uri.queryParameters["ln"],
        );
      } else if (segments.first == SHARE_PRIVATE_DATA_ACCEPTANCE_URL) {
        handleSendPrivateDateAcceptance(
          context,
          uri.queryParameters["type"]!,
          uri.queryParameters["botId"]!,
          uri.queryParameters["token"]!,
        );
      } else if (segments.first == SEND_TEXT_URL) {
        handleSendMsgToBot(
          context,
          uri.queryParameters["botId"]!,
          uri.queryParameters["text"]!,
        );
      } else if (segments.first == JOIN_URL) {
        if (segments[1] == "GROUP") {
          handleJoin(
            context,
            Uid.create()
              ..node = segments[2]
              ..category = Categories.GROUP,
            segments[3],
          );
        } else if (segments[1] == "CHANNEL") {
          handleJoin(
            context,
            Uid.create()
              ..node = segments[2]
              ..category = Categories.CHANNEL,
            segments[3],
          );
        }
      } else if (segments.first == LOGIN_URL) {
        handleLogin(context, uri.queryParameters["token"]!);
      } else if (segments.first == USER_URL) {
        if (uri.queryParameters["id"] != null) {
          _routingService.openRoom(
            (Uid.create()
                  ..node = uri.queryParameters["id"]!
                  ..category = Categories.USER)
                .asString(),
          );
        }
      } else if (segments.first == GROUP_URL) {
        handleIdLink(context, uri.queryParameters["id"], Categories.GROUP);
      } else if (segments.first == CHANNEL_URL) {
        handleIdLink(context, uri.queryParameters["id"], Categories.CHANNEL);
      }
    }
  }

  Future<void> handleIdLink(
    BuildContext context,
    String? node,
    Categories category,
  ) async {
    if (node != null) {
      final roomUid = (Uid.create()
            ..node = node
            ..category = category)
          .asString();
      final muc = await _mucDao.get(roomUid);
      if (muc != null) {
        _routingService.openRoom(
          roomUid,
        );
      } else {
        ToastDisplay.showToast(
          toastContext: context,
          toastText: "permission denied",
        );
      }
    }
  }

  Future<void> handleLogin(
    BuildContext context,
    String token,
  ) async {
    _logger.wtf(token);
    final verified = await _accountRepo.verifyQrCodeToken(token);

    if (verified) {
      Timer(const Duration(milliseconds: 500), () {
        showFloatingModalBottomSheet(
          context: context,
          isDismissible: false,
          builder: (ctx) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Tgs.asset(
                'assets/animations/done.tgs',
                width: 150,
                height: 150,
                repeat: false,
              ),
            );
          },
        );
      });
      Timer(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
        _routingService.pop();
      });
    }
  }

  Future<void> handleAddContact({
    String? firstName,
    String? lastName,
    int? countryCode,
    int? nationalNumber,
    required BuildContext context,
  }) async {
    final theme = Theme.of(context);
    final res =
        await _contactRepo.contactIsExist(countryCode!, nationalNumber!);
    if (res) {
      ToastDisplay.showToast(
        toastText:
            "${buildName(firstName, lastName)} ${_i18n.get("contact_exist")}",
        toastContext: context,
      );
    } else {
      unawaited(
        showFloatingModalBottomSheet(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _i18n.get("sure_add_contact"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  buildName(firstName, lastName),
                  style: TextStyle(color: theme.primaryColor, fontSize: 20),
                ),
                Text(
                  buildPhoneNumber(countryCode, nationalNumber),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_i18n.get("skip")),
                    ),
                    TextButton(
                      onPressed: () async {
                        final navigatorState = Navigator.of(context);
                        final newContactAdded =
                            await _contactRepo.sendNewContact(
                          Contact()
                            ..firstName = firstName!
                            ..lastName = lastName!
                            ..phoneNumber = PhoneNumber(
                              countryCode: countryCode,
                              nationalNumber: Int64(nationalNumber),
                            ),
                        );
                        if (newContactAdded) {
                          ToastDisplay.showToast(
                            toastText:
                                "$firstName$lastName ${_i18n.get("contact_add")}",
                            toastContext: context,
                          );
                          navigatorState.pop();
                        }
                      },
                      child: Text(_i18n.get("add_contact")),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> handleSendMsgToBot(
    BuildContext context,
    String botId,
    String text,
  ) async {
    final theme = Theme.of(context);

    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "${_i18n.get("send_msg_to")} $botId",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              text,
              style: TextStyle(color: theme.primaryColor, fontSize: 25),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(_i18n.get("skip")),
                ),
                TextButton(
                  onPressed: () async {
                    final navigatorState = Navigator.of(context);
                    await _messageRepo.sendTextMessage(
                      Uid()
                        ..category = Categories.BOT
                        ..node = botId,
                      text,
                    );
                    navigatorState.pop();
                    _routingService.openRoom(
                      (Uid.create()
                            ..node = botId
                            ..category = Categories.BOT)
                          .asString(),
                    );
                  },
                  child: Text(_i18n.get("send")),
                ),
              ],
            ),
          ],
        ),
      ),
    ).ignore();
  }

  Future<void> handleSendPrivateDateAcceptance(
    BuildContext context,
    String pdType,
    String botId,
    String token,
  ) async {
    PrivateDataType privateDataType;
    final type = pdType;
    type.contains("PHONE_NUMBER")
        ? privateDataType = PrivateDataType.PHONE_NUMBER
        : type.contains("USERNAME")
            ? privateDataType = PrivateDataType.USERNAME
            : type.contains("EMAIL")
                ? privateDataType = PrivateDataType.EMAIL
                : privateDataType = PrivateDataType.NAME;

    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              botId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            Text(
              _i18n.get("get_private_data_access_${privateDataType.name}"),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(_i18n.get("skip")),
                ),
                TextButton(
                  onPressed: () async {
                    final navigatorState = Navigator.of(context);
                    await _messageRepo.sendPrivateDataAcceptanceMessage(
                      Uid()
                        ..category = Categories.BOT
                        ..node = botId,
                      privateDataType,
                      token,
                    );
                    navigatorState.pop();
                    _routingService.openRoom(
                      (Uid.create()
                            ..node = botId
                            ..category = Categories.BOT)
                          .asString(),
                    );
                  },
                  child: Text(_i18n.get("ok")),
                ),
              ],
            ),
          ],
        ),
      ),
    ).ignore();
  }

  Future<void> handleJoin(
    BuildContext context,
    Uid roomUid,
    String token, {
    String? name,
  }) async {
    final muc = await _mucDao.get(roomUid.asString());
    if (muc != null) {
      _routingService.openRoom(roomUid.asString());
    } else {
      Future.delayed(Duration.zero, () {
        showFloatingModalBottomSheet(
          context: context,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatarWidget(
                  roomUid,
                  40,
                  forceText: name ?? "",
                ),
                if (name != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_i18n.get("skip")),
                    ),
                    MaterialButton(
                      onPressed: () async {
                        final navigatorState = Navigator.of(context);
                        if ((roomUid.category == Categories.GROUP ||
                            roomUid.category == Categories.CHANNEL)) {
                          final muc = await _mucRepo.getMuc(roomUid.asString());
                          if (muc == null) {
                            if (roomUid.category == Categories.GROUP) {
                              final res = await _mucRepo.joinGroup(
                                roomUid,
                                token,
                              );
                              if (res != null) {
                                navigatorState.pop();
                                _routingService.openRoom(roomUid.asString());
                              }
                            } else {
                              final res = await _mucRepo.joinChannel(
                                roomUid,
                                token,
                              );
                              if (res != null) {
                                navigatorState.pop();
                                _routingService.openRoom(roomUid.asString());
                              }
                            }
                          } else {
                            _routingService.openRoom(roomUid.asString());
                          }
                        } else {
                          _routingService.openRoom(roomUid.asString());
                        }
                      },
                      child: Text(_i18n.get("join")),
                    )
                  ],
                ),
              ],
            ),
          ),
        ).ignore();
      });
    }
  }

  void handleNormalLink(String uri, BuildContext context) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) {
          return AlertDialog(
            content: Text(
              "Do you want to open the\n$uri",
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                },
                child: Text(_i18n.get("cancel")),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(c);
                  await launchUrl(Uri.parse(uri));
                },
                child: Text(_i18n.get("open")),
              ),
            ],
          );
        },
      );
    });
  }
}
