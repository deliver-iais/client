import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rxdart/rxdart.dart';



class ScanQrCode extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ScanQrCode();
  ScanQrCode({Key key}):super(key: key);

}

class _ScanQrCode extends State<ScanQrCode> {

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var _routingServices = GetIt.I.get<RoutingService>();
  
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }
  String _message = "";

  BehaviorSubject<bool> _mucJoinQrCode = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _sendMessageToBotQrCode = BehaviorSubject.seeded(false);
  BehaviorSubject<bool> _sendAccessPrivateDataQrCode = BehaviorSubject.seeded(false);


  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(appLocalization.getTraslateValue("scan_qr_code"),style: TextStyle(color: ExtraTheme.of(context).textField),),leading: _routingServices.backButtonLeading(),),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  StreamBuilder<bool>(stream: _mucJoinQrCode.stream,builder: (c,s){
                    if(s.hasData && s.data){
                      handleUri(_message, context);
                      return SizedBox.shrink();
                    }else{
                      return SizedBox.shrink();
                    }
                  }),
                  StreamBuilder<bool>(stream: _sendMessageToBotQrCode.stream,builder: (c,s){
                    if(s.hasData && s.data){
                   //   handleUri(mucJoinUrl, context);
                      return SizedBox.shrink();
                    }else{
                      return SizedBox.shrink();
                    }
                  }),
                  StreamBuilder<bool>(stream: _sendAccessPrivateDataQrCode.stream,builder: (c,s){
                    if(s.hasData && s.data){
                  //    handleUri(mucJoinUrl, context);
                      return SizedBox.shrink();
                    }else{
                      return SizedBox.shrink();
                    }
                  }),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
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
    controller.scannedDataStream.map((event) => event.code).distinct().listen((scanData) {
      _parsQrCode(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _parsQrCode(String scanData) {
    _message = scanData;
    var m = scanData.split("/");
    if(m[3].toString().contains("join")){
      _mucJoinQrCode.add(true);
    }else if(m[3].contains("text") ){
      _sendMessageToBotQrCode.add(true);
    }else if(m[3].contains("spda")){
      _sendAccessPrivateDataQrCode.add(true);
    }
  }
}