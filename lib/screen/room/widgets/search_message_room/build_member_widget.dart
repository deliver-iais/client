import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/loaders/text_loader.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BuildRoomWidget extends StatefulWidget {
  final Uid uid;

  const BuildRoomWidget({
    super.key,
    required this.uid,
  });

  @override
  State<BuildRoomWidget> createState() => _BuildRoomWidgetState();
}

class _BuildRoomWidgetState extends State<BuildRoomWidget> {
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          _routingServices.openProfile(widget.uid.asString());
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatarWidget(widget.uid, 18),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _roomRepo.getName(widget.uid),
                        builder: (context, snapshot) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextLoader(
                                text: Text(
                                  snapshot.data ?? "".replaceAll('', '\u200B'),
                                  style:
                                      (Theme.of(context).textTheme.titleSmall)!
                                          .copyWith(height: 1.3),
                                  softWrap: false,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => {
                  _searchMessageService.closeSearch(),
                  if (!isLarge(context)) {_routingServices.pop()}
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
