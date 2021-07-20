import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
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
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fixnum/fixnum.dart';

import 'functions.dart';

class ScanQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrCode();

  ScanQrCode({Key key}) : super(key: key);
}

class _ScanQrCode extends State<ScanQrCode> {
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var _routingServices = GetIt.I.get<RoutingService>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  String _decodedData = "";
  Map<String, String> _parsedMsg = Map();

  BehaviorSubject<bool> _mucJoinQrCode = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _sendMessageToBotQrCode = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _sendAccessPrivateDataQrCode =
      BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _addContact = BehaviorSubject.seeded(false);

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
      body: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<bool>(
                    stream: _mucJoinQrCode.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data) {
                        handleUri(_decodedData, context);
                        return SizedBox.shrink();
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                StreamBuilder<bool>(
                    stream: _sendMessageToBotQrCode.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data) {
                        handleSendMsgToBot(context);
                        return SizedBox.shrink();
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                StreamBuilder<bool>(
                    stream: _sendAccessPrivateDataQrCode.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data) {
                        handleSendPrivateDateAccestance(context);
                        return SizedBox.shrink();
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                StreamBuilder<bool>(
                    stream: _addContact.stream,
                    builder: (c, s) {
                      if (s.hasData && s.data) {
                        handleAddContact(
                            context: context,
                            countryCode: _parsedMsg["cc"],
                            nationalNumber: _parsedMsg["nn"],
                            firstName: _parsedMsg["fn"],
                            lastName: _parsedMsg["ln"]);
                        return SizedBox.shrink();
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
              ],
            ),
          )
        ],
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
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream
        .map((event) => event.code)
        .distinct()
        .listen((scanData) {
      _parsQrCode(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _parsQrCode(String scanData) {
    Uri uri = Uri.parse(scanData);
    uri.queryParameters.forEach((key, value) {
      _parsedMsg[key] = value;
    });
    List<String> pathSegments = uri.pathSegments;
    _decodedData = scanData;
    if (pathSegments.last.contains("ac")) {
      _addContact.add(true);
    } else if (pathSegments.last.contains("spda")) {
      _sendAccessPrivateDataQrCode.add(true);
    } else if (pathSegments.last.contains("text")) {
      _sendMessageToBotQrCode.add(true);
    } else if (pathSegments[0].contains("join")) {
      _mucJoinQrCode.add(true);
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
      Fluttertoast.showToast(
          msg:
              "$firstName $lastName ${AppLocalization.of(context).getTraslateValue("contact_exist")}");
    } else {
      showFloatingModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AppLocalization.of(context)
                    .getTraslateValue("sure_add_contact"),
                style: TextStyle(
                  color: ExtraTheme.of(context).textField,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // CircleAvatarWidget(, 40,
              //     forceText: fm),
              Text(
                "$firstName$lastName ",
                style: TextStyle(
                    color: ExtraTheme.of(context).username, fontSize: 25),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalization.of(context)
                          .getTraslateValue("skip"))),
                  MaterialButton(
                    color: Colors.blueAccent,
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

  void handleSendMsgToBot(BuildContext context) async {
    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalization.of(context).getTraslateValue("send_msg_to_bot"),
              style: TextStyle(
                color: ExtraTheme.of(context).textField,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "${_parsedMsg["text"]}",
              style: TextStyle(
                  color: ExtraTheme.of(context).username, fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                    color: Colors.blueAccent,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("skip"))),
                MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () async {
                    _messageRepo.sendTextMessage(
                        Uid()
                          ..category = Categories.BOT
                          ..node = _parsedMsg["botId"],
                        _parsedMsg["text"]);
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

  Future<void> handleSendPrivateDateAccestance(BuildContext context) async {
    PrivateDataType privateDataType;
    switch (_parsedMsg["type"]) {
      case "PHONE_NUMBER":
        privateDataType = PrivateDataType.PHONE_NUMBER;
        break;
      case "USERNAME":
        privateDataType = PrivateDataType.USERNAME;
        break;
      case "EMAIL":
        privateDataType = PrivateDataType.EMAIL;
        break;
      case "NAME":
        privateDataType = PrivateDataType.NAME;
        break;
      default:
        privateDataType = PrivateDataType.PHONE_NUMBER;
    }

    showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              AppLocalization.of(context)
                  .getTraslateValue("get_Private_date_access"),
              style: TextStyle(
                color: ExtraTheme.of(context).textField,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "${_parsedMsg["type"]}",
              style: TextStyle(
                  color: ExtraTheme.of(context).username, fontSize: 25),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                    color: Colors.blueAccent,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                        AppLocalization.of(context).getTraslateValue("skip"))),
                MaterialButton(
                  color: Colors.blueAccent,
                  onPressed: () async {
                    _messageRepo.sendPrivateMessageAccept(
                        Uid()
                          ..category = Categories.BOT
                          ..node = _parsedMsg["botId"],
                        privateDataType,
                        _parsedMsg["token"]);
                  },
                  child:
                      Text(AppLocalization.of(context).getTraslateValue("ok")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
