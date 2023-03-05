import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/language.dart';
import 'package:deliver/shared/widgets/brand_image.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LanguageSettingsPage extends StatefulWidget {
  final bool rootFromLoginPage;

  const LanguageSettingsPage({super.key, this.rootFromLoginPage = false});

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
          leading: widget.rootFromLoginPage
              ? null
              : _routingService.backButtonLeading(),
        ),
      ),
      body: FluidContainerWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: ListView(
              children: [
                const BrandImage(
                  text: "",
                  imagePath: "assets/images/language.webp",
                  alignment: Alignment(0, -0.3),
                  topFreeHeight: 360,
                ),
                Section(
                  title: _i18n.get("languages"),
                  children: [
                    for (final lang in supportedLanguages)
                      SettingsTile(
                        title: lang.name,
                        leading: const Icon(Icons.language),
                        trailing: _i18n.locale.languageCode == lang.languageCode
                            ? const Icon(Icons.done)
                            : const SizedBox.shrink(),
                        onPressed: (context) => setState(
                          () => _i18n.changeLanguage(lang),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
