import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationCenterCircleAvatarWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  const NavigationCenterCircleAvatarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: p4),
      child: DescribedFeatureOverlay(
        featureId: SETTING_FEATURE,
        tapTarget: CircleAvatarWidget(_authRepo.currentUserUid, 30),
        backgroundColor: theme.colorScheme.tertiaryContainer,
        targetColor: theme.colorScheme.tertiary,
        title: Text(
          _i18n.get("setting_icon_feature_discovery_title"),
          textDirection: _i18n.defaultTextDirection,
          style: TextStyle(
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        overflowMode: OverflowMode.extendBackground,
        description: FeatureDiscoveryDescriptionWidget(
          permissionWidget: (hasContactCapability)
              ? TextButton(
                  onPressed: () {
                    FeatureDiscovery.dismissAll(context);
                    _routingService.openContacts();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_i18n.get("sync_contact")),
                      const Icon(
                        Icons.arrow_forward,
                      )
                    ],
                  ),
                )
              : null,
          description: _i18n.get("setting_icon_feature_discovery_description"),
          descriptionStyle: TextStyle(
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
        child: GestureDetector(
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: CircleAvatarWidget(
                _authRepo.currentUserUid,
                20,
              ),
            ),
          ),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _routingService.openSettings(popAllBeforePush: true);
          },
        ),
      ),
    );
  }
}
