import 'package:deliver/shared/constants.dart';
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
  int? duration;

  @HiveField(2)
  int? lastUpdate;

  @HiveField(3)
  List<Location> locations;

  LiveLocation({
    required this.uuid,
    this.lastUpdate,
    required this.locations,
    this.duration,
  });

  LiveLocation copyWith({
    required String uuid,
    int? lastUpdate,
    required List<Location> location,
    required int duration,
  }) =>
      LiveLocation(
        uuid: uuid,
        duration: duration,
        locations: location,
        lastUpdate: lastUpdate ?? this.lastUpdate,
      );
}
