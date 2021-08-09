import 'dart:async';

import 'package:deliver_flutter/box/dao/live_location_dao.dart';
import 'package:deliver_flutter/box/livelocation.dart';
import 'package:deliver_public_protocol/pub/v1/live_location.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart' as pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';

class LiveLocationRepo {
  var _liveLocationDao = GetIt.I.get<LiveLocationDao>();
  final _liveLocationClient = GetIt.I.get<LiveLocationServiceClient>();

  saveLiveLocation(LiveLocation liveLocation) {
    _liveLocationDao.saveLiveLocation(liveLocation);
  }

  Future<LiveLocation> getLiveLocation(String uuid) async {
    return await _liveLocationDao.getLiveLocation(uuid);
  }

  Stream<LiveLocation> watchLiveLocation(String uuid) {
    return _liveLocationDao.watchLiveLocation(uuid);
  }

  Future<void> updateLiveLocation(pb.LiveLocation liveLocation) async {
    Timer timer;
    if (DateTime.now().millisecondsSinceEpoch > liveLocation.time.toInt())
      return;
    timer = Timer.periodic(Duration(minutes: 1), (t) async {
      var res = await _liveLocationClient
          .shouldSendLiveLocation(ShouldSendLiveLocationReq());
      if (res != null) if (res.shouldSend) {
        _getLatUpdateLocation(liveLocation.uuid);
      } else {
        timer.cancel();
      }
    });
  }

  void _getLatUpdateLocation(String uuid) async {
    List<pb.Location> locations = [];
    var res = await _liveLocationClient.getLastUpdatedLiveLocation(
        GetLastUpdatedLiveLocationReq()..uuid = uuid);
    if (res != null) {
      res.liveLocations.forEach((liveLocation) {
        locations.add(liveLocation.location);
      });
      _liveLocationDao.saveLiveLocation(LiveLocation(
          uuid: uuid,
          lastUpdate: DateTime.now().millisecondsSinceEpoch,
          locations: locations));
    }
  }

  Future<CreateLiveLocationRes> createLiveLocation(
      Uid roomUid, int duration) async {
    return await _liveLocationClient.createLiveLocation(CreateLiveLocationReq()
      ..room = roomUid
      ..duration = duration);
  }

  void sendLiveLocationAsStream(
      String uuid, int duration, pb.Location location) {
    _liveLocationDao.saveLiveLocation(LiveLocation()
      ..duration = duration
      ..uuid = uuid
      ..locations = [location]
      ..lastUpdate = DateTime.now().millisecondsSinceEpoch);
    Geolocator.getPositionStream(timeLimit: Duration(seconds: duration))
        .listen((p) {
      pb.Location location =
          pb.Location(latitude: p.latitude, longitude: p.longitude);
      _liveLocationClient
          .updateLocation(UpdateLocationReq()..location = location);
      _updateLiveLocationInDb(uuid, duration, location);
    });
  }

  void _updateLiveLocationInDb(
      String uuid, int duration, pb.Location location) async {
    var liveL = await _liveLocationDao.getLiveLocation(uuid);
    List<pb.Location> locations = liveL.locations ?? [];
    locations.add(location);
    _liveLocationDao.saveLiveLocation(LiveLocation(
        uuid: uuid,
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        locations: locations,
        duration: duration));
  }
}
