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
        isAdvertisement: true,
        singleBanner: BannerCase(
          bannerImg: File(
            uuid: "a3a22351-872c-4332-99d9-90119821f8d1",
            name: "1673170736121.jpeg",
          ),
          uid: "0:285abc61-d67b-464c-b0d8-6de724643506".asUid(),
        ),
      ),
      Showcase(
        isAdvertisement: true,
        primary: true,
        groupedUrl: GroupedUrls(
          name: "خدمات الکترونیک مالیاتی",
          urlsList: [
            UrlCase(
              img: File(
                uuid: "326605b5-c0af-4e7e-a2a5-48787d4f91e5",
                name: "1669073754293.webp",
              ),
              description: "دسترسی به کلیه پرونده های مالیاتی",
              name: "پنجره واحد خدمات مالیاتی",
              url: SimpleUrl(url: "https://my.tax.gov.ir"),
            ),
            UrlCase(
              img: File(
                uuid: "51bf997d-0931-422e-9007-ac1ea09366b9",
                name: "1671729817643.webp",
              ),
              description:
                  "با داشتن شناسه پرداخت می توانید به صورت آنلاین پرداخت نمایید.",
              name: "پرداخت آنلاین مالیات",
              url: SimpleUrl(url: "https://payments.tax.gov.ir"),
            ),
            UrlCase(
              img: File(
                uuid: "2a03e1ec-ad2c-45c8-a977-874d65f7cfa2",
                name: "1673183860314.jpeg",
              ),
              description: "",
              name: "گواهی ماده ۱۸۶",
              url: SimpleUrl(url: "https://govahi186.tax.gov.ir"),
            ),
            UrlCase(
              img: File(
                uuid: "ab86fcf1-7a27-4f61-a383-e4f8f00b3443",
                name: "1673183988498.jpeg",
              ),
              description: "",
              name: "مالیات نقل و انتقال خودرو",
              url: SimpleUrl(url: "https://cartransfer.tax.gov.ir"),
            ),
            UrlCase(
              img: File(
                uuid: "95e6dc4e-9c4c-4ab2-9227-8da0ef191004",
                name: "1673183111350.webp",
              ),
              description: "",
              name: "محاسبه و پرداخت مالیات ارث",
              url: SimpleUrl(url: "https://ersportal.tax.gov.ir"),
            ),
          ],
        ),
      ),
      Showcase(
        groupedUrl: GroupedUrls(
          name: "اطلاع رسانی های مالیاتی",
          urlsList: [
            UrlCase(
              img: File(
                uuid: "65e3cb68-23c0-4d6d-8c5d-bedcc19a5ac5",
                name: "1673190421060.jpeg",
              ),
              url: SimpleUrl(url: "https://news.intamedia.ir"),
              name: "پایگاه خبری تحلیلی سازمان امور مالیاتی",
              description: "",
            ),
            UrlCase(
              url: SimpleUrl(
                url:
                    "https://www.intamedia.ir/Law-of-store-terminals-and-taxpayer-system",
              ),
              name: "پایانه های فروشگاهی و سامانه مودیان",
              description: "",
              img: File(
                uuid: "c0638b13-a64d-411c-b8d2-79a62c007d97",
                name: "1671728600458.webp",
              ),
            ),
            UrlCase(
              img: File(
                uuid: "8e90bfe2-a263-438f-a80d-8c64d72f3f3f",
                name: "1669073961778.webp",
              ),
              description: "کلیه قوانین و مقررات مالیاتی",
              name: "قوانین مالیاتی",
              url: SimpleUrl(url: "https://hamrahyaar.com/books/177679"),
            ),
            UrlCase(
              img: File(
                uuid: "b99a35c0-0db9-494b-b1e6-694dd6abc933",
                name: "1669073982836.webp",
              ),
              description: "",
              name: "رادیو مالیاتی",
              url: SimpleUrl(url: "https://www.intamedia.ir/podcast"),
            ),
            UrlCase(
              img: File(
                uuid: "88a58764-ce45-43ba-bd03-27b03735414b",
                name: "1669074068574.webp",
              ),
              description: "",
              name: "راهنمای سامانه های مالیاتی",
              url: SimpleUrl(url: "https://www.tax.gov.ir/Pages/HomePage"),
            ),
            UrlCase(
              img: File(
                uuid: "4011724e-7644-444f-897b-8b4c689c27d0",
                name: "1669074156772.webp",
              ),
              description: "آدرس و محل تمامی ساختمان های مالیاتی",
              name: "راهنمای ساختمان",
              url: SimpleUrl(
                url: "https://www.intamedia.ir/Contact-Consultants",
              ),
            ),
            UrlCase(
              img: File(
                uuid: "58400917-188b-4762-8dcb-355035133ed9",
                name: "1669153385240.webp",
              ),
              description: "",
              name: "سوت زنی",
              url: SimpleUrl(
                url: "https://www.intamedia.ir/popular-report/new-tax-frude",
              ),
            ),
            UrlCase(
              img: File(
                uuid: "2e18c836-ed5a-41ac-b3c8-02d5b0ef002f",
                name: "1673193481661.jpeg",
              ),
              description: "",
              name: "آموزش",
              url: SimpleUrl(
                url: "https://www.intamedia.ir/video-gallery/categoryid/1328",
              ),
            ),
          ],
        ),
      ),
      Showcase(
        isAdvertisement: true,
        groupedBanners: GroupedBanners(
          name: "سایر خدمات مالیاتی",
          bannersList: [
            BannerCase(
              bannerImg: File(
                uuid: "a0565245-029e-4029-935e-c7c6a3d93bb1",
                name: "1679343450677.webp",
              ),
              uid: "4:auth_bot".asUid(),
            ),
            BannerCase(
              uid: "3:57ad8f01-dce4-45f2-8a6a-995ebde9ca21".asUid(),
              bannerImg: File(
                uuid: "46c0ea16-af4c-47b2-a386-a57cdc204fb4",
                name: " 1669073291026.webp",
              ),
            ),
            BannerCase(
              uid: "4:quiztest_bot".asUid(),
              bannerImg: File(
                uuid: "3ce1cd63-2ce5-4402-ae15-f9209386cf0a",
                name: "1669073638421.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              uid: "4:ittax_bot".asUid(),
              bannerImg: File(
                uuid: "4476d1ff-a1ea-4fb6-8387-6b9af9feb398",
                name: "1669073684490.webp",
              ),
            ),
            BannerCase(
              bannerImg: File(
                uuid: "a50b746f-1d78-48e9-8de3-1a3c6e2ca8f9",
                name: "1679343398517.webp",
              ),
              uid: "4:callcenter_bot".asUid(),
            ),
          ],
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
        isAdvertisement: true,
        primary: true,
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
