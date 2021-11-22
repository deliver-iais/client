import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';

import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class LocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  LocationMessageWidget(
      {required this.message, required this.isSeen, required this.isSender});

  @override
  Widget build(BuildContext context) {
    Location location = message.json!.toLocation();
    return Container(
      child: Stack(
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
                    subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      width: 30.0,
                      height: 30.0,
                      point: LatLng(location.latitude, location.longitude),
                      builder: (ctx) => Container(
                          child: CircleAvatarWidget(message.from.asUid(), 20)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TimeAndSeenStatus(message, isSender, isSeen, needsBackground: true),
        ],
      ),
    );
  }
}
