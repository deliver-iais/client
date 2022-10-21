import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            // onEnter: (event) {
            //   _uxService.scrollPhysics
            //       .add(const NeverScrollableScrollPhysics());
            // },
            // onExit: (event) {
            //   _uxService.scrollPhysics.add(const ClampingScrollPhysics());
            // },
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(location.latitude, location.longitude),
                zoom: 15.0,
                enableScrollWheel: false,
                onTap: (_, point) async {
                  await showDialog(
                    context: context,
                    builder: (_) => LocationDialog(
                      location: location,
                      from: message.from.asUid(),
                    ),
                  );
                },
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
                          CircleAvatarWidget(message.from.asUid(), 20),
                    ),
                  ],
                ),
              ],
            ),
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

class LocationDialog extends StatelessWidget {
  final Location location;
  final Uid from;

  final double size = isDesktop ? 500 : 350;

  LocationDialog({super.key, required this.location, required this.from});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: mainBorder,
          boxShadow: DEFAULT_BOX_SHADOWS,
        ),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(location.latitude, location.longitude),
            zoom: 15.0,
            enableMultiFingerGestureRace: true,
          ),
          children: [
            TileLayer(
              tileProvider: NetworkTileProvider(),
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(location.latitude, location.longitude),
                  builder: (ctx) => CircleAvatarWidget(from, 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
