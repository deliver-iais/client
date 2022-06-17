import 'package:deliver/localization/i18n.dart';
import 'package:deliver/main.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/core.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConnectionSettingPage extends StatefulWidget {
  const ConnectionSettingPage({Key? key}) : super(key: key);

  @override
  State<ConnectionSettingPage> createState() => _ConnectionSettingPageState();
}

class _ConnectionSettingPageState extends State<ConnectionSettingPage> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.get("connection_setting")),
      ),
      body: Section(
        children: [
          SettingsTile.switchTile(
            title: _i18n.get("connect_on_bad_certificate"),
            leading: const Icon(CupertinoIcons.settings),
            switchValue: badCertificateConnection,
            onToggle: (value) => setState(() {
              setCertificate(onBadCertificate: value);
             GetIt.I.unregister<CoreServiceClient>();
             GetIt.I.registerSingleton<CoreServiceClient>(CoreServiceClient(
               isWeb ? webCoreServicesClientChannel : CoreServicesClientChannel2,
             ),);
              final _grpcCoreService = GetIt.I.get<CoreServiceClient>();
              print(_grpcCoreService);
            }),
          ),
        ],
      ),
    );
  }
}
