import 'package:deliver/localization/i18n.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FeatureDiscoveryDescriptionWidget extends StatelessWidget {
  final String description;
  final Widget? permissionWidget;

  const FeatureDiscoveryDescriptionWidget({
    super.key,
    required this.description,
    this.permissionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = GetIt.I.get<I18N>();
    return Column(
      children: [
        Text(
          description,
          textDirection: i18n.isPersian ? TextDirection.rtl : TextDirection.ltr,
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async =>
                      FeatureDiscovery.completeCurrentStep(context),
                  child: Text(
                    i18n.get("understood"),
                    style:
                        theme.textTheme.button!.copyWith(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => FeatureDiscovery.dismissAll(context),
                  child: Text(
                    i18n.get("dismiss"),
                    style:
                        theme.textTheme.button!.copyWith(color: Colors.white),
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
