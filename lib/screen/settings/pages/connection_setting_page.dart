import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionSettingPage extends StatefulWidget {
  final bool rootFromLoginPage;

  const ConnectionSettingPage({Key? key, this.rootFromLoginPage = false})
      : super(key: key);

  @override
  State<ConnectionSettingPage> createState() => _ConnectionSettingPageState();
}

class _ConnectionSettingPageState extends State<ConnectionSettingPage> {
  final _i18n = GetIt.I.get<I18N>();
  final _servicesDiscoveryRepo = GetIt.I.get<ServicesDiscoveryRepo>();
  final TextEditingController _textEditingController = TextEditingController();
  final _shareDao = GetIt.I.get<SharedDao>();
  final BehaviorSubject<bool> _useCustomIp = BehaviorSubject.seeded(false);
  final _routingServices = GetIt.I.get<RoutingService>();
  String ip = "";

  @override
  void initState() {
    _initConnectionData();
    super.initState();
  }

  Future<void> _initConnectionData() async {
    ip = (await _shareDao.get(SHARE_DAO_HOST_SET_BY_USER)) ?? "";
    _useCustomIp.add((ip.isNotEmpty));
    _textEditingController.text = ip;
  }

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
            height: 30,
          ),
          StreamBuilder<bool>(
            initialData: false,
            stream: _useCustomIp.stream,
            builder: (c, ipSnapshot) {
              return SettingsTile.switchTile(
                title: _i18n.get("use_custom_ip"),
                leading: const Icon(CupertinoIcons.rectangle_expand_vertical),
                switchValue: ipSnapshot.data,
                onToggle: (value) {
                  if (!value) {
                    _shareDao.put(SHARE_DAO_HOST_SET_BY_USER, "");
                    _textEditingController.text = "";
                    _servicesDiscoveryRepo.initClientChannel();
                  }
                  _useCustomIp.add(value);
                },
              );
            },
          ),
          StreamBuilder<bool>(
            initialData: false,
            stream: _useCustomIp.stream,
            builder: (c, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Section(
                  title: _i18n.get("ip"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(3, 20, 3, 30),
                      child: TextField(
                        controller: _textEditingController,
                        keyboardType: TextInputType.phone,
                        maxLength: 15,
                        decoration: InputDecoration(
                          hintText: "127.0.0.1",
                          helperText: _i18n.get("set_ip_helper"),
                          labelText: _i18n.get("host"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_textEditingController.text.isNotEmpty) {
                            _servicesDiscoveryRepo.initClientChannel(
                              ip: _textEditingController.text,
                            );
                            _shareDao.put(
                              SHARE_DAO_HOST_SET_BY_USER,
                              _textEditingController.text,
                            );
                            if (widget.rootFromLoginPage) {
                              Navigator.pop(context);
                            } else {
                              _routingServices.pop();
                            }
                          }
                        },
                        child: Text(_i18n.get("save")),
                      ),
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
