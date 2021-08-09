import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:hive/hive.dart';

part 'livelocation.g.dart';

@HiveType(typeId: LIVE_LOCATION_TRACK_ID)
class LiveLocation {
  // Table ID
  @HiveField(0)
  String uuid;

  // DbId
  @HiveField(1)
  int duration;

  @HiveField(2)
  int lastUpdate;

  @HiveField(3)
  List<Location> locations;


  LiveLocation(
      {this.uuid, this.lastUpdate,this.locations,this.duration});

  LiveLocation copyWith(
      {String uuid,
        int lastUpdate,
        List<Location> location,
        int duration}) =>
      LiveLocation(
        uuid: uuid ?? this.uuid,
        duration: duration ?? this.duration,
        locations: location ?? this.locations,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}
