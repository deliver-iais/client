import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/serverless/serverless_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

class CreateMucFloatingActionButton extends StatefulWidget {
  const CreateMucFloatingActionButton({Key? key}) : super(key: key);

  @override
  State<CreateMucFloatingActionButton> createState() =>
      _CreateMucFloatingActionButtonState();
}

class _CreateMucFloatingActionButtonState
    extends State<CreateMucFloatingActionButton> with CustomPopupMenu {
  static final _i18n = GetIt.I.get<I18N>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _serverLessService = GetIt.I.get<ServerLessService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanDown: storeDragDownPosition,
          child: FloatingActionButton(
            heroTag: "navigation-center-fab",
            onPressed: () {
              this.showMenu(
                context: context,
                items: [
                  _buildMenuItems(
                    "contacts",
                    const Icon(CupertinoIcons.person_2_alt),
                  ),
                  _buildMenuItems(
                    "new_broadcast",
                    const Icon(FontAwesomeIcons.towerBroadcast),
                  ),
                  _buildMenuItems(
                    "new_group",
                    const Icon(CupertinoIcons.group_solid),
                  ),
                  _buildMenuItems(
                    "new_channel",
                    const Icon(Icons.campaign_outlined),
                  ),
                ],
              ).then((value) => selectChatMenu(value ?? ""));
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void selectChatMenu(String key) {
    switch (key) {
      case "contacts":
        _routingService.openContacts();
        break;
      case "new_group":
        _routingService.openMemberSelection(
          categories: MucCategories.GROUP,
        );
        break;
      case "new_channel":
        _routingService.openMemberSelection(
          categories: MucCategories.CHANNEL,
        );
        break;
      case "new_broadcast":
        _routingService.openMemberSelection(
          categories: MucCategories.BROADCAST,
        );
        break;
    }
  }

  PopupMenuItem _buildMenuItems(String value, Widget icon,
      {bool showServerLessIcon = false}) {
    final theme = Theme.of(context);
    return PopupMenuItem<String>(
      key: Key(value),
      value: value,
      child: Row(
        children: [
          icon,
          const SizedBox(width: p8),
          Text(
            _i18n.get(value),
            style: theme.textTheme.bodyMedium,
          ),
          if (showServerLessIcon)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(CupertinoIcons.antenna_radiowaves_left_right),
            )
        ],
      ),
    );
  }
}
