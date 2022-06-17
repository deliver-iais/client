import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  LanguageSettingsPageState createState() => LanguageSettingsPageState();
}

class LanguageSettingsPageState extends State<LanguageSettingsPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("language")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView(
            children: [
              Section(
                title: 'Languages',
                children: [
                  SettingsTile(
                    title: 'English',
                    leading: const Icon(Icons.language),
                    trailing: _i18n.locale.languageCode == english.languageCode
                        ? const Icon(Icons.done)
                        : const SizedBox.shrink(),
                    onPressed: (context) {
                      setState(() {
                        _i18n.changeLanguage(english);
                      });
                    },
                  ),
                  SettingsTile(
                    title: 'فارسی',
                    leading: const Icon(Icons.language),
                    trailing: _i18n.locale.languageCode == farsi.languageCode
                        ? const Icon(Icons.done)
                        : const SizedBox.shrink(),
                    onPressed: (context) {
                      setState(() {
                        _i18n.changeLanguage(farsi);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
