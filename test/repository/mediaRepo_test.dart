// ignore_for_file: file_names

import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:deliver/box/meta.dart' as meta_box;
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/meta.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../constants/constants.dart';
import '../helper/test_helper.dart';

void main() {
  group('MediaRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group('fetchMediaMetaData -', () {
      test('When called should get MetaCounts', () async {
        final sdr = getAndRegisterServicesDiscoveryRepo();
        await MetaRepo().fetchMetaCountFromServer(testUid);
        verify(
          sdr.queryServiceClient.getMetaCounts(
            GetMetaCountsReq()..roomUid = testUid,
          ),
        );
        expect(
          await sdr.queryServiceClient.getMetaCounts(
            GetMetaCountsReq()..roomUid = testUid,
          ),
          GetMetaCountsRes(allMediaCount: Int64(1)),
        );
      });
      group('_updateMediaMetaData -', () {
        test('When called should get metaCount count from mediaMetaDataDao',
            () async {
          final mediaMetaDataDao =
              getAndRegisterMetaCountDataDao(metaCount: testMetaData);
          await MetaRepo().fetchMetaCountFromServer(testUid);
          verify(
            mediaMetaDataDao.getAsFuture(testUid.asString()),
          );
          expect(
            await mediaMetaDataDao.getAsFuture(testUid.asString()),
            testMetaData,
          );
        });
        test('When called should save metaCount to MediaMetaDataDao', () {
          saveMediaMetaDataTest(testMetaData);
        });
        group(
            'if metaCount count from mediaMetaDataDao is null should call fetchLastMedia -',
            () {
          test('When called should get room from room repo', () async {
            await _getRoomFromRoomDaoTest();
          });
          test(
              'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
              () async {
            await _nullRoomNeverCallFetchLastMedia();
          });
          group(
              'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
              () {
            test('When called should get fetch MetaList', () async {
              await _fetchMetaListFromServerTests(MetaGroup.MEDIA, 20);
            });

            group(
                'if fetched MetaList is not empty should call _saveFetchedMedias -',
                () {
              test('When called should save meta list to media dao -',
                  () async {
                await _saveFetchedMediasTests(MetaType.MEDIA);
              });
            });
            group(
                'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                () {
              test('When called should fetch MetaList with year-1', () async {
                await _fetchMoreMetas(
                  MetaGroup.MEDIA,
                  20,
                );
              });
            });
          });
        });
        group(
            'if metaCount count from mediaMetaDataDao is not null should call checkNeedFetchMedia -',
            () {
          group(
            'if mediasCount from oldMediaMetaData !=  allMediaCount from fetched meta count  should call fetchLastMedia(for group=media) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allMediaCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData,
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    mediasCount: 2,
                  ),
                  oldMediaMetaData: testMetaData,
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaListz', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.MEDIA,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allMediaCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.MEDIA,
                        getMetaCountsRes:
                            GetMetaCountsRes(allMediaCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.MEDIA,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.MEDIA,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allMediaCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
          group(
            'if voicesCount from oldMediaMetaData !=  allVoicesCount from fetched meta count  should call fetchLastMedia(for group=voice) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allVoicesCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    voicesCount: 1,
                    mediasCount: 0,
                  ),
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    voicesCount: 2,
                    mediasCount: 0,
                  ),
                  oldMediaMetaData: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    voicesCount: 1,
                    mediasCount: 0,
                  ),
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaList', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.VOICES,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allVoicesCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.AUDIO,
                        getMetaCountsRes:
                            GetMetaCountsRes(allVoicesCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.VOICES,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.VOICES,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allVoicesCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
          group(
            'if musicsCount from oldMediaMetaData !=  allMusicsCount from fetched meta count  should call fetchLastMedia(for group=music) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allMusicsCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    musicsCount: 1,
                    mediasCount: 0,
                  ),
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    musicsCount: 2,
                    mediasCount: 0,
                  ),
                  oldMediaMetaData: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    musicsCount: 1,
                    mediasCount: 0,
                  ),
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaList', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.MUSICS,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allMusicsCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.MUSIC,
                        getMetaCountsRes:
                            GetMetaCountsRes(allMusicsCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.MUSICS,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.MUSICS,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allMusicsCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
          group(
            'if filesCount from oldMediaMetaData !=  allFilesCount from fetched meta count  should call fetchLastMedia(for group=file) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allFilesCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    filesCount: 1,
                    mediasCount: 0,
                  ),
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    filesCount: 2,
                    mediasCount: 0,
                  ),
                  oldMediaMetaData: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    filesCount: 1,
                    mediasCount: 0,
                  ),
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaList', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.FILES,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allFilesCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.FILE,
                        getMetaCountsRes:
                            GetMetaCountsRes(allFilesCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.FILES,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.FILES,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allFilesCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
          group(
            'if linkCount from oldMediaMetaData !=  allLinkCount from fetched meta count  should call fetchLastMedia(for group=link) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allLinksCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    linkCount: 1,
                    mediasCount: 0,
                  ),
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    linkCount: 2,
                    mediasCount: 0,
                  ),
                  oldMediaMetaData: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    linkCount: 1,
                    mediasCount: 0,
                  ),
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaList', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.LINKS,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allLinksCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.LINK,
                        getMetaCountsRes:
                            GetMetaCountsRes(allLinksCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.LINKS,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.LINKS,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allLinksCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
          group(
            'if callsCount from oldMediaMetaData !=  allCallsCount from fetched meta count  should call fetchLastMedia(for group=call) -',
            () {
              setUp(() {
                getAndRegisterServicesDiscoveryRepo(
                  GetMetaCountsRe: GetMetaCountsRes(allCallCount: Int64(2)),
                );
                getAndRegisterMetaCountDataDao(
                  metaCount: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    callsCount: 1,
                    mediasCount: 0,
                  ),
                );
              });
              test('When called should save metaCount to MediaMetaDataDao', () {
                saveMediaMetaDataTest(
                  testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    callsCount: 2,
                    mediasCount: 0,
                  ),
                  oldMediaMetaData: testMetaData.copyWith(
                    lastUpdateTime: DateTime(2000).millisecondsSinceEpoch,
                    callsCount: 1,
                    mediasCount: 0,
                  ),
                );
              });

              test('When called should get room from room repo', () async {
                await _getRoomFromRoomDaoTest();
              });
              test(
                  'When called should get should get room from room repo and if room is  null or last message id null should not fetchLastMedia',
                  () async {
                await _nullRoomNeverCallFetchLastMedia();
              });
              group(
                'if room  is not  null and last message id is not null should  call _fetchLastMedia -',
                () {
                  test('When called should get fetch MetaList', () async {
                    await _fetchMetaListFromServerTests(
                      MetaGroup.CALLS,
                      1,
                      getMetaCountsRes:
                          GetMetaCountsRes(allCallCount: Int64(2)),
                    );
                  });

                  group(
                      'if fetched MetaList is not empty should call _saveFetchedMedias -',
                      () {
                    test('When called should save meta list to media dao -',
                        () async {
                      await _saveFetchedMediasTests(
                        MetaType.CALL,
                        getMetaCountsRes:
                            GetMetaCountsRes(allCallCount: Int64(2)),
                        limit: 1,
                        metaGroup: MetaGroup.CALLS,
                      );
                    });
                  });
                  group(
                      'if fetched MetaList is empty should call _fetchLastMedia with year-1 -',
                      () {
                    test('When called should fetch MetaList with year-1',
                        () async {
                      await _fetchMoreMetas(
                        MetaGroup.CALLS,
                        1,
                        GetMetaCountsRe:
                            GetMetaCountsRes(allCallCount: Int64(2)),
                      );
                    });
                  });
                },
              );
            },
          );
        });
      });
    });
    group('getMediaMetaData -', () {
      test('When called should get metaCount ', () async {
        final mediasMetaDataDao =
            getAndRegisterMetaCountDataDao(metaCount: testMetaData);

        expect(
          await MetaRepo().getMetaCount(testUid.asString()),
          testMetaData,
        );
        verify(mediasMetaDataDao.getAsFuture(testUid.asString()));
      });
    });
    group('getMediasMetaDataCountFromDB -', () {
      test(
          'When called should get MediasMetaDataCountFromDB from MediasMetaDataDao ',
          () async {
        final mediasMetaDataDao =
            getAndRegisterMetaCountDataDao(metaCount: testMetaData);
        MetaRepo().getMetaCountFromDBAsStream(testUid).listen((event) {
          expect(event, testMetaData);
        });
        verify(mediasMetaDataDao.get(testUid.asString()));
      });
    });
    group('findFetchedMediaType -', () {
      test(
          'When called if metaGroup= MetaGroup.MEDIA should return MediaType.MEDIA',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.MEDIA),
          MetaType.MEDIA,
        );
      });
      test(
          'When called if metaGroup= MetaGroup.LINKS should return MediaType.LINKS',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.LINKS),
          MetaType.LINK,
        );
      });
      test(
          'When called if metaGroup= MetaGroup.CALLS should return MediaType.CALLS',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.CALLS),
          MetaType.CALL,
        );
      });
      test(
          'When called if metaGroup= MetaGroup.FILES should return MediaType.FILES',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.FILES),
          MetaType.FILE,
        );
      });
      test(
          'When called if metaGroup= MetaGroup.AUDIO should return MediaType.VOICES',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.VOICES),
          MetaType.AUDIO,
        );
      });
      test(
          'When called if metaGroup= MetaGroup.MUSICS should return MediaType.MUSICS',
          () async {
        expect(
          MetaRepo().findFetchedMetaType(MetaGroup.MUSICS),
          MetaType.MUSIC,
        );
      });
    });
    group('convertType -', () {
      test(
          'When called if mediaType=MediaType.MEDIA should return MetaGroup.MEDIA',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.MEDIA),
          MetaGroup.MEDIA,
        );
      });
      test(
          'When called if mediaType=MediaType.FILE should return MetaGroup.FILE',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.FILE),
          MetaGroup.FILES,
        );
      });
      test(
          'When called if mediaType=MediaType.CALLS should return MetaGroup.CALLS',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.CALL),
          MetaGroup.CALLS,
        );
      });
      test(
          'When called if mediaType=MediaType.MUSIC should return MetaGroup.MUSIC',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.MUSIC),
          MetaGroup.MUSICS,
        );
      });
      test(
          'When called if mediaType=MediaType.VOICES should return MetaGroup.VOICES',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.AUDIO),
          MetaGroup.VOICES,
        );
      });
      test(
          'When called if mediaType=MediaType.LINKS should return MetaGroup.LINKS',
          () async {
        expect(
          MetaRepo().convertMetaTypeToMetaGroup(MetaType.LINK),
          MetaGroup.LINKS,
        );
      });
    });
    group('getMediaPage -', () {
      final meta = meta_box.Meta(
        createdOn: 0,
        json: "",
        roomId: testUid.asString(),
        messageId: 0,
        type: MetaType.FILE,
        createdBy: testUid.asString(),
        index: 0,
      );
      setUp(
        () => {
          getAndRegisterMetaDao(
            getMediaType: MetaType.FILE,
            getMetaPage: [meta],
          )
        },
      );

      test('When called should get media from media dao by type and room uid',
          () async {
        final metaDao = getAndRegisterMetaDao(
          getMediaType: MetaType.FILE,
          getMetaPage: [meta],
        );
        await MetaRepo().getMetaPage(testUid.asString(), MetaType.FILE, 0, 0);
        verify(metaDao.getMetaPage(testUid.asString(), MetaType.FILE, 0));
      });
      test(
          'When called should get media from media dao by type and room uid and if mediaList.length > index should return media list',
          () async {
        expect(
          await MetaRepo().getMetaPage(testUid.asString(), MetaType.FILE, 0, 0),
          [meta],
        );
      });
      test(
        'When called should get media from media dao by type and room uid and if mediaList.length <= index should get more media from server',
        () async {
          final sdr = getAndRegisterServicesDiscoveryRepo(
            metaList: [Meta(index: Int64(5), sender: testUid)],
            fetchMetaListTime: 0,
            fetchMetaListLimit: 40,
            fetchMetaListGroup: MetaGroup.FILES,
          );
          final value = await MetaRepo()
              .getMetaPage(testUid.asString(), MetaType.FILE, 0, 1);
          verify(
            sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64()
                ..group = MetaGroup.FILES
                ..limit = 40
                ..direction = QueryDirection.BACKWARD_INCLUSIVE,
            ),
          );
          expect(value, [
            meta_box.Meta(
              createdOn: 0,
              json: jsonEncode({}),
              roomId: testUid.asString(),
              messageId: 0,
              type: MetaType.FILE,
              createdBy: testUid.asString(),
              index: 5,
            ),
          ]);
        },
      );
    });
    group('fetchMoreMedia -', () {
      test('When called if pointer==null should get the room from roomDao',
          () async {
        final roomRepo = getAndRegisterRoomRepo(
          room: testRoom.copyWith(
            lastMessage: testMessage,
          ),
        );
        getAndRegisterServicesDiscoveryRepo(
          metaList: [Meta(index: Int64())],
          fetchMetaListLimit: 40,
          fetchMetaListGroup: MetaGroup.MEDIA,
        );
        await MetaRepo().getMetasPageFromServer(
          testUid.asString(),
          0,
          MetaGroup.MEDIA,
        );
        verify(
          roomRepo.getRoom(testUid.asString()),
        );
        expect(
          await roomRepo.getRoom(testUid.asString()),
          testRoom.copyWith(
            lastMessage: testMessage,
          ),
        );
      });
      test(
          'When called if pointer==null should get the room and if room is not null and last message is not null should get meta list with pointer=last message time',
          () async {
        getAndRegisterRoomRepo(
          room: testRoom.copyWith(
            lastMessage: testMessage,
          ),
        );
        final sdr = getAndRegisterServicesDiscoveryRepo(
          metaList: [Meta(index: Int64())],
          fetchMetaListLimit: 40,
          fetchMetaListGroup: MetaGroup.MUSICS,
          fetchingDirectionType: QueryDirection.FORWARD_INCLUSIVE,
        );
        await MetaRepo().getMetasPageFromServer(
          testUid.asString(),
          0,
          MetaGroup.MUSICS,
        );
        verify(
          sdr.queryServiceClient.fetchMetaList(
            FetchMetaListReq()
              ..roomUid = testUid
              ..pointer = Int64(testMessage.time)
              ..group = MetaGroup.MUSICS
              ..limit = 40
              ..direction = QueryDirection.FORWARD_INCLUSIVE,
          ),
        );
        expect(
          (await sdr.queryServiceClient.fetchMetaList(
            FetchMetaListReq()
              ..roomUid = testUid
              ..pointer = Int64(testMessage.time)
              ..group = MetaGroup.MUSICS
              ..limit = 40
              ..direction = QueryDirection.FORWARD_INCLUSIVE,
          ))
              .metaList,
          [Meta(index: Int64())],
        );
      });
      test(
          'When called if pointer==null should get the room and if room is  null or last message is not null should get meta list with pointer=clock.now',
          () {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final sdr = getAndRegisterServicesDiscoveryRepo(
            metaList: [Meta(index: Int64())],
            fetchMetaListLimit: 40,
            fetchMetaListTime: DateTime(2000).millisecondsSinceEpoch,
            fetchMetaListGroup: MetaGroup.MUSICS,
            fetchingDirectionType: QueryDirection.FORWARD_INCLUSIVE,
          );
          await MetaRepo().getMetasPageFromServer(
            testUid.asString(),
            0,
            MetaGroup.MUSICS,
          );
          verify(
            sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
                ..group = MetaGroup.MUSICS
                ..limit = 40
                ..direction = QueryDirection.FORWARD_INCLUSIVE,
            ),
          );
          expect(
            (await sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
                ..group = MetaGroup.MUSICS
                ..limit = 40
                ..direction = QueryDirection.FORWARD_INCLUSIVE,
            ))
                .metaList,
            [Meta(index: Int64())],
          );
        });
      });
      test(
        'When called if pointer!=null should never get the room and should get meta list with pointer',
        () async {
          final roomRepo = getAndRegisterRoomRepo();
          final sdr = getAndRegisterServicesDiscoveryRepo(
            metaList: [Meta(index: Int64())],
            fetchMetaListLimit: 40,
            fetchMetaListTime: 1990,
            fetchMetaListGroup: MetaGroup.VOICES,
            fetchingDirectionType: QueryDirection.FORWARD_INCLUSIVE,
          );
          await MetaRepo().getMetasPageFromServer(
            testUid.asString(),
            0,
            MetaGroup.VOICES,
          );

          verifyNever(
            roomRepo.getRoom(testUid.asString()),
          );
          verify(
            sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(1990)
                ..group = MetaGroup.VOICES
                ..limit = 40
                ..direction = QueryDirection.FORWARD_INCLUSIVE,
            ),
          );
          expect(
            (await sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(1990)
                ..group = MetaGroup.VOICES
                ..limit = 40
                ..direction = QueryDirection.FORWARD_INCLUSIVE,
            ))
                .metaList,
            [Meta(index: Int64())],
          );
        },
      );
      test(
        'When called should get the meta list and if meta list is not empty should save the meta list',
        () async {
          final metaDao = getAndRegisterMetaDao();
          getAndRegisterRoomRepo(
            room: testRoom.copyWith(
              lastMessage: testMessage,
            ),
          );
          getAndRegisterServicesDiscoveryRepo(
            metaList: [Meta(index: Int64(5), sender: testUid)],
            fetchMetaListLimit: 40,
            fetchMetaListGroup: MetaGroup.MUSICS,
            fetchingDirectionType: QueryDirection.FORWARD_INCLUSIVE,
          );
          await MetaRepo().getMetasPageFromServer(
            testUid.asString(),
            0,
            MetaGroup.MUSICS,
          );
          verify(
            metaDao.saveMeta(
              meta_box.Meta(
                createdOn: 0,
                messageId: 0,
                index: 5,
                type: MetaType.MUSIC,
                createdBy: testUid.asString(),
                json: jsonEncode({}),
                roomId: testUid.asString(),
              ),
            ),
          );
        },
      );
      test(
        'When called should get the meta list and if meta list is  empty should call the function with pointer=year-1',
        () async {
          getAndRegisterRoomRepo(
            room: testRoom.copyWith(
              lastMessage: testMessage.copyWith(
                time: DateTime(2000).millisecondsSinceEpoch,
              ),
            ),
          );
          final sdr = getAndRegisterServicesDiscoveryRepo(
            metaList: [Meta(index: Int64())],
            fetchMetaListTime: DateTime(1999, 12, 30).millisecondsSinceEpoch,
            fetchMetaListLimit: 40,
            fetchMetaListGroup: MetaGroup.CALLS,
          );
          await MetaRepo().getMetasPageFromServer(
            testUid.asString(),
            0,
            MetaGroup.CALLS,
          );
          verify(
            sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
                ..group = MetaGroup.CALLS
                ..limit = 40
                ..direction = QueryDirection.BACKWARD_INCLUSIVE,
            ),
          );
          expect(
            (await sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
                ..group = MetaGroup.CALLS
                ..limit = 40
                ..direction = QueryDirection.BACKWARD_INCLUSIVE,
            ))
                .metaList,
            [],
          );
          verify(
            sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(
                  DateTime(1999, 12, 30).millisecondsSinceEpoch,
                )
                ..group = MetaGroup.CALLS
                ..limit = 40
                ..direction = QueryDirection.BACKWARD_INCLUSIVE,
            ),
          );
          expect(
            (await sdr.queryServiceClient.fetchMetaList(
              FetchMetaListReq()
                ..roomUid = testUid
                ..pointer = Int64(
                  DateTime(1999, 12, 30).millisecondsSinceEpoch,
                )
                ..group = MetaGroup.CALLS
                ..limit = 40
                ..direction = QueryDirection.BACKWARD_INCLUSIVE,
            ))
                .metaList,
            [Meta(index: Int64())],
          );
        },
      );
    });
    group('findFetchedMediaJson -', () {
      test('When called if meta has link should return json with link', () {
        final meta = Meta(link: Link(urls: ["https://google.com"]));
        expect(
          MetaRepo().findFetchedMetaJson(
            meta,
          ),
          meta.link.writeToJson(),
        );
      });
      test('When called if meta has File should return json with file', () {
        expect(
          MetaRepo().findFetchedMetaJson(
            Meta(file: testFile),
          ),
          jsonEncode({
            "uuid": "94667220000013418",
            "size": 0,
            "type": "audio/mp4",
            "name": "test",
            "caption": "test",
            "width": 0,
            "height": 0,
            "blurHash": "",
            "duration": 0.0,
            "audioWaveData": []
          }),
        );
      });
      test('When called if meta has call should return json with call', () {
        expect(
          MetaRepo().findFetchedMetaJson(Meta(callInfo: testCallInfo)),
          testCallInfo.writeToJson(),
        );
      });
    });
    group('updateMedia -', () {
      final message = testMessage.copyWith(
        id: 0,
        json: (File()
              ..uuid = "94667220000013418"
              ..caption = "test"
              ..width = 0
              ..height = 0
              ..type = "audio/mp4"
              ..size = Int64()
              ..name = "test"
              ..duration = 0)
            .writeToJson(),
      );
      test('When called should get old media from media dao', () async {
        final metaDao = getAndRegisterMetaDao();
        await MetaRepo().updateMeta(message);
        verify(metaDao.getIndexOfMetaFromMessageId(testMessage.roomUid, 0));
      });
      test(
          "When called should get old media from media dao and if old media is null should never update media",
          () async {
        final metaDao = getAndRegisterMetaDao(IndexOfMedia: null);
        await MetaRepo().updateMeta(message);
        verifyNever(metaDao.saveMeta(any));
      });
      test(
          "When called should get old media from media dao and if old media is not null should update media",
          () {
        withClock(Clock.fixed(DateTime(2000)), () async {
          final metaDao = getAndRegisterMetaDao(IndexOfMedia: 2);
          await MetaRepo().updateMeta(message);
          verify(
            metaDao.saveMeta(
              meta_box.Meta(
                createdOn: clock.now().millisecondsSinceEpoch,
                json: jsonEncode({
                  "uuid": "94667220000013418",
                  "size": 0,
                  "type": "audio/mp4",
                  "name": "test",
                  "caption": "test",
                  "width": 0,
                  "height": 0,
                  "blurHash": "",
                  "duration": 0.0,
                  "audioWaveData": []
                }),
                roomId: testMessage.roomUid,
                messageId: 0,
                type: MetaType.MUSIC,
                createdBy: testMessage.from,
                index: 2,
              ),
            ),
          );
        });
      });
    });
  });
}

