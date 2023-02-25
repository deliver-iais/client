import 'dart:convert';

import 'package:deliver/box/dao/show_case_dao.dart';
import 'package:deliver/box/show_case.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/pin_code_settings.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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

  // TODO(any): using real data after implementation
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
      // Showcase(
      //   groupedRooms: GroupedRooms(
      //     name: "پیشنهادی های شما",
      //     roomsList: [
      //       RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
      //       RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //       RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
      //       RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
      //       RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
      //       RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //     ],
      //   ),
      // ),
      Showcase(
        singleBanner: BannerCase(
          uid: "3:fec74bc5-a8e6-4020-933e-784b1f3c6c05".asUid(),
          bannerImg: File(
            uuid: "14f0fa82-7023-4932-9e85-06935612c0cb",
            name: "1667989130491.jpeg",
          ),
        ),
      ),
      Showcase(
        singleUrl: UrlCase(
          name: "بات",
          description: "ساخت بات",
          botCallback: BotCallback(
            bot: Uid(category: Categories.BOT, node: "auth_bot"),
            data: _getData("REGISTER", "BOT_PLATFORM"),
            pinCodeSettings: PinCodeSettings(
              length: 4,
              isOutsideFirstRedirectionEnabled: true,
              outsideFirstRedirectionAlert:
                  "با مراجعه به بات نشست خود را احراز کنید.",
              outsideFirstRedirectionText: "/start",
            ),
          ),
          img: File(
            uuid: "0410e8ed-aeda-4180-949a-5f13b2efc1b1",
            name: "yaybotemoji.gif",
          ),
        ),
      ),
      Showcase(
        singleUrl: UrlCase(
          name: "گروه تستی احراز هویت",
          description: "گروه تستی احراز هویت",
          botCallback: BotCallback(
            bot: Uid(category: Categories.BOT, node: "auth_bot"),
            data: _getData(
              "JOIN_TO_GROUP",
              "d23e3f2f-9484-44da-a851-da1efa761f7c",
            ),
          ),
          img: File(
            uuid: "d369efa0-5159-463c-98e7-f96378ca8710",
            name: "1676788382457.jpeg",
          ),
        ),
      ),
      Showcase(
        singleUrl: UrlCase(
          name: "ارزیابی",
          description: "سامانه ارزیابی",
          botCallback: BotCallback(
            bot: Uid(category: Categories.BOT, node: "auth_bot"),
            data: _getData("LOGIN", "botplatform"),
          ),
          img: File(
            uuid: "14f0fa82-7023-4932-9e85-06935612c0cb",
            name: "1667989130491.jpeg",
          ),
        ),
      ),
      // Showcase(
      //   primary: true,
      //   groupedRooms: GroupedRooms(
      //     name: "جدیدترین ها",
      //     roomsList: [
      //       RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
      //       RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //       RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
      //       RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //       RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
      //       RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
      //     ],
      //   ),
      // ),
      // Showcase(
      //   groupedRooms: GroupedRooms(
      //     name: "اخبار جدید",
      //     roomsList: [
      //       RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
      //       RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //       RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
      //       RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
      //       RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
      //       RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
      //       RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
      //     ],
      //   ),
      // ),
      Showcase(
        groupedBanners: GroupedBanners(
          bannersList: [
            // BannerCase(
            //   uid: "3:e86a3be9-d3f0-423d-ba7b-59fb82525f7b".asUid(),
            //   bannerImg: File(
            //     uuid: "e5eeddb6-e59a-4b60-8c17-e27fe9f76c47",
            //     name: "1664365328848.webp",
            //   ),
            // ),
            BannerCase(
              uid: "3:fec74bc5-a8e6-4020-933e-784b1f3c6c05".asUid(),
              bannerImg: File(
                uuid: "14f0fa82-7023-4932-9e85-06935612c0cb",
                name: "1667989130491.jpeg",
              ),
            ),
            BannerCase(
              uid: "4:quiztest_bot".asUid(),
              bannerImg: File(
                uuid: "e5eeddb6-e59a-4b60-8c17-e27fe9f76c47",
                name: "1664365328848.webp",
              ),
            ),
            BannerCase(
              uid: "3:911c2734-397d-410d-81aa-a66da99b629e".asUid(),
              bannerImg: File(
                uuid: "fa9f51dd-760f-4de0-8486-f44b2523132f",
                name: "1664365332860.webp",
              ),
            ),
            BannerCase(
              uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
              bannerImg: File(
                uuid: "2dc29b9a-4af6-4409-9645-db1333cac542",
                name: "1664446020902.jpeg",
              ),
            ),
            // BannerCase(
            //   uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
            //   bannerImg: File(
            //     uuid: "5cee9920-8676-437e-994c-b0015f83f1a2",
            //     name: "1664446035532.jpeg",
            //   ),
            // ),
            // BannerCase(
            //   uid: "3:f508a026-071b-4d65-ba75-82fdd83756b0".asUid(),
            //   bannerImg: File(
            //     uuid: "00394804-79a6-4d62-8a1f-1a1d41b7230e",
            //     name: "1664446007055.jpeg",
            //   ),
            // ),
          ],
          name: "مالیات",
        ),
      ),
      // Showcase(
      //   isAdvertisement: true,
      //   groupedRooms: GroupedRooms(
      //     name: "علم روز",
      //     roomsList: [
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //       RoomCase(uid: "3:c123a6b0-57b7-45aa-8bb4-2b9d4ac273bf".asUid()),
      //       RoomCase(uid: "3:95e40d70-6586-4662-aba3-ac17d3ca8faf".asUid()),
      //       RoomCase(uid: "3:a7c9605b-79cd-4764-a235-65edcecc6b2e".asUid()),
      //       RoomCase(uid: "3:5b53a194-f9ea-48c4-9653-bab6f8b637ff".asUid()),
      //       RoomCase(uid: "3:d0800022-fc53-4d53-9b42-74fa1181366f".asUid()),
      //       RoomCase(uid: "3:4b76d77a-0b29-4aa5-b042-44193b6662bd".asUid()),
      //       RoomCase(uid: "3:edb16986-ee0a-4e07-a474-29344f27af5a".asUid()),
      //     ],
      //   ),
      // ),
      // Showcase(
      //   isAdvertisement: true,
      //   singleUrl: UrlCase(
      //     img: File(
      //       uuid: "14f0fa82-7023-4932-9e85-06935612c0cb",
      //       name: "1667989130491.jpeg",
      //     ),
      //     description: "پایگاه خبری تحلیلی سازمان مالیاتی کشور",
      //     name: "اینتا",
      //     url: "https://www.tax.gov.ir/Pages/HomePage",
      //   ),
      // ),
      // Showcase(
      //   isAdvertisement: true,
      //   groupedUrl: GroupedUrls(
      //     name: "مالیات",
      //     urlsList: [
      //       UrlCase(
      //         img: File(
      //           uuid: "5cee9920-8676-437e-994c-b0015f83f1a2",
      //           name: "1664446035532.jpeg",
      //         ),
      //         description: "پایگاه خبری تحلیلی سازمان مالیاتی کشور",
      //         name: "اینتا",
      //         url: "https://www.tax.gov.ir/Pages/HomePage",
      //       ),
      //       UrlCase(
      //         img: File(
      //           uuid: "e5eeddb6-e59a-4b60-8c17-e27fe9f76c47",
      //           name: "1664365328848.webp",
      //         ),
      //         description: "پایگاه خبری تحلیلی سازمان مالیاتی کشور",
      //         name: "اینتا",
      //         url: "https://www.tax.gov.ir/Pages/HomePage",
      //       ),
      //     ],
      //   ),
      // ),
    ];
    //return fake data
    return _saveFetchedShowCases(fakeData, pointer);
    // if (result.showcases.isNotEmpty) {
    //   return _saveFetchedShowCases(result.showcases, pointer);
    // }
    // return null;
  }

  Showcase_Type findShowCaseType(String showCaseJson) {
    return Showcase.fromJson(showCaseJson).whichType();
  }

  String _getData(String key, String value) => jsonEncode({key: value});

  Future<List<ShowCase>> _saveFetchedShowCases(
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
