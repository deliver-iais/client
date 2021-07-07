import 'dart:convert';

import 'package:deliver_flutter/box/dao/media_dao.dart';
import 'package:deliver_flutter/box/dao/media_meta_data_dao.dart';
import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:deliver_flutter/box/media.dart';
import 'package:deliver_flutter/box/media_type.dart';


import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/utils/log.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart' as queryObject;
import 'package:deliver_public_protocol/pub/v1/models/media.pb.dart'
    as MediaObject;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:fixnum/fixnum.dart';

class MediaQueryRepo {
  var mediaList;
  var allMedia;
  var _mediaQueriesDao = GetIt.I.get<MediaDao>();
  int count;
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mediaDao = GetIt.I.get<MediaDao>();
  var _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  int lastTime;
  final QueryServiceClient _queryServiceClient =
      GetIt.I.get<QueryServiceClient>();

  getMediaMetaDataReq(Uid uid) async {
    try {
      var mediaResponse = await _queryServiceClient.getMediaMetadata(
          GetMediaMetadataReq()..with_1 = uid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      await insertMediaMetaData(uid, mediaResponse);
    } catch (e) {
      debug(e);
    }

  }

  Future insertMediaMetaData(
      Uid uid, queryObject.GetMediaMetadataRes mediaResponse) async {
    _mediaMetaDataDao.save( MediaMetaData(
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

  Stream< MediaMetaData> getMediasMetaDataCountFromDB(Uid roomId) {
    return _mediaMetaDataDao.get(roomId.asString());
  }


//TODO correction of performance
  Future<List<Media>> getMedia(
      Uid uid, MediaType mediaType, int mediaCount) async {
    List<Media> mediasList = [];
    mediasList =
        await _mediaDao.getByRoomIdAndType(uid.asString(), mediaType);
    if (mediasList.length == 0) {
      mediasList = await getLastMediasList(
          uid,
          convertType(mediaType),
          DateTime.now().millisecondsSinceEpoch,
          FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);

      return mediasList;
    } else if (mediasList.length < mediaCount) {
      int pointer = mediasList.first.createdOn;
      var newMediasServerList = await getLastMediasList(uid, convertType(mediaType), pointer,
          FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
     mediasList.removeAt(0);
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
      var getMediasRes = await _queryServiceClient.fetchMedias(getMediaReq,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      List<Media> medias =
          await _saveFetchedMedias(getMediasRes.medias, roomId, mediaType);
      return medias;
    } catch (e) {
      debug("error on get lastMediaList:$e");
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
  FetchMediasReq_MediaType convertType(MediaType mediaType){
    switch(mediaType){

      case MediaType.IMAGE:
       return  FetchMediasReq_MediaType.IMAGES;
        break;
      case MediaType.VIDEO:
        return  FetchMediasReq_MediaType.VIDEOS;
        break;
      case MediaType.FILE:
        return  FetchMediasReq_MediaType.FILES;
        break;
      case MediaType.AUDIO:
        return  FetchMediasReq_MediaType.AUDIOS;
        break;
      case MediaType.MUSIC:
        return  FetchMediasReq_MediaType.MUSICS;
        break;
      case MediaType.DOCUMENT:
        return  FetchMediasReq_MediaType.DOCUMENTS;
        break;
      case MediaType.LINK:
        return  FetchMediasReq_MediaType.LINKS;
        break;
      case MediaType.NOT_SET:
        return  FetchMediasReq_MediaType.FILES;
        break;
    }

  }

  Future<List<Media>> getMediaAround(
      String roomId, int offset, MediaType type) async {
    mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset, type);
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
        "duration": media.file.duration
      };
    }
    return jsonEncode(json);
  }
}
