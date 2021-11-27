import 'dart:convert';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart' as queryObject;
import 'package:deliver_public_protocol/pub/v1/models/media.pb.dart'
    as MediaObject;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

class MediaQueryRepo {
  final _logger = GetIt.I.get<Logger>();
  final _mediaQueriesDao = GetIt.I.get<MediaDao>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  getMediaMetaDataReq(Uid uid) async {
    try {
      var mediaResponse = await _queryServiceClient
          .getMediaMetadata(GetMediaMetadataReq()..with_1 = uid);
      insertMediaMetaData(uid, mediaResponse);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future insertMediaMetaData(
      Uid uid, queryObject.GetMediaMetadataRes mediaResponse) async {
    _mediaMetaDataDao.save(MediaMetaData(
      roomId: uid.asString(),
      imagesCount: mediaResponse.allImagesCount.toInt(),
      videosCount: mediaResponse.allVideosCount.toInt(),
      filesCount: mediaResponse.allFilesCount.toInt(),
      documentsCount: mediaResponse.allDocumentsCount.toInt(),
      audiosCount: mediaResponse.allAudiosCount.toInt(),
      musicsCount: mediaResponse.allMusicsCount.toInt(),
      linkCount: mediaResponse.allLinksCount.toInt(),
    ));
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

  Stream<MediaMetaData> getMediasMetaDataCountFromDB(Uid roomId) {
    return _mediaMetaDataDao.get(roomId.asString());
  }

//TODO correction of performance
  Future<List<Media>> getMedia(Uid uid, MediaType mediaType, int mediaCount,
      {int messageId = 0}) async {
    List<Media> mediasList = [];
    mediasList = await _mediaDao.getByRoomIdAndType(uid.asString(), mediaType);
    if (mediasList.length == 0) {
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

  Future<List<Media>> getLastMediasList(
      Uid roomId,
      FetchMediasReq_MediaType mediaType,
      int pointer,
      FetchMediasReq_FetchingDirectionType directionType) async {
    var getMediaReq = FetchMediasReq();
    getMediaReq..roomUid = roomId;
    getMediaReq..pointer = Int64(pointer);
    getMediaReq..year = DateTime.now().year;
    getMediaReq..mediaType = mediaType;
    getMediaReq..fetchingDirectionType = directionType;
    getMediaReq..limit = 30;
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

  Future<List<Media>> _saveFetchedMedias(List<MediaObject.Media> getMedias,
      Uid roomUid, FetchMediasReq_MediaType mediaType) async {
    List<Media> mediaList = [];
    for (MediaObject.Media media in getMedias) {
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
    } else
      return MediaType.NOT_SET;
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
    var mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset, type);
    return mediaList;
  }

  String findFetchedMediaJson(MediaObject.Media media) {
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
}
