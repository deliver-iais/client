import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/muc/widgets/selected_member_list_box.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SmsBroadcastList extends StatefulWidget {
  const SmsBroadcastList({Key? key}) : super(key: key);

  @override
  State<SmsBroadcastList> createState() => _SmsBroadcastListState();
}

class _SmsBroadcastListState extends State<SmsBroadcastList>
    with TickerProviderStateMixin {
  final I18N _i18n = GetIt.I.get<I18N>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final _routingService = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _i18n.get("use_sms_broad_cast_title"),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            StreamBuilder<bool>(
              stream: _createMucService.isSmsBroadcastEnableStream(),
              builder: (context, snapshot) {
                return Switch(
                  value: snapshot.data ?? false,
                  onChanged: (value) =>
                      _createMucService.setSmsBroadcastStatus(value: value),
                );
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: p8),
          child: Text(
            _i18n.get("use_sms_broad_cast_desc"),
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: _createMucService.isSmsBroadcastEnableStream(),
          builder: (context, snapshot) {
            return AnimatedSize(
              duration: AnimationSettings.slow,
              child: snapshot.data ?? false
                  ? SelectedMemberListBox(
                      title: _i18n.get("sms_recipients"),
                      onAddMemberClick: () {
                        _routingService.openMemberSelection(
                          categories: MucCategories.BROADCAST,
                          useSmsBroadcastList: true,
                          openMucInfoDeterminationPage: false,
                        );
                      },
                      useSmsBroadcastList: true,
                    )
                  : const SizedBox.shrink(),
            );
          },
        )
      ],
    );
  }
}
