import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/widgets/settings_ui/settings_ui.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  _LanguageSettingsPageState createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    I18N i18n = GetIt.I.get<I18N>();
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxBackground,
            titleSpacing: 8,
            title: Text(
              i18n.get("language"),
              style: TextStyle(color: ExtraTheme.of(context).textField),
            ),
            leading: _routingService.backButtonLeading(context),
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
                      leading: const Icon(Icons.language),
                      trailing: I18N.of(context)!.locale.languageCode ==
                              english.languageCode
                          ? const Icon(Icons.done)
                          : const SizedBox.shrink(),
                      onPressed: (BuildContext context) {
                        setState(() {
                          I18N.of(context)!.changeLanguage(english);
                        });
                      },
                    ),
                    SettingsTile(
                      title: 'فارسی',
                      leading: const Icon(Icons.language),
                      trailing: I18N.of(context)!.locale.languageCode ==
                              farsi.languageCode
                          ? const Icon(Icons.done)
                          : const SizedBox.shrink(),
                      onPressed: (BuildContext context) {
                        setState(() {
                          I18N.of(context)!.changeLanguage(farsi);
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
