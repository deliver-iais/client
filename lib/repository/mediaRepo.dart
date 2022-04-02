// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart' as query_pb;
import 'package:deliver_public_protocol/pub/v1/models/media.pb.dart'
    as media_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

class MediaRepo {
  final _logger = GetIt.I.get<Logger>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  Future<void> fetchMediaMetaData(Uid uid, {bool updateAllMedia = true}) async {
    try {
      var mediaResponse = await _queryServiceClient
          .getMediaMetadata(GetMediaMetadataReq()..with_1 = uid);
      updateMediaMetaData(uid, mediaResponse);
    } catch (e) {
      _logger.e(e);
    }
  }

  void saveMediaMetaData(MediaMetaData metaData) {
    _mediaMetaDataDao.save(metaData);
  }

  Future<MediaMetaData?> getMediaMetaData(String roomUid) async {
    return _mediaMetaDataDao.getAsFuture(roomUid);
  }

  Future updateMediaMetaData(
      Uid roomUid, query_pb.GetMediaMetadataRes mediaResponse,
      {bool updateAllMedia = true}) async {
    MediaMetaData? oldMetaMediaData =
        await _mediaMetaDataDao.getAsFuture(roomUid.asString());
    if (oldMetaMediaData != null) {
      checkNeedFetchMedia(
          roomUid.asString(), oldMetaMediaData, mediaResponse, updateAllMedia);
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

  void _updateMetaMediaData(
      String roomUid, GetMediaMetadataRes getMediaMetadataRes) {
    _mediaMetaDataDao.save(MediaMetaData(
        roomId: roomUid,
        imagesCount: getMediaMetadataRes.allImagesCount.toInt(),
        videosCount: getMediaMetadataRes.allVideosCount.toInt(),
        filesCount: getMediaMetadataRes.allFilesCount.toInt(),
        documentsCount: getMediaMetadataRes.allDocumentsCount.toInt(),
        audiosCount: getMediaMetadataRes.allAudiosCount.toInt(),
        musicsCount: getMediaMetadataRes.allMusicsCount.toInt(),
        linkCount: getMediaMetadataRes.allLinksCount.toInt(),
        lastUpdateTime: DateTime.now().millisecondsSinceEpoch));
  }

  Future checkNeedFetchMedia(String roomUid, MediaMetaData oldMediaMetaData,
      GetMediaMetadataRes getMediaMetadataRes, bool updateOtherMedia) async {
    if (oldMediaMetaData.imagesCount !=
        getMediaMetadataRes.allImagesCount.toInt()) {
      await fetchLastMedia(
          oldMediaMetaData.roomId,
          oldMediaMetaData.imagesCount,
          query_pb.FetchMediasReq_MediaType.IMAGES,
          getMediaMetadataRes.allImagesCount.toInt());
    }
    if (updateOtherMedia) {
      if (oldMediaMetaData.audiosCount !=
          getMediaMetadataRes.allAudiosCount.toInt()) {
        fetchLastMedia(
            oldMediaMetaData.roomId,
            oldMediaMetaData.audiosCount,
            query_pb.FetchMediasReq_MediaType.AUDIOS,
            getMediaMetadataRes.allAudiosCount.toInt());
      }
      if (oldMediaMetaData.musicsCount !=
          getMediaMetadataRes.allMusicsCount.toInt()) {
        fetchLastMedia(
            oldMediaMetaData.roomId,
            oldMediaMetaData.audiosCount,
            query_pb.FetchMediasReq_MediaType.MUSICS,
            getMediaMetadataRes.allMusicsCount.toInt());
      }
      if (oldMediaMetaData.filesCount !=
          getMediaMetadataRes.allFilesCount.toInt()) {
        fetchLastMedia(
            oldMediaMetaData.roomId,
            oldMediaMetaData.filesCount,
            query_pb.FetchMediasReq_MediaType.FILES,
            getMediaMetadataRes.allFilesCount.toInt());
      }
      if (oldMediaMetaData.videosCount !=
          getMediaMetadataRes.allVideosCount.toInt()) {
        fetchLastMedia(
            oldMediaMetaData.roomId,
            oldMediaMetaData.videosCount,
            query_pb.FetchMediasReq_MediaType.VIDEOS,
            getMediaMetadataRes.allVideosCount.toInt());
      }
      if (oldMediaMetaData.linkCount !=
          getMediaMetadataRes.allLinksCount.toInt()) {
        fetchLastMedia(
            oldMediaMetaData.roomId,
            oldMediaMetaData.linkCount,
            query_pb.FetchMediasReq_MediaType.LINKS,
            getMediaMetadataRes.allLinksCount.toInt());
      }
    }

    _updateMetaMediaData(roomUid, getMediaMetadataRes);
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
        await _fetchLastMedia(
            roomUid.asUid(),
            mediaType,
            room.lastMessage!.time,
            DateTime.fromMillisecondsSinceEpoch(room.lastMessage!.time).year,
            imagesCount != 0 ? allImageCount - imagesCount : 20);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Stream<MediaMetaData?> getMediasMetaDataCountFromDB(Uid roomId) {
    return _mediaMetaDataDao.get(roomId.asString());
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
    final List<Media> mediaList = [];
    for (final media in getMedias) {
      final type = findFetchedMediaType(mediaType);
      final json = findFetchedMediaJson(media);
      final insertedMedia = Media(
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

  final _completerMap = <String, Completer<List<Media>?>>{};

  Future<List<Media>?> getMediaPage(
      String roomUid, MediaType type, int page, int index) async {
    var completer = _completerMap["$roomUid-$type-$page"];

    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completerMap["$roomUid-$type-$page"] = completer;

    var mediaList = await _mediaDao.getByRoomIdAndType(roomUid, type);
    if (mediaList.length > index) {
      completer.complete(mediaList);
    } else {
      completer.complete(await fetchMoreMedia(roomUid, convertType(type),
          mediaList.isNotEmpty ? mediaList.last.createdOn : null));
    }
    return completer.future;
  }

  void saveMediaFromMessage(Message message) {
    _mediaDao.save(Media(
        createdOn: message.time,
        json: buildJsonFromFile(message.json.toFile()),
        roomId: message.roomUid,
        messageId: message.id!,
        type: MediaType.IMAGE,
        createdBy: message.from));
  }

  Future<List<Media>?> fetchMoreMedia(
      String roomUid, FetchMediasReq_MediaType mediaType, int? pointer) async {
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
        ..mediaType = mediaType
        ..roomUid = roomUid.asUid()
        ..limit = 40
        ..year = DateTime.fromMillisecondsSinceEpoch(pointer).year
        ..fetchingDirectionType =
            FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
      if (result.medias.isNotEmpty) {
        return _saveFetchedMedias(result.medias, roomUid.asUid(), mediaType);
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

  String buildJsonFromFile(File file) {
    return jsonEncode({
      "uuid": file.uuid,
      "size": file.size.toInt(),
      "type": file.type,
      "name": file.name,
      "caption": file.caption,
      "width": file.width,
      "height": file.height,
      "blurHash": file.blurHash,
      "duration": file.duration
    });
  }

  void updateMedia(Message message) async {
    _mediaDao.save(Media(
        createdOn: DateTime.now().millisecondsSinceEpoch,
        json: buildJsonFromFile(message.json.toFile()),
        roomId: message.roomUid,
        messageId: message.id!,
        type: loadTypeFromString(message.json.toFile().type),
        createdBy: message.from));
  }

  MediaType loadTypeFromString(String type) {
    if (type.contains("image")) {
      return MediaType.IMAGE;
    } else if (type.contains("audio") || type.contains("mp3")) {
      return MediaType.AUDIO;
    } else if (type.contains("video")) {
      return MediaType.VIDEO;
    }
    return MediaType.DOCUMENT;
  }
}
