// ignore_for_file: file_names

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart' as query_pb;
import 'package:deliver_public_protocol/pub/v1/models/media.pb.dart'
    as media_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

class MediaQueryRepo {
  final _logger = GetIt.I.get<Logger>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  getMediaMetaDataReq(Uid uid) async {
    try {
      var mediaResponse = await _queryServiceClient
          .getMediaMetadata(GetMediaMetadataReq()..with_1 = uid);
      updateMediaMetaData(uid, mediaResponse);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future updateMediaMetaData(
      Uid roomUid, query_pb.GetMediaMetadataRes mediaResponse) async {
    MediaMetaData? oldMetaMediaData =
        await _mediaMetaDataDao.getAsFuture(roomUid.asString());
    if (oldMetaMediaData != null) {
      checkNeedFetchMedia(roomUid.asString(), oldMetaMediaData, mediaResponse);
    } else {
      //get all image  for build  first tab
      fetchLastMedia(
          roomUid.asString(),
          0,
          query_pb.FetchMediasReq_MediaType.IMAGES,
          mediaResponse.allImagesCount.toInt());
    }

    _mediaMetaDataDao.save(MediaMetaData(
        roomId: roomUid.asString(),
        imagesCount: mediaResponse.allImagesCount.toInt(),
        videosCount: mediaResponse.allVideosCount.toInt(),
        filesCount: mediaResponse.allFilesCount.toInt(),
        documentsCount: mediaResponse.allDocumentsCount.toInt(),
        audiosCount: mediaResponse.allAudiosCount.toInt(),
        musicsCount: mediaResponse.allMusicsCount.toInt(),
        linkCount: mediaResponse.allLinksCount.toInt(),
        lastUpdateTime: DateTime.now().millisecondsSinceEpoch));
  }

  Future checkNeedFetchMedia(String roomUid, MediaMetaData oldMediaMetaData,
      GetMediaMetadataRes newMetaData) async {
    if (oldMediaMetaData.imagesCount != newMetaData.allImagesCount.toInt()) {
      await fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.imagesCount,
          query_pb.FetchMediasReq_MediaType.IMAGES,
          newMetaData.allImagesCount.toInt());
      _mediaMetaDataDao.save(MediaMetaData(
          roomId: roomUid,
          imagesCount: newMetaData.allImagesCount.toInt(),
          videosCount: newMetaData.allVideosCount.toInt(),
          filesCount: newMetaData.allFilesCount.toInt(),
          documentsCount: newMetaData.allDocumentsCount.toInt(),
          audiosCount: newMetaData.allAudiosCount.toInt(),
          musicsCount: newMetaData.allMusicsCount.toInt(),
          linkCount: newMetaData.allLinksCount.toInt(),
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch));
    }
    if (oldMediaMetaData.audiosCount != newMetaData.allAudiosCount.toInt()) {
      fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.audiosCount,
          query_pb.FetchMediasReq_MediaType.AUDIOS,
          newMetaData.allAudiosCount.toInt());
    }
    if (oldMediaMetaData.filesCount != newMetaData.allFilesCount.toInt()) {
      fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.filesCount,
          query_pb.FetchMediasReq_MediaType.FILES,
          newMetaData.allFilesCount.toInt());
    }
    if (oldMediaMetaData.videosCount != newMetaData.allVideosCount.toInt()) {
      fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.videosCount,
          query_pb.FetchMediasReq_MediaType.VIDEOS,
          newMetaData.allVideosCount.toInt());
    }
    if (oldMediaMetaData.linkCount != newMetaData.allLinksCount.toInt()) {
      fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.linkCount,
          query_pb.FetchMediasReq_MediaType.LINKS,
          newMetaData.allLinksCount.toInt());
    }
  }

  Future fetchLastMedia(
    String roomUid,
    int imagesCount,
    FetchMediasReq_MediaType mediaType,
    int allImageCount,
  ) async {
    try {
      Room? room = await _roomRepo.getRoom(roomUid);

      if (room != null && room.lastMessage != null) {
        print("room=>>>>>>>>              ${room.lastMessageId}");
        await _fetchLastMedia(
            roomUid.asUid(),
            mediaType,
            room.lastMessage!.time,
            DateTime.fromMillisecondsSinceEpoch(room.lastMessage!.time).year,
            min(allImageCount - imagesCount, 10));
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<int?> getImageMediaCount(Uid uid) async {
    try {
      var mediaRes = await _queryServiceClient
          .getMediaMetadata(GetMediaMetadataReq()..with_1 = uid);
      return mediaRes.allImagesCount.toInt();
    } catch (e) {
      return null;
    }
  }

  Stream<MediaMetaData?> getMediasMetaDataCountFromDB(Uid roomId) {
    return _mediaMetaDataDao.get(roomId.asString());
  }

//TODO correction of performance
  Future<List<Media>> getMedia(Uid uid, MediaType mediaType, int mediaCount,
      {int messageId = 0}) async {
    List<Media> mediasList = [];
    mediasList = await _mediaDao.getByRoomIdAndType(uid.asString(), mediaType);
    if (mediasList.isEmpty) {
      mediasList = await getLastMediasList(
          uid,
          convertType(mediaType),
          DateTime.now().millisecondsSinceEpoch,
          FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);

      return mediasList;
    } else if (mediasList.length < mediaCount) {
      int lastId = mediasList.last.messageId;
      int pointer = messageId != 0 && lastId < messageId
          ? mediasList.last.createdOn
          : mediasList.first.createdOn;
      var newMediasServerList = await getLastMediasList(
          uid,
          convertType(mediaType),
          pointer,
          messageId != 0 && lastId < messageId
              ? FetchMediasReq_FetchingDirectionType.FORWARD_FETCH
              : FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
      mediasList.removeAt(
          messageId != 0 && lastId < messageId ? mediasList.length : 0);
      var combinedList = [...newMediasServerList.reversed, ...mediasList];
      return combinedList.reversed.toList();
    } else {
      return mediasList.reversed.toList();
    }
  }

  Future<void> _fetchLastMedia(Uid roomUid, FetchMediasReq_MediaType mediaType,
      int time, int year, int limit) async {
    try {
      var getMediasReq = await _queryServiceClient.fetchMedias(FetchMediasReq()
        ..roomUid = roomUid
        ..pointer = Int64(time)
        ..mediaType = mediaType
        ..year = year
        ..limit = limit
        ..fetchingDirectionType =
            FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
      if (getMediasReq.medias.isEmpty) {
        time = DateTime(year - 1, 12, 30).millisecondsSinceEpoch;
        _fetchLastMedia(roomUid, mediaType, time, year - 1, limit);
      } else {
        await _saveFetchedMedias(getMediasReq.medias, roomUid, mediaType);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<List<Media>> getLastMediasList(
      Uid roomId,
      FetchMediasReq_MediaType mediaType,
      int pointer,
      FetchMediasReq_FetchingDirectionType directionType) async {
    var getMediaReq = FetchMediasReq();
    getMediaReq.roomUid = roomId;
    getMediaReq.pointer = Int64(pointer);
    getMediaReq.year = DateTime.now().year;
    getMediaReq.mediaType = mediaType;
    getMediaReq.fetchingDirectionType = directionType;
    getMediaReq.limit = 30;
    try {
      var getMediasRes = await _queryServiceClient.fetchMedias(getMediaReq);
      List<Media> medias =
          await _saveFetchedMedias(getMediasRes.medias, roomId, mediaType);
      return medias;
    } catch (e) {
      _logger.e(e);
      return [];
    }
  }

  Future<List<Media>> _saveFetchedMedias(List<media_pb.Media> getMedias,
      Uid roomUid, FetchMediasReq_MediaType mediaType) async {
    List<Media> mediaList = [];
    for (media_pb.Media media in getMedias) {
      print("media====>       ${media.messageId.toString()}");
      MediaType type = findFetchedMediaType(mediaType);
      String json = findFetchedMediaJson(media);
      Media insertedMedia = Media(
          createdOn: media.createdOn.toInt(),
          createdBy: media.createdBy.asString(),
          messageId: media.messageId.toInt(),
          type: type,
          roomId: roomUid.asString(),
          json: json);
      mediaList.add(insertedMedia);
      _mediaDao.save(insertedMedia);
    }
    return mediaList;
  }

  MediaType findFetchedMediaType(FetchMediasReq_MediaType mediaType) {
    if (mediaType == FetchMediasReq_MediaType.IMAGES) {
      return MediaType.IMAGE;
    } else if (mediaType == FetchMediasReq_MediaType.VIDEOS) {
      return MediaType.VIDEO;
    } else if (mediaType == FetchMediasReq_MediaType.FILES) {
      return MediaType.FILE;
    } else if (mediaType == FetchMediasReq_MediaType.AUDIOS) {
      return MediaType.AUDIO;
    } else if (mediaType == FetchMediasReq_MediaType.MUSICS) {
      return MediaType.MUSIC;
    } else if (mediaType == FetchMediasReq_MediaType.DOCUMENTS) {
      return MediaType.DOCUMENT;
    } else if (mediaType == FetchMediasReq_MediaType.LINKS) {
      return MediaType.LINK;
    } else {
      return MediaType.NOT_SET;
    }
  }

  FetchMediasReq_MediaType convertType(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.IMAGE:
        return FetchMediasReq_MediaType.IMAGES;
      case MediaType.VIDEO:
        return FetchMediasReq_MediaType.VIDEOS;
      case MediaType.FILE:
        return FetchMediasReq_MediaType.FILES;
      case MediaType.AUDIO:
        return FetchMediasReq_MediaType.AUDIOS;
      case MediaType.MUSIC:
        return FetchMediasReq_MediaType.MUSICS;
      case MediaType.DOCUMENT:
        return FetchMediasReq_MediaType.DOCUMENTS;
      case MediaType.LINK:
        return FetchMediasReq_MediaType.LINKS;
      default:
        return FetchMediasReq_MediaType.FILES;
    }
  }

  Future<List<Media>> getMediaAround(
      String roomId, int offset, MediaType type) async {
    var mediaList = await _mediaDao.getMediaAround(roomId, offset, type);
    return mediaList;
  }

  final _completerMap = <String, Completer<List<Media>?>>{};

  Future<List<Media>?> getMediaPage(
      String roomUid, MediaType type, int page, int index) async {
    var completer = _completerMap["$roomUid-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["$roomUid-$page"] = completer;

    var mediaList = await _mediaDao.getByRoomIdAndType(roomUid, type);
    if (mediaList.length > index) {
      completer.complete(mediaList);
    } else {
      completer.complete(await fetchMoreMedia(roomUid, type,
          mediaList.isNotEmpty ? mediaList.last.createdOn : null));
    }
    return completer.future;
  }

  Future<List<Media>?> fetchMoreMedia(
      String roomUid, MediaType mediaType, int? pointer) async {
    try {
      if (pointer == null) {
        Room? room = await _roomRepo.getRoom(roomUid);
        if (room != null && room.lastMessage != null) {
          pointer = room.lastMessage!.time;
        } else {
          pointer = DateTime.now().millisecondsSinceEpoch;
        }
      }
      var result = await _queryServiceClient.fetchMedias(FetchMediasReq()
        ..pointer = Int64(pointer)
        ..mediaType = FetchMediasReq_MediaType.IMAGES
        ..roomUid = roomUid.asUid()
        ..limit = 40
        ..year = DateTime.fromMillisecondsSinceEpoch(pointer).year
        ..fetchingDirectionType =
            FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
      if (result.medias.isNotEmpty) {
        return _saveFetchedMedias(
            result.medias, roomUid.asUid(), FetchMediasReq_MediaType.IMAGES);
      } else {
        return fetchMoreMedia(
            roomUid,
            mediaType,
            DateTime(DateTime.fromMillisecondsSinceEpoch(pointer).year - 1, 12,
                    30)
                .millisecondsSinceEpoch);
      }
    } catch (e) {
      return null;
    }
  }

  String findFetchedMediaJson(media_pb.Media media) {
    var json = Object();
    if (media.hasLink()) {
      json = {"url": media.link};
    } else if (media.hasFile()) {
      json = {
        "uuid": media.file.uuid,
        "size": media.file.size.toInt(),
        "type": media.file.type,
        "name": media.file.name,
        "caption": media.file.caption,
        "width": media.file.width,
        "height": media.file.height,
        "blurHash": media.file.blurHash,
        "duration": media.file.duration
      };
    }
    return jsonEncode(json);
  }

  Stream<List<Media>>? getMediaAsStream(String roomUid, MediaType mediaType) {
    return _mediaDao.getMediaAsStream(roomUid, mediaType);
  }

  Stream<List<Media>>? getMediaAtIndex(
      String roomUid, int index, MediaType mediaType) {
    return _mediaDao.getMediaAsStream(roomUid, mediaType);
  }
}
