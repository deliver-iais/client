import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:deliver_flutter/box/livelocation.dart' as box;
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/liveLocationRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:percent_indicator/percent_indicator.dart';

class LiveLocationMessageWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;

  LiveLocationMessageWidget(this.message, this.isSeen, this.isSender);

  @override
  _LiveLocationMessageWidgetState createState() =>
      _LiveLocationMessageWidgetState();
}

class _LiveLocationMessageWidgetState extends State<LiveLocationMessageWidget> {
  var _liveLocationRepo = GetIt.I.get<LiveLocationRepo>();

  LiveLocation liveLocation;

  @override
  void initState() {
    liveLocation = widget.message.json.toLiveLocation();
    _liveLocationRepo.updateLiveLocation(liveLocation);
  }

  @override
  Widget build(BuildContext context) {
    I18N _i18n = I18N.of(context);

    return StreamBuilder<box.LiveLocation>(
        stream: _liveLocationRepo.watchLiveLocation(liveLocation.uuid),
        builder: (c, liveLocationsnapshot) {
          if (liveLocationsnapshot.hasData &&
              liveLocationsnapshot.data != null) {
            return liveLocationMessageWidgetBuilder(
                liveLocationsnapshot.data.locations.last,
                _i18n,
                liveLocation.time.toInt());
          }
          return liveLocationMessageWidgetBuilder(
              liveLocation.location, _i18n, liveLocation.time.toInt());
        });
  }

  Container liveLocationMessageWidgetBuilder(
      Location location, I18N _i18n, int duration) {
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
                          child: CircleAvatarWidget(
                              widget.message.from.asUid(), 20)),
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
                  Text(_i18n.get("live_location")),
                  Text("${_i18n.get(
                    "last_update",
                  )}")
                ],
              ),
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 5.0,
                percent: 1.0,
                center: new Text(Duration(milliseconds: duration).toString()),
                progressColor: Colors.blueAccent,
              )
            ],
          ),
          TimeAndSeenStatus(
              widget.message, widget.isSender, true, widget.isSeen),
        ],
      ),
    );
  }
}
