import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:settings_ui/settings_ui.dart';

class LanguageSettingsPage extends StatefulWidget {
  LanguageSettingsPage({Key key}) : super(key: key);

  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _uxService = GetIt.I.get<UxService>();

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: FluidContainerWidget(
            child: AppBar(
              backgroundColor: ExtraTheme.of(context).boxBackground,
              // elevation: 0,
              titleSpacing: 8,
              title: Text(
                i18n.get("language"),
                style: Theme.of(context).textTheme.headline2,
              ),
              leading: _routingService.backButtonLeading(),
            ),
          ),
        ),
        body: FluidContainerWidget(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: 'Languages',
                  tiles: [
                    SettingsTile(
                      title: 'English',
                      leading: Icon(Icons.language),
                      trailing:
                          _uxService.locale.languageCode == English.languageCode
                              ? Icon(Icons.done)
                              : SizedBox.shrink(),
                      titleTextStyle: TextStyle(color: ExtraTheme.of(context).textField),
                      onPressed: (BuildContext context) {
                        setState(() {
                          _uxService.changeLanguage(English);
                        });
                      },
                    ),
                    SettingsTile(
                      title: 'فارسی',
                      leading: Icon(Icons.language),
                      trailing:
                          _uxService.locale.languageCode == Farsi.languageCode
                              ? Icon(Icons.done)
                              : SizedBox.shrink(),
                      titleTextStyle: TextStyle(color: ExtraTheme.of(context).textField),
                      onPressed: (BuildContext context) {
                        setState(() {
                          _uxService.changeLanguage(Farsi);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
