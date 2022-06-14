import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrCode();

  const ScanQrCode({Key? key}) : super(key: key);
}

class _ScanQrCode extends State<ScanQrCode> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final _routingServices = GetIt.I.get<RoutingService>();

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
        cutOutSize: scanArea,
      ),
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
      UrlHandler()
          .handleApplicationUri(scanData!, context, controller: controller);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
