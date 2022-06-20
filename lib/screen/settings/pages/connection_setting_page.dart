import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ConnectionSettingPage extends StatefulWidget {
  final bool rootFromLoginPage;

  const ConnectionSettingPage({super.key, this.rootFromLoginPage = false});

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
  final _coreServices = GetIt.I.get<CoreServices>();

  @override
  void initState() {
    _initConnectionData();
    super.initState();
  }

  Future<void> _initConnectionData() async {
    final ip = (await _shareDao.get(SHARE_DAO_HOST_SET_BY_USER)) ?? "";
    _useCustomIp.add((ip.isNotEmpty));
    _textEditingController.text = ip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.get("connection_setting")),
      ),
      body: ListView(
        children: [
          Section(
            children: [
              SettingsTile.switchTile(
                title: _i18n.get("connect_on_bad_certificate"),
                leading: const Icon(CupertinoIcons.settings),
                switchValue: _servicesDiscoveryRepo.badCertificateConnection,
                onToggle: (value) => setState(() {
                  _servicesDiscoveryRepo.setCertificate(
                    onBadCertificate: value,
                  );
                }),
              ),
            ],
          ),
          StreamBuilder<bool>(
            initialData: false,
            stream: _useCustomIp.stream,
            builder: (c, ipSnapshot) {
              return Section(
                children: [
                  SettingsTile.switchTile(
                    title: _i18n.get("use_custom_ip"),
                    leading: const Icon(
                      CupertinoIcons.rectangle_expand_vertical,
                    ),
                    switchValue: ipSnapshot.data,
                    onToggle: (value) {
                      if (!value) {
                        _shareDao.put(SHARE_DAO_HOST_SET_BY_USER, "");
                        _textEditingController.text = "";
                        _servicesDiscoveryRepo.initClientChannel();
                      }
                      _useCustomIp.add(value);
                      _coreServices.resetConnection();
                    },
                  ),
                  if (ipSnapshot.hasData && ipSnapshot.data!)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
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
                          padding: const EdgeInsets.all(15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 15,
                              ),
                              primary: theme.colorScheme.primary,
                              onPrimary: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              if (_textEditingController.text.isNotEmpty) {
                                _servicesDiscoveryRepo.initClientChannel(
                                  ip: _textEditingController.text,
                                );
                                _shareDao.put(
                                  SHARE_DAO_HOST_SET_BY_USER,
                                  _textEditingController.text,
                                );
                                _coreServices.resetConnection();
                                if (widget.rootFromLoginPage) {
                                  Navigator.pop(context);
                                } else {
                                  _routingServices.pop();
                                }
                              }
                            },
                            child: Text(
                              _i18n.get("save"),
                            ),
                          ),
                        )
                      ],
                    )
                ],
              );
            },
          ),
          StreamBuilder<String>(
            stream: connectionError.stream,
            builder: (c, errorMsg) {
              if (errorMsg.hasData &&
                  errorMsg.data != null &&
                  errorMsg.data!.isNotEmpty) {
                return Section(
                  title: _i18n.get("connection_error"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        runSpacing: 8,
                        children: [
                          Debug(
                            errorMsg.data,
                            label: _i18n.get("connection_error"),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
    );
  }
}
