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
  final _urlHandlerService = GetIt.I.get<UrlHandlerService>();
  final MobileScannerController _mobileScannerController =
      MobileScannerController();
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
    return Stack(
      children: [
        MobileScanner(
          controller: _mobileScannerController,
          onDetect: (barcode, args) {
            if (barcode.rawValue != null) {
              _urlHandlerService.handleApplicationUri(
                barcode.rawValue!,
                context,
              );
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Center(
            child: Ws.asset(
              "assets/animations/qr.ws",
              height: MediaQuery.of(context).size.height / 2,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    super.dispose();
  }
}
