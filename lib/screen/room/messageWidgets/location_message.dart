import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const LocationMessageWidget({
    super.key,
    required this.message,
    required this.isSeen,
    required this.isSender,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final location = message.json.toLocation();
    return Stack(
      children: [
        SizedBox(
          width: 270,
          height: 270,
          child: FlutterMap(
            options: MapOptions(
              center: LatLng(location.latitude, location.longitude),
              zoom: 15.0,
            ),
            layers: [
              TileLayerOptions(
                tileProvider: NetworkTileProvider(),
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    point: LatLng(location.latitude, location.longitude),
                    builder: (ctx) =>
                        CircleAvatarWidget(message.from.asUid(), 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        TimeAndSeenStatus(
          message,
          isSender: isSender,
          isSeen: isSeen,
          needsPadding: true,
          showBackground: true,
        ),
      ],
    );
  }
}
