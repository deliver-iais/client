import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SelectedMemberListBox extends StatelessWidget {
  static final _createMucService = GetIt.I.get<CreateMucService>();
  static final I18N _i18n = GetIt.I.get<I18N>();
  final String title;
  final bool useSmsBroadcastList;
  final VoidCallback onAddMemberClick;
  final MucCategories categories;

  const SelectedMemberListBox({
    super.key,
    required this.title,
    this.useSmsBroadcastList = false,
    required this.onAddMemberClick,
    this.categories = MucCategories.NONE,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: p12),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: p8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => buildText(
                    _createMucService.selected.length,
                    theme,
                  ),
                ),
                IconButton(
                  onPressed: () => onAddMemberClick(),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: p8),
            child: Divider(
              color: theme.colorScheme.outline,
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 250),
            child: Obx(
              () => _createMucService.selected.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _createMucService.selected.length,
                      itemBuilder: (context, index) => ContactWidget(
                        user: _createMucService.getSelected(
                          useBroadcastSmsContacts: useSmsBroadcastList,
                        )[index],
                        circleIcon: !((categories == MucCategories.BROADCAST &&
                                    _createMucService.selected.length < 3) ||
                                (categories == MucCategories.GROUP &&
                                    _createMucService.selected.length < 2) ||
                                (categories == MucCategories.CHANNEL &&
                                    _createMucService.selected.length < 2))
                            ? Icons.remove_circle_outline
                            : null,
                        circleIconColor: Colors.red,
                        onCircleIcon: () =>
                            _createMucService.deleteFromSelected(
                          _createMucService.getSelected(
                            useBroadcastSmsContacts: useSmsBroadcastList,
                          )[index],
                          useBroadcastSmsContacts: useSmsBroadcastList,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () => onAddMemberClick(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_i18n.get("add_member")),
                          SizedBox(
                            height: 70,
                            width: 50,
                            child: Ws.asset(
                              "assets/animations/touch.ws",
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(
                                    const ['**'],
                                    value: theme.colorScheme.primary,
                                  ),
                                  ValueDelegate.strokeColor(
                                    const ['**'],
                                    value: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Text buildText(int size, ThemeData theme) {
    return Text(
      '$title: ${"$size ${_i18n.get("members")}"}',
      style: theme.primaryTextTheme.titleSmall,
    );
  }
}
