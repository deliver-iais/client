import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/search/search_rooms_widget.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationCenterAppbarActionsWidget extends StatefulWidget {
  const NavigationCenterAppbarActionsWidget({
    super.key,
  });

  @override
  State<NavigationCenterAppbarActionsWidget> createState() =>
      _NavigationCenterAppbarActionsWidgetState();
}

class _NavigationCenterAppbarActionsWidgetState
    extends State<NavigationCenterAppbarActionsWidget> with CustomPopupMenu {
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();
  final SearchController _searchBoxController = SearchController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Directionality(
          textDirection: _i18n.reverseDefaultTextDirection,
          child: SearchAnchor(
            searchController: _searchBoxController,
            viewHintText: _i18n.get("search"),
            dividerColor: theme.dividerColor.withAlpha(60),
            suggestionsBuilder: (context, controller) {
              return <Widget>[
                Directionality(
                  textDirection: _i18n.defaultTextDirection,
                  child: SearchRoomsWidget(
                    searchBoxController: controller,
                  ),
                )
              ];
            },
            viewTrailing: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  if (_searchBoxController.text.isEmpty) {
                    Navigator.pop(context);
                  } else {
                    _searchBoxController.clear();
                  }
                },
              )
            ],
            builder: (context, controller) {
              return IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => _searchBoxController.openView(),
              );
            },
          ),
        ),
        if (isMobileNative)
          DescribedFeatureOverlay(
            featureId: QRCODE_FEATURE,
            tapTarget: Icon(
              CupertinoIcons.qrcode_viewfinder,
              color: theme.colorScheme.tertiaryContainer,
            ),
            backgroundColor: theme.colorScheme.tertiaryContainer,
            targetColor: theme.colorScheme.tertiary,
            title: Text(
              _i18n.get("qr_code_feature_discovery_title"),
              textDirection: _i18n.defaultTextDirection,
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            description: FeatureDiscoveryDescriptionWidget(
              description: _i18n.get("qr_code_feature_discovery_description"),
              descriptionStyle: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            child: IconButton(
              onPressed: () {
                _routingService.openScanQrCode();
              },
              icon: const Icon(
                CupertinoIcons.qrcode_viewfinder,
              ),
            ),
          ),
        StreamBuilder<PerformanceMode>(
          stream: PerformanceMonitor.performanceProfile,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data!.level <= PerformanceMode.POWER_SAVER.level) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanDown: storeDragDownPosition,
                child: IconButton(
                  onPressed: () async {
                    final value = await this.showMenu(
                      context: context,
                      items: [
                        PopupMenuItem(
                          value: "go_to_settings",
                          child: Text(
                            _i18n["power_saver_turned_on"],
                          ),
                        )
                      ],
                    );
                    if (value == "go_to_settings") {
                      _routingService.openPowerSaverSettings();
                    }
                  },
                  icon: const Icon(
                    Icons.energy_savings_leaf_outlined,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(
          width: 8,
        )
      ],
    );
  }
}
