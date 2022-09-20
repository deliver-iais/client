import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';

class ShowCaseRepo {
  //final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _showCaseDao = GetIt.I.get<ShowCaseDao>();

  Future<List<ShowCase>?> getShowCasePage(
    int pointer, {
    bool foreToUpdateShowCases = false,
  }) async {
    final showCases = await _showCaseDao.getAllShowCases();
    if (showCases.length > pointer && !foreToUpdateShowCases) {
      return showCases;
    } else {
      return fetchMoreShowCases(pointer);
    }
  }

  //todo using real data after implementation
  Future<List<ShowCase>?> fetchMoreShowCases(
    int pointer,
  ) async {
    // final result = await _sdr.queryServiceClient.getShowcases(
    //   GetShowcasesReq()
    //     ..limit = Int64(10)
    //     ..pointer = Int64(pointer),
    // );

    //fake data
    final fakeData = [
      Showcase(
        groupedRooms: GroupedRooms(
          name: "پیشنهادی های شما",
          roomsList: [
            RoomCase(uid: "2:85afbdc5-b6f0-405e-beda-58bb27b28fda".asUid()),
            RoomCase(uid: "2:4c783547-3d10-404c-b82b-1486927fcf37".asUid()),
            RoomCase(uid: "2:2c6abdb2-8a6a-4a57-9dac-9aacf936835c".asUid()),
            RoomCase(uid: "2:5cb0f1d3-0861-41e7-a741-9bc2ba08a88b".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f6ed3557-94f5-439a-b140-0fae522dfc5d".asUid()),
            RoomCase(uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid()),
          ],
        ),
      ),
      Showcase(
        singleBanner: BannerCase(
          uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid(),
          bannerImg: File(
            uuid: "91f84af0-deac-416f-a1e5-996ca513da63",
            name: "1663694559011.webp",
          ),
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "جدیدترین ها",
          roomsList: [
            RoomCase(uid: "2:4c783547-3d10-404c-b82b-1486927fcf37".asUid()),
            RoomCase(uid: "2:2c6abdb2-8a6a-4a57-9dac-9aacf936835c".asUid()),
            RoomCase(uid: "2:5cb0f1d3-0861-41e7-a741-9bc2ba08a88b".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:85afbdc5-b6f0-405e-beda-58bb27b28fda".asUid()),
            RoomCase(uid: "2:f6ed3557-94f5-439a-b140-0fae522dfc5d".asUid()),
            RoomCase(uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid()),
          ],
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "اخبار جدید",
          roomsList: [
            RoomCase(uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid()),
            RoomCase(uid: "2:85afbdc5-b6f0-405e-beda-58bb27b28fda".asUid()),
            RoomCase(uid: "2:975a9d21-8fbf-4ab4-a264-ba07fa857119".asUid()),
            RoomCase(uid: "2:2c6abdb2-8a6a-4a57-9dac-9aacf936835c".asUid()),
            RoomCase(uid: "2:5cb0f1d3-0861-41e7-a741-9bc2ba08a88b".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f6ed3557-94f5-439a-b140-0fae522dfc5d".asUid()),
          ],
        ),
      ),
      Showcase(
        singleBanner: BannerCase(
          uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid(),
          bannerImg: File(
            uuid: "91f84af0-deac-416f-a1e5-996ca513da63",
            name: "1663694559011.webp",
          ),
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "علم روز",
          roomsList: [
            RoomCase(uid: "2:975a9d21-8fbf-4ab4-a264-ba07fa857119".asUid()),
            RoomCase(uid: "2:2c6abdb2-8a6a-4a57-9dac-9aacf936835c".asUid()),
            RoomCase(uid: "2:5cb0f1d3-0861-41e7-a741-9bc2ba08a88b".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f8e51f85-0e31-4d5b-94f2-bf5ed37b1e66".asUid()),
            RoomCase(uid: "2:f6ed3557-94f5-439a-b140-0fae522dfc5d".asUid()),
            RoomCase(uid: "2:d84dcfee-49db-4f39-962f-dc04e62037c8".asUid()),
            RoomCase(uid: "2:85afbdc5-b6f0-405e-beda-58bb27b28fda".asUid()),
          ],
        ),
      ),
    ];
    //return fake data
    return _saveFetchedMedias(fakeData, pointer);
    // if (result.showcases.isNotEmpty) {
    //   return _saveFetchedMedias(result.showcases, pointer);
    // }
    // return null;
  }

  Showcase_Type findShowCaseType(String showCaseJson) {
    return Showcase.fromJson(showCaseJson).whichType();
  }

  Future<List<ShowCase>> _saveFetchedMedias(
    List<Showcase> getShowCases,
    int pointer,
  ) async {
    final showCasesList = <ShowCase>[];
    for (var i = 0; i < getShowCases.length; i++) {
      final insertedShowCase = ShowCase(
        index: pointer + i,
        json: getShowCases[i].writeToJson(),
      );
      showCasesList.add(insertedShowCase);
      await _showCaseDao.save(insertedShowCase);
    }
    return showCasesList;
  }
}
