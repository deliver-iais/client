import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/brand_image.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
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
  final _useCustomIp = false.obs;
  final _routingServices = GetIt.I.get<RoutingService>();
  final _coreServices = GetIt.I.get<CoreServices>();
  final _webUrlTextController =
      TextEditingController(text: settings.webViewUrl.value);

  @override
  void initState() {
    _initConnectionData();
    super.initState();
  }

  Future<void> _initConnectionData() async {
    final ip = settings.hostSetByUser.value;
    _useCustomIp.value = ((ip.isNotEmpty));
    _textEditingController.text = ip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_i18n.get("connection_settings")),
      ),
      body: FluidContainerWidget(
        child: ListView(
          children: [
            const BrandImage(
              text: "",
              imagePath: "assets/images/connection.webp",
              topFreeHeight: 330,
            ),
            Section(
              children: [
                Column(
                  children: [
                    SettingsTile.switchTile(
                      title: _i18n.get("connect_on_bad_certificate"),
                      leading: const Icon(CupertinoIcons.shield_slash),
                      switchValue: settings.useBadCertificateConnection.value,
                      onToggle: ({required newValue}) => setState(() {
                        settings.useBadCertificateConnection.toggleValue();
                      }),
                    ),
                    if (settings.useBadCertificateConnection.value)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: 18.0,
                          top: 4,
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 10),
                              child: Text(
                                _i18n.get("not_recommended"),
                                style: TextStyle(
                                  height: 0.8,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
            StreamBuilder<bool>(
              initialData: false,
              stream: _useCustomIp.stream,
              builder: (c, ipSnapshot) {
                return Section(
                  children: [
                    Column(
                      children: [
                        SettingsTile.switchTile(
                          title: _i18n.get("use_custom_ip"),
                          leading: const Icon(
                            FontAwesomeIcons.networkWired,
                            size: 20,
                          ),
                          switchValue: ipSnapshot.data,
                          onToggle: ({required newValue}) {
                            if (!newValue) {
                              settings.hostSetByUser.set("");
                              _textEditingController.text = "";
                              _servicesDiscoveryRepo.initClientChannels();
                            }
                            _useCustomIp.value = newValue;
                            _coreServices.retryConnection(forced: true);
                          },
                        ),
                        if (ipSnapshot.hasData && ipSnapshot.data!)
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
                                helperText:
                                    "${_i18n.get("set_ip_helper")} - 127.0.0.1",
                                labelText: _i18n.get("host"),
                              ),
                            ),
                          ),
                        if (ipSnapshot.hasData && ipSnapshot.data!)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 45,
                                  vertical: 15,
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              onPressed: () {
                                settings.hostSetByUser
                                    .set(_textEditingController.text);
                                _servicesDiscoveryRepo.initClientChannels();
                                _coreServices.retryConnection(forced: true);
                                if (widget.rootFromLoginPage) {
                                  Navigator.pop(context);
                                } else {
                                  _routingServices.pop();
                                }
                              },
                              child: Text(_i18n.get("save")),
                            ),
                          )
                      ],
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<String>(
              stream: connectionError.stream
                  .debounceTime(AnimationSettings.actualNormal)
                  .asBroadcastStream(),
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
            ),
            if (settings.showDeveloperPage.value) ...[
              const Padding(
                padding:
                    EdgeInsetsDirectional.only(start: 18.0, end: 18.0, top: 16),
                child: Text("آدرس فروشگاه"),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        minLines: 1,
                        controller: _webUrlTextController,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: p8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 15,
                        ),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        settings.webViewUrl.set(_webUrlTextController.text);
                        if (widget.rootFromLoginPage) {
                          Navigator.pop(context);
                        } else {
                          _routingServices.pop();
                        }
                      },
                      child: Text(_i18n.get("save")),
                    )
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
