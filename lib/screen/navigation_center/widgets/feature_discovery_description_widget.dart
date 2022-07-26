import 'package:deliver/localization/i18n.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeatureDiscoveryDescriptionWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
  final String description;
  final Widget? permissionWidget;
  final TextStyle? descriptionStyle;

  const FeatureDiscoveryDescriptionWidget({
    super.key,
    required this.description,
    this.descriptionStyle,
    this.permissionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          description,
          textDirection: _i18n.defaultTextDirection,
          style: descriptionStyle,
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async =>
                      FeatureDiscovery.completeCurrentStep(context),
                  child: Text(
                    key: const Key("understood"),
                    _i18n.get("understood"),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                TextButton(
                  key: const Key("dismiss"),
                  onPressed: () => FeatureDiscovery.dismissAll(context),
                  child: Text(
                    _i18n.get("dismiss"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            permissionWidget ?? const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
