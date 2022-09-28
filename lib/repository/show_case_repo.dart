import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
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
            RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
            RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
            RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
            RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
            RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
            RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
          ],
        ),
      ),
      Showcase(
        singleBanner: BannerCase(
          uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
          bannerImg: File(
            uuid: "89ea82cd-e8fc-425f-8ff3-084870b4f864",
            name: "1664362602484.webp",
          ),
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "جدیدترین ها",
          roomsList: [
            RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
            RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
            RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
            RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
            RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
            RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
          ],
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "اخبار جدید",
          roomsList: [
            RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
            RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
            RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
            RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
            RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
            RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
            RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
          ],
        ),
      ),
      Showcase(
        groupedBanners: GroupedBanners(
          bannersList: [
            BannerCase(
              uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
              bannerImg: File(
                uuid: "e5eeddb6-e59a-4b60-8c17-e27fe9f76c47",
                name: "1664365328848.webp",
              ),
            ),
            BannerCase(
              uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
              bannerImg: File(
                uuid: "fa9f51dd-760f-4de0-8486-f44b2523132f",
                name: "1664365332860.webp",
              ),
            ),
          ],
          name: "آگهی ها",
        ),
      ),
      Showcase(
        groupedRooms: GroupedRooms(
          name: "علم روز",
          roomsList: [
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
            RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
            RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
            RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
            RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
            RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
            RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
            RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
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
