import 'dart:async';
import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/floating_modal_bottom_sheet.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/url.dart';
import 'package:deliver/shared/widgets/tgs.dart';

import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart' as C;
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fixnum/fixnum.dart';

class ScanQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrCode();

  ScanQrCode({Key key}) : super(key: key);
}

class _ScanQrCode extends State<ScanQrCode> {
  QRViewController controller;
  final _logger = GetIt.I.get<Logger>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _routingServices = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.get("scan_qr_code")),
        leading: _routingServices.backButtonLeading(context),
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
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 350.0;

    return QRView(
      key: qrKey,
      overlayMargin: const EdgeInsets.all(24.0).copyWith(bottom: 100),
      onQRViewCreated: (QRViewController controller) =>
          _onQRViewCreated(controller, context),
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
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
      _parseQrCode(scanData, context);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _parseQrCode(String url, BuildContext context) {
    Uri uri = Uri.parse(url);

    if (uri.host != APPLICATION_DOMAIN) {
      return;
    }

    var segments =
        uri.pathSegments.where((e) => e != APPLICATION_DOMAIN).toList();

    if (segments.first == "ac") {
      handleAddContact(
          context: context,
          countryCode: uri.queryParameters["cc"],
          nationalNumber: uri.queryParameters["nn"],
          firstName: uri.queryParameters["fn"],
          lastName: uri.queryParameters["ln"]);
    } else if (segments.first == "spda") {
      handleSendPrivateDateAcceptance(context, uri.queryParameters["type"],
          uri.queryParameters["botId"], uri.queryParameters["token"]);
    } else if (segments.first == "text") {
      handleSendMsgToBot(
          context, uri.queryParameters["botId"], uri.queryParameters["text"]);
    } else if (segments.first == "join") {
      handleJoinUri(context, url);
    } else if (segments.first == "login") {
      handleLogin(context, uri.queryParameters["token"]);
    }
  }

  Future<void> handleLogin(BuildContext context, String token) async {
    _logger.wtf(token);
    bool verified = await _accountRepo.verifyQrCodeToken(token);

    if (verified) {
      Timer(Duration(milliseconds: 500), () {
        controller.pauseCamera();
        showFloatingModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (BuildContext ctx) {
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: TGS.asset(
                    'assets/animations/done.tgs',
                    width: 150,
                    height: 150,
                    repeat: false,
                  ));
            });
      });
      Timer(Duration(seconds: 5), () {
        Navigator.of(context).pop();
        _routingServices.pop();
      });
    }
  }

  Future<void> handleAddContact(
      {String firstName,
      String lastName,
      String countryCode,
      String nationalNumber,
      BuildContext context}) async {
    var res = await _contactRepo.contactIsExist(countryCode, nationalNumber);
    if (res) {
      ToastDisplay.showToast(
          toastText:
              "$firstName $lastName ${I18N.of(context).get("contact_exist")}",
          tostContext: context);
    } else {
      showFloatingModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                I18N.of(context).get("sure_add_contact"),
                style: TextStyle(
                  color: ExtraTheme.of(context).textField,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                buildName(firstName, lastName),
                style: TextStyle(
                    color: ExtraTheme.of(context).username, fontSize: 20),
              ),
              Text(
                buildPhoneNumber(countryCode, nationalNumber),
                style: TextStyle(
                    color: ExtraTheme.of(context).textField, fontSize: 20),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(I18N.of(context).get("skip"))),
                  TextButton(
                    onPressed: () async {
                      var res = await _contactRepo.addContact(C.Contact()
                        ..firstName = firstName
                        ..lastName = lastName
                        ..phoneNumber = PhoneNumber(
                            countryCode: int.parse(countryCode),
                            nationalNumber: Int64(int.parse(nationalNumber))));
                      _contactRepo.getContacts();
                      if (res) {
                        ToastDisplay.showToast(
                            toastText:
                                "$firstName$lastName ${I18N.of(context).get("contact_add")}",
                            tostContext: context);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(I18N.of(context).get("add_contact")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void handleSendMsgToBot(
      BuildContext context, String botId, String text) async {
    controller.pauseCamera();

    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "${I18N.of(context).get("send_msg_to")} $botId",
              style: TextStyle(
                color: ExtraTheme.of(context).textField,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              text,
              style: TextStyle(
                  color: ExtraTheme.of(context).username, fontSize: 25),
            ),
            SizedBox(
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
                    child: Text(I18N.of(context).get("skip"))),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _routingServices.openRoom(
                        (Uid.create()
                              ..node = botId
                              ..category = Categories.BOT)
                            .asString(),
                        context: context);
                    _messageRepo.sendTextMessage(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        text);
                  },
                  child: Text(I18N.of(context).get("send")),
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

    I18N i18n = I18N.of(context);
    PrivateDataType privateDataType;
    String type = pdType;
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
              style: TextStyle(
                color: ExtraTheme.of(context).textField,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            Text(
              i18n.get("get_private_data_access_${privateDataType.name}"),
              style: TextStyle(
                color: ExtraTheme.of(context).textField,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            SizedBox(
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
                    child: Text(I18N.of(context).get("skip"))),
                TextButton(
                  onPressed: () async {
                    _messageRepo.sendPrivateMessageAccept(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        privateDataType,
                        token);
                    _routingServices.openRoom(
                        (Uid.create()
                              ..node = botId
                              ..category = Categories.BOT)
                            .asString(),
                        context: context);
                    Navigator.of(context).pop();
                  },
                  child: Text(I18N.of(context).get("ok")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
