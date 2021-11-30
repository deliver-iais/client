
import 'package:deliver/box/livelocation.dart';
import 'package:hive/hive.dart';

abstract class LiveLocationDao {

  Future<LiveLocation?> getLiveLocation(String uuid);

  Future<void> saveLiveLocation(LiveLocation liveLocation);

  Stream<LiveLocation?> watchLiveLocation(String uuid);


}

class LiveLocationDaoImpl implements LiveLocationDao {


  @override
  Future<void> saveLiveLocation(LiveLocation liveLocation) async {
    var box = await _open();
    box.put(liveLocation.uuid, liveLocation);


  }


  @override
  Future<LiveLocation?> getLiveLocation(String uuid) async {
    var box = await _open();
    return box.get(uuid);
  }

  @override
  Stream<LiveLocation?> watchLiveLocation(String uuid) async* {
    var box = await _open();

    yield box.get(uuid);
    yield* box.watch(key: uuid).map((event) => box.get(uuid));
  }

  static String _key() => "live_location";


  static Future<Box<LiveLocation>> _open() =>
      Hive.openBox<LiveLocation>(_key());

}
