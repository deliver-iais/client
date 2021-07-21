import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/shared/floating_modal_bottom_sheet.dart';

import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/contact.pb.dart' as C;
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fixnum/fixnum.dart';

import 'functions.dart';

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
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalization.getTraslateValue("scan_qr_code"),
          style: TextStyle(color: ExtraTheme.of(context).textField),
        ),
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
    }
  }

  Future<void> handleAddContact(
      {String firstName,
      String lastName,
      String countryCode,
      String nationalNumber,
      BuildContext context}) async {
    var res = await _contactRepo.contactIsExist(countryCode, nationalNumber);
    if (!res) {
      Fluttertoast.showToast(
          msg:
              "$firstName $lastName ${AppLocalization.of(context).getTraslateValue("contact_exist")}");
    } else {
      showFloatingModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalization.of(context)
                    .getTraslateValue("sure_add_contact"),
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
                      child: Text(AppLocalization.of(context)
                          .getTraslateValue("skip"))),
                  TextButton(
                    onPressed: () async {
                      var res = await _contactRepo.addContact(C.Contact()
                        ..firstName = firstName
                        ..lastName = lastName
                        ..phoneNumber = PhoneNumber(
                            countryCode: int.parse(countryCode),
                            nationalNumber: Int64(int.parse(nationalNumber))));
                      if (res) {
                        Fluttertoast.showToast(
                            msg:
                                "$firstName$lastName ${AppLocalization.of(context).getTraslateValue("contact_add")}");
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(AppLocalization.of(context)
                        .getTraslateValue("add_contact")),
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
    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "${AppLocalization.of(context).getTraslateValue("send_msg_to")} $botId",
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
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("skip"))),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _routingServices.openRoom((Uid.create()
                          ..node = botId
                          ..category = Categories.BOT)
                        .asString());
                    _messageRepo.sendTextMessage(
                        Uid()
                          ..category = Categories.BOT
                          ..node = botId,
                        text);
                  },
                  child: Text(
                      AppLocalization.of(context).getTraslateValue("send")),
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
    AppLocalization appLocalization = AppLocalization.of(context);
    PrivateDataType privateDataType;
    String type = pdType;
    type.contains("PHONE_NUMBER")
        ? privateDataType = PrivateDataType.PHONE_NUMBER
        : type.contains("USERNAME")
            ? privateDataType = PrivateDataType.USERNAME
            : type.contains("EMAIL")
                ? privateDataType = PrivateDataType.EMAIL
                : privateDataType = PrivateDataType.NAME;

    Future.delayed(Duration.zero, () {
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
                appLocalization.getTraslateValue("get_private_data_access"),
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
                "${appLocalization.getTraslateValue("private_data")} : ${appLocalization.getTraslateValue(privateDataType.name)}",
                style: TextStyle(
                    color: ExtraTheme.of(context).username, fontSize: 25),
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalization.of(context)
                          .getTraslateValue("skip"))),
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
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("ok")),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
