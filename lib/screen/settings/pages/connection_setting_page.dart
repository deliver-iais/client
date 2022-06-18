import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionSettingPage extends StatefulWidget {
  const ConnectionSettingPage({Key? key}) : super(key: key);

  @override
  State<ConnectionSettingPage> createState() => _ConnectionSettingPageState();
}

class _ConnectionSettingPageState extends State<ConnectionSettingPage> {
  final _i18n = GetIt.I.get<I18N>();
  final _servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();
  final TextEditingController _textEditingController = TextEditingController();
  final _shareDao = GetIt.I.get<SharedDao>();
  final BehaviorSubject<bool> _roomIsSet = BehaviorSubject.seeded(false);

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
            switchValue: _servicesDiscoveryRepo.badCertificateConnection,
            onToggle: (value) => setState(() {
              _servicesDiscoveryRepo.setCertificate(onBadCertificate: value);
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<String?>(
            future: _shareDao.get(SHARE_DAO_HOST_SET_BY_USER),
            builder: (c, ipSnapshot) {
              _roomIsSet
                  .add(ipSnapshot.data != null && ipSnapshot.data!.isNotEmpty);
              return SettingsTile.switchTile(
                title: _i18n.get("use_custom_ip"),
                leading: const Icon(CupertinoIcons.rectangle_expand_vertical),
                switchValue: _roomIsSet.value,
                onToggle: (value) => setState(() {
                  if (!value) {
                    _shareDao.put(SHARE_DAO_HOST_SET_BY_USER, "");
                  }
                  _roomIsSet.add(value);
                }),
              );
            },
          ),
          StreamBuilder<bool>(
            initialData: false,
            stream: _roomIsSet.stream,
            builder: (c, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Section(
                  title: _i18n.get("ip"),
                  children: [
                    TextField(
                      controller: _textEditingController,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: "127.0.0.1",
                        labelText: _i18n.get("host"),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _shareDao.put(
                          SHARE_DAO_HOST_SET_BY_USER,
                          _textEditingController.text,
                        );
                      },
                      child: Text(_i18n.get("save")),
                    )
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
