import 'dart:async';

import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/ws.dart';
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

// TODO(bitbeter): check all possibilities
// TODO(bitbeter): change all links to application domain

//https://wemessenger.ir/text?botId="bdff_bot" & text="/start"
class UrlHandlerService {
  final _mucDao = GetIt.I.get<MucDao>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _logger = GetIt.I.get<Logger>();

  Future<void> onUrlTap(
    String uri, {
    bool openLinkImmediately = false,
    bool sendDirectly = false,
  }) async {
    //add prefix if needed
    if (isApplicationUrl(uri)) {
      handleApplicationUri(
        normalizeApplicationUrl(uri),
        sendDirectly: sendDirectly,
      );
    } else {
      handleNormalLink(
        uri,
        openLinkImmediately: openLinkImmediately,
        sendDirectly: sendDirectly,
      );
    }
  }

  void handleApplicationUri(
    String url, {
    bool shareTextMessage = false,
    bool sendDirectly = false,
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
          countryCode: int.parse(uri.queryParameters["cc"]!),
          nationalNumber: int.parse(uri.queryParameters["nn"]!),
          firstName: uri.queryParameters["fn"],
          lastName: uri.queryParameters["ln"],
        );
      } else if (segments.first == SHARE_PRIVATE_DATA_ACCEPTANCE_URL) {
        handleSendPrivateDateAcceptance(
          uri.queryParameters["type"]!,
          uri.queryParameters["botId"]!,
          uri.queryParameters["token"]!,
        );
      } else if (segments.first == SEND_TEXT_URL) {
        handleSendMsgToBot(
          uri.queryParameters["botId"]!,
          uri.queryParameters["text"]!,
        );
      } else if (segments.first == JOIN_URL) {
        if (segments[1] == "GROUP") {
          handleJoin(
            Uid.create()
              ..node = segments[2]
              ..category = Categories.GROUP,
            segments[3],
          );
        } else if (segments[1] == "CHANNEL") {
          handleJoin(
            Uid.create()
              ..node = segments[2]
              ..category = Categories.CHANNEL,
            segments[3],
          );
        }
      } else if (segments.first == LOGIN_URL) {
        handleLogin(uri.queryParameters["token"]!);
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
        handleIdLink(uri.queryParameters["id"], Categories.GROUP);
      } else if (segments.first == CHANNEL_URL) {
        handleIdLink(uri.queryParameters["id"], Categories.CHANNEL);
      }
    }
  }

  bool isApplicationUrl(String uri) {
    final applicationUrlRegex = RegExp(
      r"^"
      "(https://$APPLICATION_DOMAIN|we:/|$APPLICATION_DOMAIN)"
      r"/(login|spda|text|join|user|channel|group|ac).+$",
    );
    return applicationUrlRegex.hasMatch(uri);
  }

  String normalizeApplicationUrl(String uri) {
    if (uri.startsWith("we://")) {
      return "https://$APPLICATION_DOMAIN${uri.substring(4)}";
    } else {
      return uri;
    }
  }

  Future<void> handleIdLink(
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
        // TODO(any): use i18n
        ToastDisplay.showToast(toastText: "permission denied");
      }
    }
  }

  Future<void> handleLogin(String token) async {
    _logger.wtf(token);
    final verified = await _accountRepo.verifyQrCodeToken(token);

    if (verified) {
      Timer(const Duration(milliseconds: 500), () {
        showFloatingModalBottomSheet(
          context: _uxService.appContext,
          isDismissible: false,
          builder: (ctx) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: const Ws.asset(
                'assets/animations/done.ws',
                width: 150,
                height: 150,
                repeat: false,
              ),
            );
          },
        );
      });
      Timer(const Duration(seconds: 5), () {
        Navigator.of(_uxService.appContext).pop();
        _routingService.pop();
      });
    }
  }

  Future<void> handleAddContact({
    String? firstName,
    String? lastName,
    int? countryCode,
    int? nationalNumber,
  }) async {
    final theme = Theme.of(_uxService.appContext);
    final res =
        await _contactRepo.contactIsExist(countryCode!, nationalNumber!);
    if (res) {
      ToastDisplay.showToast(
        toastText:
            "${buildName(firstName, lastName)} ${_i18n.get("contact_exist")}",
      );
    } else {
      unawaited(
        // ignore: use_build_context_synchronously
        showFloatingModalBottomSheet(
          context: _uxService.appContext,
          builder: (ctx) => Padding(
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
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(_i18n.get("skip")),
                    ),
                    TextButton(
                      onPressed: () async {
                        final navigatorState = Navigator.of(ctx);
                        final contactUid = await _contactRepo.sendNewContact(
                          Contact()
                            ..firstName = firstName!
                            ..lastName = lastName!
                            ..phoneNumber = PhoneNumber(
                              countryCode: countryCode,
                              nationalNumber: Int64(nationalNumber),
                            ),
                        );
                        if (contactUid != null) {
                          ToastDisplay.showToast(
                            toastText: "$firstName$lastName ${_i18n.get(
                              "contact_add",
                            )}",
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
    String botId,
    String text, {
    bool sendDirectly = false,
  }) async {
    final theme = Theme.of(_uxService.appContext);
    if (sendDirectly) {
      _sendMessageToBot(botId, text);
    } else {
      showFloatingModalBottomSheet(
        context: _uxService.appContext,
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
                    onPressed: () {
                      final navigatorState = Navigator.of(context);
                      _sendMessageToBot(botId, text);
                      navigatorState.pop();
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
  }

  void _sendMessageToBot(String botId, String text) {
    _messageRepo.sendTextMessage(
      Uid()
        ..category = Categories.BOT
        ..node = botId,
      text,
    );
    _routingService.openRoom(
      (Uid.create()
            ..node = botId
            ..category = Categories.BOT)
          .asString(),
    );
  }

  Future<void> handleSendPrivateDateAcceptance(
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
      context: _uxService.appContext,
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
                    unawaited(
                      _messageRepo.sendPrivateDataAcceptanceMessage(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        privateDataType,
                        token,
                      ),
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
    Uid roomUid,
    String token, {
    String? name,
  }) async {
    final room = await _roomRepo.getRoom(roomUid.asString());
    if (room != null && !room.deleted) {
      _routingService.openRoom(roomUid.asString());
    } else {
      Future.delayed(Duration.zero, () {
        showFloatingModalBottomSheet(
          context: _uxService.appContext,
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Text(_i18n.get("skip")),
                    ),
                    TextButton(
                      onPressed: () async {
                        final navigatorState = Navigator.of(context);
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
                      },
                      child: Text(_i18n.get("join")),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  void handleNormalLink(
    String uri, {
    bool openLinkImmediately = false,
    bool sendDirectly = false,
  }) {
    final theme = Theme.of(_uxService.appContext);

    if (openLinkImmediately || sendDirectly) {
      launchUrl(Uri.parse(uri));
    } else {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: _uxService.appContext,
          builder: (c) {
            return Directionality(
              textDirection: _i18n.defaultTextDirection,
              child: AlertDialog(
                title: Text(_i18n.get("open_link_title")),
                content: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 330,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      uri,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                VerticalDivider(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.5),
                                ),
                                InkWell(
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.copy),
                                  ),
                                  onTap: () {
                                    saveToClipboard(uri);
                                    Navigator.pop(c);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(_i18n.get("cancel")),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(c);
                      await launchUrl(
                        Uri.parse(uri),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Text(_i18n.get("open")),
                  ),
                ],
              ),
            );
          },
        );
      });
    }
  }
}
