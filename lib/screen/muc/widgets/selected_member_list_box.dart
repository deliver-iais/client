import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SelectedMemberListBox extends StatelessWidget {
  static final _createMucService = GetIt.I.get<CreateMucService>();
  static final I18N _i18n = GetIt.I.get<I18N>();
  final String title;
  final bool useSmsBroadcastList;
  final VoidCallback onAddMemberClick;

  const SelectedMemberListBox({
    Key? key,
    required this.title,
    this.useSmsBroadcastList = false,
    required this.onAddMemberClick,
  }) : super(key: key);

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
                StreamBuilder<int>(
                  stream: _createMucService.selectedMembersLengthStream(
                    useBroadcastSmsContacts: useSmsBroadcastList,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      '$title: ${snapshot.data != 0 ? "${snapshot.data} ${_i18n.get("members")}" : ""}',
                      style: theme.primaryTextTheme.titleSmall,
                    );
                  },
                ),
                IconButton(
                  onPressed: () => onAddMemberClick(),
                  icon: const Icon(Icons.add_circle_outline),
                )
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
            child: StreamBuilder<int>(
              stream: _createMucService.selectedMembersLengthStream(
                useBroadcastSmsContacts: useSmsBroadcastList,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                } else if (snapshot.data == 0) {
                  return InkWell(
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
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data,
                  itemBuilder: (context, index) => ContactWidget(
                    contact: _createMucService.getContacts(
                      useBroadcastSmsContacts: useSmsBroadcastList,
                    )[index],
                    circleIcon: Icons.remove_circle_outline,
                    circleIconColor: Colors.red,
                    onCircleIcon: () => _createMucService.deleteContact(
                      _createMucService.getContacts(
                        useBroadcastSmsContacts: useSmsBroadcastList,
                      )[index],
                      useBroadcastSmsContacts: useSmsBroadcastList,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
