import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MucAppbarTitle extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _mucHelper = GetIt.I.get<MucHelperService>();

  final Uid mucUid;

  const MucAppbarTitle({super.key, required this.mucUid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            CircleAvatarWidget(mucUid, 20),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: StreamBuilder<Muc?>(
                stream: _mucRepo.watchMuc(mucUid.asString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.name,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: theme.textTheme.titleMedium,
                        ),
                        TitleStatus(
                          style: theme.textTheme.bodySmall!,
                          normalConditionWidget: Text(
                            "${_mucHelper.calculateMucPopulation(snapshot.data!.uid.asUid(), snapshot.data!.population)}"
                            " ${_mucHelper.mucAppBarMemberTitle(snapshot.data!.uid.asUid())}",
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: theme.textTheme.bodySmall,
                          ),
                          currentRoomUid: mucUid,
                        )
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 200,
                          height: 20,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 11,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            )
          ],
        ),
        onTap: () {
          _routingService.openProfile(mucUid.asString());
        },
      ),
    );
  }
}
