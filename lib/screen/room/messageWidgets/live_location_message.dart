import 'package:deliver/box/livelocation.dart' as box;
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/liveLocationRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LiveLocationMessageWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;
  final CustomColorScheme colorScheme;

  const LiveLocationMessageWidget(
    this.message, {
    super.key,
    required this.isSender,
    required this.isSeen,
    required this.colorScheme,
  });

  @override
  LiveLocationMessageWidgetState createState() =>
      LiveLocationMessageWidgetState();
}

class LiveLocationMessageWidgetState extends State<LiveLocationMessageWidget> {
  static final _liveLocationRepo = GetIt.I.get<LiveLocationRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  late LiveLocation liveLocation;

  @override
  void initState() {
    liveLocation = widget.message.json.toLiveLocation();
    _liveLocationRepo.updateLiveLocation(liveLocation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<box.LiveLocation?>(
      stream: _liveLocationRepo.watchLiveLocation(liveLocation.uuid),
      builder: (c, liveLocationSnapshot) {
        if (liveLocationSnapshot.hasData && liveLocationSnapshot.data != null) {
          return liveLocationMessageWidgetBuilder(
            liveLocationSnapshot.data!.locations.last,
            _i18n,
            liveLocation.time.toInt(),
          );
        }
        return liveLocationMessageWidgetBuilder(
          liveLocation.location,
          _i18n,
          liveLocation.time.toInt(),
        );
      },
    );
  }

  Widget liveLocationMessageWidgetBuilder(
    Location location,
    I18N i18n,
    int duration,
  ) {
    return Stack(
      children: [
        SizedBox(
          width: 270,
          height: 270,
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(location.latitude, location.longitude),
              zoom: DEFAULT_ZOOM_LEVEL,
            ),
            children: [
              TileLayer(
                tileProvider: NetworkTileProvider(),
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(location.latitude, location.longitude),
                    builder: (ctx) =>
                        CircleAvatarWidget(widget.message.from, 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            ListView(
              children: [
                Text(i18n.get("live_location")),
                Text(i18n.get("last_update"))
              ],
            ),
            CircularPercentIndicator(
              radius: 20.0,
              percent: 1.0,
              center: Text(Duration(milliseconds: duration).toString()),
              progressColor: Colors.blueAccent,
            )
          ],
        ),
        TimeAndSeenStatus(
          widget.message,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          needsPadding: true,
          showBackground: true,
        ),
      ],
    );
  }
}
