import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart'
    as contact_pb;
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrCode();

  const ScanQrCode({Key? key}) : super(key: key);
}

class _ScanQrCode extends State<ScanQrCode> {
  late QRViewController controller;
  final _logger = GetIt.I.get<Logger>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _routingServices = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  void reassemble() {
    try {
      super.reassemble();
      if (isAndroid) {
        controller.pauseCamera();
      }
      controller.resumeCamera();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final i18n = GetIt.I.get<I18N>();
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.get("scan_qr_code")),
        leading: _routingServices.backButtonLeading(),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: _buildQrView(context),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final theme = Theme.of(context);
    final scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 350.0;

    return QRView(
      key: qrKey,
      overlayMargin: const EdgeInsets.all(24.0).copyWith(bottom: 100),
      onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
      overlay: QrScannerOverlayShape(
          borderColor: theme.primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream
        .map((event) => event.code)
        .distinct()
        .listen((scanData) {
      _parseQrCode(scanData!, context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _parseQrCode(String url, BuildContext context) {
    final uri = Uri.parse(url);

    if (uri.host != APPLICATION_DOMAIN) {
      return;
    }

    final segments =
        uri.pathSegments.where((e) => e != APPLICATION_DOMAIN).toList();

    if (segments.first == "ac") {
      handleAddContact(
          context: context,
          countryCode: uri.queryParameters["cc"],
          nationalNumber: uri.queryParameters["nn"],
          firstName: uri.queryParameters["fn"],
          lastName: uri.queryParameters["ln"]);
    } else if (segments.first == SPDA) {
      handleSendPrivateDateAcceptance(context, uri.queryParameters["type"]!,
          uri.queryParameters["botId"]!, uri.queryParameters["token"]!);
    } else if (segments.first == TEXT) {
      handleSendMsgToBot(
          context, uri.queryParameters["botId"]!, uri.queryParameters["text"]!);
    } else if (segments.first == JOIN) {
      handleJoinUri(context, url);
    } else if (segments.first == LOGIN) {
      handleLogin(context, uri.queryParameters["token"]!);
    }
  }

  Future<void> handleLogin(BuildContext context, String token) async {
    _logger.wtf(token);
    final verified = await _accountRepo.verifyQrCodeToken(token);

    if (verified) {
      Timer(const Duration(milliseconds: 500), () {
        controller.pauseCamera();
        showFloatingModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (ctx) {
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const TGS.asset(
                    'assets/animations/done.tgs',
                    width: 150,
                    height: 150,
                    repeat: false,
                  ));
            });
      });
      Timer(const Duration(seconds: 5), () {
        Navigator.of(context).pop();
        _routingServices.pop();
      });
    }
  }

  Future<void> handleAddContact(
      {String? firstName,
      String? lastName,
      String? countryCode,
      String? nationalNumber,
      required BuildContext context}) async {
    final theme = Theme.of(context);
    final res =
        await _contactRepo.contactIsExist(countryCode!, nationalNumber!);
    if (res) {
      ToastDisplay.showToast(
          toastText:
              "$firstName $lastName ${I18N.of(context)!.get("contact_exist")}",
          toastContext: context);
    } else {
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
                      child: Text(_i18n.get("skip"))),
                  TextButton(
                    onPressed: () async {
                      final newContactAdded = await _contactRepo.sendNewContact(
                          contact_pb.Contact()
                            ..firstName = firstName!
                            ..lastName = lastName!
                            ..phoneNumber = PhoneNumber(
                                countryCode: int.parse(countryCode),
                                nationalNumber:
                                    Int64(int.parse(nationalNumber))));
                      if (newContactAdded) {
                        ToastDisplay.showToast(
                            toastText:
                                "$firstName$lastName ${_i18n.get("contact_add")}",
                            toastContext: context);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(_i18n.get("add_contact")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> handleSendMsgToBot(
      BuildContext context, String botId, String text) async {
    final theme = Theme.of(context);
    controller.pauseCamera();

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
                      controller.resumeCamera();
                      Navigator.of(context).pop();
                    },
                    child: Text(_i18n.get("skip"))),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _routingServices.openRoom(
                      (Uid.create()
                            ..node = botId
                            ..category = Categories.BOT)
                          .asString(),
                    );
                    _messageRepo.sendTextMessage(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        text);
                  },
                  child: Text(_i18n.get("send")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleSendPrivateDateAcceptance(
    BuildContext context,
    String pdType,
    String botId,
    String token,
  ) async {
    controller.pauseCamera();

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
                      controller.resumeCamera();
                      Navigator.of(context).pop();
                    },
                    child: Text(_i18n.get("skip"))),
                TextButton(
                  onPressed: () async {
                    _messageRepo.sendPrivateMessageAccept(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        privateDataType,
                        token);
                    _routingServices.openRoom((Uid.create()
                          ..node = botId
                          ..category = Categories.BOT)
                        .asString());
                    Navigator.of(context).pop();
                  },
                  child: Text(_i18n.get("ok")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
