import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart';

class MapWidget extends StatelessWidget {
  final Uid roomUid;
  final LocationData locationData;
  final Function scrollToLast;

  MapWidget({Key key, this.roomUid, this.locationData, this.scrollToLast})
      : super(key: key);

  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _routingServices = GetIt.I.get<RoutingService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            _messageRepo.sendLocationMessage(locationData, roomUid);
            _routingServices.pop();
            scrollToLast();
          },
          splashColor: Colors.blue,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        appBar: AppBar(
          leading: _routingServices.backButtonLeading(),
          title: FutureBuilder<String>(
            future: _roomRepo.getRoomDisplayName(roomUid),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.data != null) {
                return Text(
                  snapshot.data,
                  style: TextStyle(color: Colors.white),
                );
              } else {
                return Text(
                  "Unknown",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                );
              }
            },
          ),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            child: FlutterMap(
          options: new MapOptions(
            center: LatLng(locationData.latitude, locationData.longitude),
            zoom: 14.0,
          ),
          layers: [
            new TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            new MarkerLayerOptions(
              markers: [
                new Marker(
                  width: 200.0,
                  height: 200.0,
                  point: LatLng(locationData.latitude, locationData.longitude),
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        )));
  }
}
