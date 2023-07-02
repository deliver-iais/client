import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrCode extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQrCode();

  const ScanQrCode({super.key});
}

class _ScanQrCode extends State<ScanQrCode> {
  bool enable = true;
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final MobileScannerController _mobileScannerController =
      MobileScannerController(detectionTimeoutMs: 500);
  final _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    final i18n = GetIt.I.get<I18N>();
    return Scaffold(
      appBar: AppBar(
        title: Text(i18n.get("scan_qr_code")),
        leading: _routingServices.backButtonLeading(),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: _buildQrView(context),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final pageSize = MediaQuery.of(context).size;

    final size = min(pageSize.width, pageSize.height) * 0.95;

    return Stack(
      children: [
        MobileScanner(
          controller: _mobileScannerController,
          onDetect: (b) {
            for (final barcode in b.barcodes) {
              final uri = barcode.rawValue;
              if (uri != null && UrlHandlerService.isApplicationUrl(uri)) {
                stop();
                _urlHandlerService.handleApplicationUri(uri);
                break;
              }
            }
          },
        ),
        if (enable)
          Center(
            child: Ws.asset(
              "assets/animations/particles.ws",
              height: size,
              width: size,
            ),
          ),
      ],
    );
  }

  void stop() {
    _routingServices.pop();
    _mobileScannerController.stop();
    setState(() {
      enable = false;
    });
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    super.dispose();
  }
}