void saveMediaMetaDataTest(
  MetaCount metaData, {
      MetaCount? oldMediaMetaData,
}) {
  withClock(Clock.fixed(DateTime(2000)), () async {
    final mediaMetaDataDao = getAndRegisterMetaCountDataDao(
      metaCount: oldMediaMetaData,
    );
    await MetaRepo().fetchMetaCountFromServer(testUid);
    verify(
      mediaMetaDataDao.save(metaData),
    );
  });
}

Future<void> _fetchMoreMetas(
  MetaGroup metaGroup,
  int limit, {
  GetMetaCountsRes? GetMetaCountsRe,
}) async {
  getAndRegisterRoomRepo(
    room: testRoom.copyWith(
      lastMessage: testMessage.copyWith(
        time: DateTime(2000).millisecondsSinceEpoch,
      ),
    ),
  );
  final sdr = getAndRegisterServicesDiscoveryRepo(
    metaList: [Meta(index: Int64())],
    fetchMetaListTime: DateTime(1999, 12, 30).millisecondsSinceEpoch,
    GetMetaCountsRe: GetMetaCountsRe,
    fetchMetaListLimit: limit,
    fetchMetaListGroup: metaGroup,
  );
  await MetaRepo().fetchMetaCountFromServer(testUid);
  verify(
    sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ),
  );
  expect(
    (await sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(DateTime(2000).millisecondsSinceEpoch)
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ))
        .metaList,
    [],
  );
  verify(
    sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(
          DateTime(1999, 12, 30).millisecondsSinceEpoch,
        )
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ),
  );
  expect(
    (await sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(
          DateTime(1999, 12, 30).millisecondsSinceEpoch,
        )
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ))
        .metaList,
    [Meta(index: Int64())],
  );
}

