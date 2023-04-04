// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/live_location_dao.dart';
import 'package:deliver/box/livelocation.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart' as pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

class LiveLocationRepo {
  final _liveLocationDao = GetIt.I.get<LiveLocationDao>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  void saveLiveLocation(LiveLocation liveLocation) {
    _liveLocationDao.saveLiveLocation(liveLocation);
  }

  Future<LiveLocation?> getLiveLocation(String uuid) async =>
      _liveLocationDao.getLiveLocation(uuid);

  Stream<LiveLocation?> watchLiveLocation(String uuid) =>
      _liveLocationDao.watchLiveLocation(uuid);

  void updateLiveLocation(pb.LiveLocation liveLocation) {
    Timer? timer;
    if (clock.now().millisecondsSinceEpoch > liveLocation.time.toInt()) {
      return;
    }
    timer = Timer.periodic(const Duration(minutes: 1), (t) async {
      final res = await _sdr.liveLocationServiceClient
          .shouldSendLiveLocation(ShouldSendLiveLocationReq());
      if (res.shouldSend) {
        return _getLatUpdateLocation(liveLocation.uuid);
      } else {
        timer!.cancel();
      }
    });
  }

  Future<void> _getLatUpdateLocation(String uuid) async {
    final locations = <pb.Location>[];
    final res = await _sdr.liveLocationServiceClient.getLastUpdatedLiveLocation(
      GetLastUpdatedLiveLocationReq()..uuid = uuid,
    );
    for (final liveLocation in res.liveLocations) {
      locations.add(liveLocation.location);
    }
    return _liveLocationDao.saveLiveLocation(
      LiveLocation(
        uuid: uuid,
        lastUpdate: clock.now().millisecondsSinceEpoch,
        locations: locations,
      ),
    );
  }

  Future<CreateLiveLocationRes> createLiveLocation(
    Uid roomUid,
    int duration,
  ) async =>
      await _sdr.liveLocationServiceClient.createLiveLocation(
        CreateLiveLocationReq()
          ..room = roomUid
          ..duration = Int64(duration),
      );

  void sendLiveLocationAsStream(
    String uuid,
    int duration,
    pb.Location location,
  ) {
    _liveLocationDao.saveLiveLocation(
      LiveLocation(
        duration: duration,
        uuid: uuid,
        locations: [location],
        lastUpdate: clock.now().millisecondsSinceEpoch,
      ),
    );
    Geolocator.getPositionStream(
      locationSettings:
          LocationSettings(timeLimit: Duration(seconds: duration)),
    ).listen((p) {
      final location =
          pb.Location(latitude: p.latitude, longitude: p.longitude);
      _sdr.liveLocationServiceClient
          .updateLocation(UpdateLocationReq()..location = location);
      _updateLiveLocationInDb(uuid, duration, location);
    });
  }

  Future<void> _updateLiveLocationInDb(
    String uuid,
    int duration,
    pb.Location location,
  ) async {
    final liveLocation = await _liveLocationDao.getLiveLocation(uuid);
    final locations = liveLocation!.locations..add(location);
    return _liveLocationDao.saveLiveLocation(
      LiveLocation(
        uuid: uuid,
        lastUpdate: clock.now().millisecondsSinceEpoch,
        locations: locations,
        duration: duration,
      ),
    );
  }
}
