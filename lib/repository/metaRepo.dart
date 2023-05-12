// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:deliver/box/dao/meta_count_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/meta.pb.dart' as meta_pb;
import 'package:deliver_public_protocol/pub/v1/models/meta.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart' as query_pb;
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';

class MetaRepo {
  final _logger = GetIt.I.get<Logger>();
  final _metaDao = GetIt.I.get<MetaDao>();
  final _metaCountDao = GetIt.I.get<MetaCountDao>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  Future<MetaCount?> fetchMetaCountFromServer(
    Uid uid,
  ) async {
    try {
      final metaCountsResponse = await _sdr.queryServiceClient.getMetaCounts(
        GetMetaCountsReq()..roomUid = uid,
        options: CallOptions(
          timeout: const Duration(seconds: 2),
        ),
      );
      unawaited(_roomDao.updateRoom(uid: uid.asString(),shouldUpdateMediaCount: false));
      await fetchDeletedIndexFromServerIFNeeded(
        uid.asString(),
        metaCountsResponse.allMediaDeletedCount.toInt(),
      );
      return _updateMetaCount(
        uid,
        metaCountsResponse,
      );
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<void> fetchDeletedIndexFromServerIFNeeded(
    String roomUid,
    int deletedCount,
  ) async {
    final shouldFetchDeletedIndex =
        await _metaDao.shouldFetchMetaDeletedIndex(roomUid);
    if (shouldFetchDeletedIndex && deletedCount > 0) {
      try {
        final deletedIndex =
            await _sdr.queryServiceClient.fetchMetaDeletedIndexes(
          FetchMetaDeletedIndexesReq()
            ..group = MetaGroup.MEDIA
            ..roomUid = roomUid.asUid()
            ..pointer = Int64()
            ..limit = deletedCount
            ..direction = QueryDirection.FORWARD_INCLUSIVE,
          options: CallOptions(
            timeout: const Duration(seconds: 2),
          ),
        );
        await _metaDao.setShouldFetchMetaDeletedIndex(roomUid);
        if (deletedIndex.deletedIndexes.isNotEmpty) {
          await saveMetaDeletedIndex(
            deletedIndex.deletedIndexes,
            roomUid,
            MetaType.MEDIA,
          );
        }
      } catch (e) {
        _logger.e(e);
      }
    }
  }

  Future<void> saveMetaDeletedIndex(
    List<Int64> indexList,
    String roomUid,
    MetaType type,
  ) async {
    for (final index in indexList) {
      await _metaDao.saveMetaDeletedIndex(
        roomUid,
        index.toInt(),
      );
    }
  }

  void saveMetaCount(MetaCount metaCount) {
    _metaCountDao.save(metaCount);
  }

  Future<List<Meta>?> getAudioAutoPlayListPageByMessageId({
    required int messageId,
    required String roomUid,
    MetaType type = MetaType.AUDIO,
  }) async {
    final index = await _metaDao.getIndexOfMetaFromMessageId(
      roomUid,
      messageId,
    );

    if (index != null) {
      int? metaCount;
      if (type == MetaType.AUDIO) {
        metaCount = (await getMetaCount(roomUid))?.voicesCount;
      } else if (type == MetaType.MUSIC) {
        metaCount = (await getMetaCount(roomUid))?.musicsCount;
      }
      if (metaCount != null && index != metaCount) {
        final page = (index / META_PAGE_SIZE).floor();
        final metaList = (await _metaDao.getMetaPage(
          roomUid,
          type,
          page,
          offset: index + 1,
          resultSize: metaCount - index,
        ));
        return metaList.where((element) => element.index > index).toList();
      }
    }
    return _getMetaAutoPlayListPageFromServer(
      roomUid: roomUid,
      messageId: messageId,
      type: type,
      index: index,
    );
  }

  bool isMessageContainMeta(Message message) {
    if (message.type == MessageType.FILE || message.type == MessageType.CALL) {
      return true;
    } else if (message.type == MessageType.TEXT) {
      return isTextContainUrlFeature(
        message.json.toText().text,
      );
    }
    return false;
  }

  Future<List<Meta>?> _getMetaAutoPlayListPageFromServer({
    required int messageId,
    required String roomUid,
    MetaType type = MetaType.AUDIO,
    int? index,
  }) async {
    final metaIndex = index ??
        await getMetaIndexFromMessageId(
          metaGroup: convertMetaTypeToMetaGroup(type),
          messageId: messageId,
          roomUid: roomUid,
        );
    if (metaIndex != null) {
      final page = (metaIndex / META_PAGE_SIZE).floor();
      final metas = await getMetasPageFromServer(
        roomUid,
        page,
        convertMetaTypeToMetaGroup(type),
      );
      return metas?.where((element) => element.index > metaIndex).toList();
    }
    return null;
  }

  Future<int?> getMetaIndexFromMessageId({
    required int messageId,
    required String roomUid,
    required MetaGroup metaGroup,
  }) async {
    var reTryFailedFetch = 3;
    while (reTryFailedFetch > 0) {
      try {
        reTryFailedFetch--;
        final metaIndex = await _sdr.queryServiceClient.fetchMessageMetaIndex(
          FetchMessageMetaIndexReq()
            ..group = metaGroup
            ..messageId = Int64(messageId)
            ..roomUid = roomUid.asUid(),
        );
        return metaIndex.index.toInt();
      } catch (e) {
        _logger.e(e);
      }
    }
    return null;
  }

  Future<MetaCount?> getMetaCount(String roomUid) async =>
      _metaCountDao.getAsFuture(roomUid);

  Future<MetaCount> _updateMetaCount(
    Uid roomUid,
    query_pb.GetMetaCountsRes metaCountsResponse,
  ) async {
    return _saveMetaCount(roomUid.asString(), metaCountsResponse);
  }

  Future<MetaCount> _saveMetaCount(
    String roomUid,
    GetMetaCountsRes metaCountsRes,
  ) async {
    final metaCount = MetaCount(
      roomId: roomUid,
      mediasCount: metaCountsRes.allMediaCount.toInt(),
      callsCount: metaCountsRes.allCallCount.toInt(),
      filesCount: metaCountsRes.allFilesCount.toInt(),
      voicesCount: metaCountsRes.allVoicesCount.toInt(),
      musicsCount: metaCountsRes.allMusicsCount.toInt(),
      linkCount: metaCountsRes.allLinksCount.toInt(),
      allCallDeletedCount: metaCountsRes.allCallDeletedCount.toInt(),
      allFilesDeletedCount: metaCountsRes.allFilesDeletedCount.toInt(),
      allLinksDeletedCount: metaCountsRes.allLinksDeletedCount.toInt(),
      allMediaDeletedCount: metaCountsRes.allMediaDeletedCount.toInt(),
      allMusicsDeletedCount: metaCountsRes.allMusicsDeletedCount.toInt(),
      allVoicesDeletedCount: metaCountsRes.allVoicesDeletedCount.toInt(),
      lastUpdateTime: clock.now().millisecondsSinceEpoch,
    );
    unawaited(
      _metaCountDao.save(
        metaCount,
      ),
    );
    return metaCount;
  }

  Stream<MetaCount?> getMetaCountFromDBAsStream(Uid roomId) =>
      _metaCountDao.get(roomId.asString());

  Future<List<Meta>> _saveFetchedMetas(
    List<meta_pb.Meta> fetchedMetaList,
    Uid roomUid,
    MetaGroup metaGroup,
  ) async {
    final metaList = <Meta>[];
    for (final meta in fetchedMetaList) {
      final type = findFetchedMetaType(metaGroup);
      final json = findFetchedMetaJson(meta);
      final insertedMeta = Meta(
        createdOn: meta.createdOn.toInt(),
        createdBy: meta.sender.asString(),
        messageId: meta.messageId.toInt(),
        type: type,
        roomId: roomUid.asString(),
        json: json,
        index: meta.index.toInt(),
      );
      metaList.add(insertedMeta);
      unawaited(_metaDao.saveMeta(insertedMeta));
    }
    return metaList;
  }

  MetaType findFetchedMetaType(
    MetaGroup metaGroup,
  ) {
    switch (metaGroup) {
      case MetaGroup.CALLS:
        return MetaType.CALL;
      case MetaGroup.FILES:
        return MetaType.FILE;
      case MetaGroup.LINKS:
        return MetaType.LINK;
      case MetaGroup.MEDIA:
        return MetaType.MEDIA;
      case MetaGroup.MUSICS:
        return MetaType.MUSIC;
      case MetaGroup.VOICES:
        return MetaType.AUDIO;
    }
    return MetaType.NOT_SET;
  }

  MetaGroup convertMetaTypeToMetaGroup(MetaType metaType) {
    switch (metaType) {
      case MetaType.MEDIA:
        return MetaGroup.MEDIA;
      case MetaType.FILE:
        return MetaGroup.FILES;
      case MetaType.AUDIO:
        return MetaGroup.VOICES;
      case MetaType.MUSIC:
        return MetaGroup.MUSICS;
      case MetaType.CALL:
        return MetaGroup.CALLS;
      case MetaType.LINK:
        return MetaGroup.LINKS;
      case MetaType.NOT_SET:
        return MetaGroup.FILES;
    }
  }

  final _completerMap = <String, Completer<List<Meta>?>>{};

  Future<Meta?> getAndCacheMetaPage(
    int index,
    MetaType metaType,
    String roomUid,
    Map<int, Meta> metaCache,
  ) async {
    if (metaCache.values.toList().isNotEmpty && metaCache[index] != null) {
      return metaCache[index];
    } else {
      final page = (index / META_PAGE_SIZE).floor();
      final res = await getMetaPage(
        roomUid,
        metaType,
        page,
        index,
      );
      if (res != null) {
        for (final meta in res) {
          metaCache[meta.index] = meta;
        }
      }
      return metaCache[index];
    }
  }

  Future<List<Meta>?> getMetaPage(
    String roomUid,
    MetaType type,
    int page,
    int index, {
    int resultSize = META_PAGE_SIZE,
  }) async {
    var completer = _completerMap["$roomUid-$type-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["$roomUid-$type-$page"] = completer;
    final metaList =
        await _metaDao.getMetaPage(roomUid, type, page, resultSize: resultSize);
    if (metaList.any((element) => element.index == index)) {
      completer.complete(metaList);
    } else {
      completer.complete(
        await getMetasPageFromServer(
          roomUid,
          page,
          convertMetaTypeToMetaGroup(type),
        ),
      );
    }
    return completer.future;
  }

  Future<List<Meta>?> getMetasPageFromServer(
    String roomUid,
    int page,
    MetaGroup metaGroup, {
    int limit = META_PAGE_SIZE,
  }) async {
    try {
      final result = await _sdr.queryServiceClient.fetchMetaList(
        FetchMetaListReq()
          ..pointer = Int64(page * limit)
          ..group = metaGroup
          ..roomUid = roomUid.asUid()
          ..limit = limit + 1
          ..direction = QueryDirection.FORWARD_INCLUSIVE,
      );

      if (result.metaList.isNotEmpty) {
        return _saveFetchedMetas(result.metaList, roomUid.asUid(), metaGroup);
      }

      return null;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  String findFetchedMetaJson(meta_pb.Meta meta) {
    if (meta.hasLink()) {
      return meta.link.writeToJson();
    } else if (meta.hasFile()) {
      return meta.file.writeToJson();
    } else if (meta.hasCallInfo()) {
      return meta.callInfo.writeToJson();
    }
    return jsonEncode({});
  }

  Future<void> updateMeta(Message message) async {
    if (isMessageContainMeta(message)) {
      final oldMetaIndex = await _metaDao.getIndexOfMetaFromMessageId(
        message.roomUid,
        message.id!,
      );
      final metaType = findMetaTypeFromMessageData(message);
      final String json;
      if (metaType == MetaType.LINK) {
        json = meta_pb.Link(
          urls: getLinkBlocksFromText(message.json.toText().text)
              .map((e) => e.text),
        ).writeToJson();
      } else {
        json = message.json;
      }
      if (oldMetaIndex != null) {
        await _metaDao.saveMeta(
          Meta(
            createdOn: clock.now().millisecondsSinceEpoch,
            json: json,
            roomId: message.roomUid,
            messageId: message.id!,
            type: metaType,
            createdBy: message.from,
            index: oldMetaIndex,
          ),
        );
      }
    }
  }

  MetaType findMetaTypeFromMessageData(Message message) {
    if (message.type == MessageType.CALL) {
      return MetaType.CALL;
    } else if (message.type == MessageType.FILE) {
      return message.json.toFile().findMetaTypeFromFileProto();
    } else if (message.type == MessageType.TEXT &&
        isTextContainUrlFeature(
          message.json.toText().text,
        )) {
      return MetaType.LINK;
    } else {
      return MetaType.NOT_SET;
    }
  }

  Future<void> addDeletedMetaIndexFromMessage(Message message) async {
    if (isMessageContainMeta(message)) {
      final oldMetaIndex = await _metaDao.getIndexOfMetaFromMessageId(
        message.roomUid,
        message.id!,
      );
      final metaType = findMetaTypeFromMessageData(message);
      if (oldMetaIndex != null) {
        await _metaDao.saveMetaDeletedIndex(
          message.roomUid,
          oldMetaIndex,
        );

        await _metaDao.deleteMeta(
          message.roomUid,
          oldMetaIndex,
          metaType,
        );
      } else {
        final metaIndex = await getMetaIndexFromMessageId(
          messageId: message.id!,
          roomUid: message.roomUid,
          metaGroup: convertMetaTypeToMetaGroup(metaType),
        );
        if (metaIndex != null) {
          if (metaIndex != 0) {
            await _metaDao.saveMeta(
              Meta(
                index: metaIndex,
                createdOn: clock.now().millisecondsSinceEpoch,
                createdBy: message.from,
                json: EMPTY_MESSAGE,
                roomId: message.roomUid,
                messageId: message.id!,
                type: metaType,
              ),
            );
          }
        } else {
          await _metaDao.setShouldFetchMetaDeletedIndex(
            message.roomUid,
            shouldFetchDeletedIndex: true,
          );
          await _roomDao.updateRoom(
            uid: message.roomUid,
            shouldUpdateMediaCount: true,
          );
        }
      }
    }
  }
}