Future<void> _fetchMetaListFromServerTests(
  MetaGroup metaGroup,
  int limit, {
  GetMetaCountsRes? getMetaCountsRes,
}) async {
  getAndRegisterRoomRepo(
    room: testRoom.copyWith(
      lastMessage: testMessage,
    ),
  );
  final sdr = getAndRegisterServicesDiscoveryRepo(
    metaList: [Meta(index: Int64())],
    fetchMetaListLimit: limit,
    fetchMetaListGroup: metaGroup,
    GetMetaCountsRe: getMetaCountsRes,
  );
  await MetaRepo().fetchMetaCountFromServer(testUid);
  verify(
    sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(testMessage.time)
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ),
  );
  expect(
    (await sdr.queryServiceClient.fetchMetaList(
      FetchMetaListReq()
        ..roomUid = testUid
        ..pointer = Int64(testMessage.time)
        ..group = metaGroup
        ..limit = limit
        ..direction = QueryDirection.BACKWARD_INCLUSIVE,
    ))
        .metaList,
    [Meta(index: Int64())],
  );
}

Future<void> _saveFetchedMediasTests(
  MetaType mediaType, {
  MetaGroup? metaGroup,
  int? limit,
  GetMetaCountsRes? getMetaCountsRes,
}) async {
  final metaDao = getAndRegisterMetaDao();
  getAndRegisterRoomRepo(
    room: testRoom.copyWith(
      lastMessage: testMessage,
    ),
  );
  getAndRegisterServicesDiscoveryRepo(
    metaList: [
      Meta(
        index: Int64(),
        messageId: Int64(),
        createdOn: Int64(),
        sender: testUid,
      )
    ],
    fetchMetaListLimit: limit,
    fetchMetaListGroup: metaGroup,
    GetMetaCountsRe: getMetaCountsRes,
  );
  await MetaRepo().fetchMetaCountFromServer(testUid);

  verify(
    metaDao.saveMeta(
      meta_box.Meta(
        createdOn: 0,
        messageId: 0,
        index: 0,
        type: mediaType,
        createdBy: testUid.asString(),
        json: jsonEncode({}),
        roomId: testUid.asString(),
      ),
    ),
  );
}

Future<void> _nullRoomNeverCallFetchLastMedia() async {
  final sdr = getAndRegisterServicesDiscoveryRepo();
  await MetaRepo().fetchMetaCountFromServer(testUid);
  verifyNever(
    sdr.queryServiceClient.fetchMetaList(any),
  );
}

Future<void> _getRoomFromRoomDaoTest() async {
  final roomRepo = getAndRegisterRoomRepo();
  await MetaRepo().fetchMetaCountFromServer(testUid);
  verify(
    roomRepo.getRoom(testUid.asString()),
  );
  expect(
    await roomRepo.getRoom(testUid.asString()),
    testRoom,
  );
}
