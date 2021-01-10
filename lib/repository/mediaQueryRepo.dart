import 'dart:convert';
import 'dart:ffi';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/MediaMetaData.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/dao/MediaMetaDataDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/fetchingDirectionType.dart';
import 'package:deliver_flutter/models/mediaCount.dart';
import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
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
    var mediaResponse;
    var getMediaMetaDataReq = GetMediaMetadataReq();
    getMediaMetaDataReq..with_1 = uid;
    try {
      mediaResponse = await _queryServiceClient.getMediaMetadata(
          getMediaMetaDataReq,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      insertMediaMetaData(uid, mediaResponse);
    } catch (e) {}
  }

  insertMediaMetaData(
      Uid uid, queryObject.GetMediaMetadataRes mediaResponse) async {
    _mediaMetaDataDao.upsertMetaData(MediasMetaDataData(
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

  Stream<MediasMetaDataData> getMediasMetaDataCountFromDB(Uid roomId) {
    return _mediaMetaDataDao.getStreamMediasCountByRoomId(roomId.asString());
  }

//TODO correction of performance
  Future<List<Media>> getMedia(
      Uid uid, FetchMediasReq_MediaType mediaType, int mediaCount) async {
    List<Media> mediasList = [];
    mediasList =
        await _mediaDao.getByRoomIdAndType(uid.asString(), mediaType.value);
    if (mediasList.length == 0) {
      mediasList = await getLastMediasList(
          uid,
          mediaType,
          DateTime.now().microsecondsSinceEpoch,
          FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH);
      return mediasList;
    } else if (mediasList.length < mediaCount) {
      int pointer = mediasList.last.createdOn;
      List<Media> newMediasServerList = await getLastMediasList(uid, mediaType,
          pointer, FetchMediasReq_FetchingDirectionType.FORWARD_FETCH);
      if (newMediasServerList != null) mediasList.addAll(newMediasServerList);
      return mediasList;
    } else {
      return mediasList;
    }
  }

  Future<List<Media>> getLastMediasList(
      Uid roomId,
      FetchMediasReq_MediaType mediaType,
      int pointer,
      FetchMediasReq_FetchingDirectionType directionType) async {
    var getMediaReq = FetchMediasReq();
    List<Media> medias = List();
    getMediaReq..roomUid = roomId;
    getMediaReq..pointer = Int64.parseInt(pointer.toString());
    getMediaReq..year = DateTime.now().year;
    getMediaReq..mediaType = mediaType;
    getMediaReq..fetchingDirectionType = directionType;
    getMediaReq..limit = 30;
    try {
      var getMediasRes = await _queryServiceClient.fetchMedias(getMediaReq,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      if (getMediasRes != null)
        medias =
            await _saveFetchedMedias(getMediasRes.medias, roomId, mediaType);

      return medias;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<Media>> _saveFetchedMedias(List<MediaObject.Media> getMedias,
      Uid roomUid, FetchMediasReq_MediaType mediaType) async {
    List<Media> mediaList = [];
    print(getMedias.length.toString());
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
      await _mediaDao.insertQueryMedia(insertedMedia);
    }
    return mediaList;
  }

  MediaType findFetchedMediaType(FetchMediasReq_MediaType mediaType) {
    MediaType type;
    if (mediaType == FetchMediasReq_MediaType.IMAGES) {
      return type = MediaType.IMAGE;
    } else if (mediaType == FetchMediasReq_MediaType.VIDEOS) {
      return type = MediaType.VIDEO;
    } else if (mediaType == FetchMediasReq_MediaType.FILES) {
      return type = MediaType.FILE;
    } else if (mediaType == FetchMediasReq_MediaType.AUDIOS) {
      return type = MediaType.AUDIO;
    } else if (mediaType == FetchMediasReq_MediaType.MUSICS) {
      return type = MediaType.MUSIC;
    } else if (mediaType == FetchMediasReq_MediaType.DOCUMENTS) {
      return type = MediaType.DOCUMENT;
    } else if (mediaType == FetchMediasReq_MediaType.LINKS) {
      return type = MediaType.LINK;
    } else
      return type = MediaType.NOT_SET;
  }

  Future<List<Media>> getMediaAround(
      String roomId, int offset, int type) async {
    mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset, type);
    return mediaList;
  }

  Future<List<Media>> getAllMedia() async {
    allMedia = await _mediaQueriesDao.getAll();
    return allMedia;
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
