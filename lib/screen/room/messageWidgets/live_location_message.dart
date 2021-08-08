import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
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

class LiveLocationMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;

  LiveLocationMessageWidget(this.message, this.isSeen, this.isSender);

  var _messageRepo = GetIt.I.get<MessageRepo>();


  @override
  Widget build(BuildContext context) {
    I18N _i18n = I18N.of(context);
    LiveLocation liveLocation = message.json.toLiveLocation();
    return StreamBuilder<Message>(stream: _messageRepo.watchMessage(message.roomUid, message.id.toString()),builder: (c,lm){
      if(lm.hasData && lm.data != null){
        liveLocation = lm.data.json.toLiveLocation();
        return liveLocationMessageWidgetBuilder(liveLocation, _i18n);
      }return
       liveLocationMessageWidgetBuilder(liveLocation, _i18n);
    });

  }

  Container liveLocationMessageWidgetBuilder(LiveLocation liveLocation, I18N _i18n) {
    return Container(
      child: Stack(
        children: [
          SizedBox(
            width: 270,
            height: 270,
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(liveLocation.location.latitude,
                    liveLocation.location.longitude),
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
                      point: LatLng(liveLocation.location.latitude,
                          liveLocation.location.longitude),
                      builder: (ctx) => Container(
                          child: CircleAvatarWidget(message.from.asUid(), 20)),
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
                center: new Text(Duration(seconds: liveLocation.time.toInt()).toString()),
                progressColor: Colors.blueAccent,
              )
            ],
          ),
          TimeAndSeenStatus(message, isSender, true, isSeen),
        ],
      ),
    );
  }
}
