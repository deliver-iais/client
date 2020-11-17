import 'dart:convert';
import 'dart:html';

import 'package:deliver_flutter/db/MediaMetaData.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/dao/MediaMetaDataDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/fetchingDirectionType.dart';
import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart'
    as queryObject;
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
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
int lastTime;
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().mediaConnection.host,
      port: ServicesDiscoveryRepo().mediaConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var mediaServices = QueryServiceClient(clientChannel);

  getMediasCountFromServer(Uid uid) async {
    var getMediaMetaDataReq = GetMediaMetadataReq();
    getMediaMetaDataReq..with_1 = uid;
    var mediaResponse = await mediaServices.getMediaMetadata(
        getMediaMetaDataReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    // return mediaResponse;
    insertMediaMetaData(uid,mediaResponse);
  }

  insertMediaMetaData(Uid uid ,queryObject.GetMediaMetadataRes mediaResponse) async{
    await _mediaMetaDataDao.insertMetaData(MediasMetaDataData(
        roomId: uid.string,
        imagesCount: mediaResponse.allImagesCount.toInt(),
        videosCount: mediaResponse.allVideosCount.toInt(),
        filesCount: mediaResponse.allFilesCount.toInt(),
        documentsCount: mediaResponse.allDocumentsCount.toInt(),
        audiosCount: mediaResponse.allAudiosCount.toInt(),
        musicsCount: mediaResponse.allMusicsCount.toInt(),
        linkCount: mediaResponse.allLinksCount.toInt(),
       ));
  }
  Future<MediasMetaDataData> getMediasCountFromDB(String roomId) async{
    var mediaMeta = await _mediaMetaDataDao.getMediasCountByRoomId(roomId);
    return mediaMeta;
   }

  Future<List<Media>> getMedias(
      String roomId,
      int year,
      FetchMediasReq_MediaType mediaType,
      int pageSize,int position) async {

    await getMediasCountFromServer(roomId.uid);

    var medias = await _mediaDao.getByRoomIdAndType(roomId, mediaType.value,pageSize,position);
     if(medias.length==0){
       int pointer = DateTime.now().microsecondsSinceEpoch;
       var getMediaReq = FetchMediasReq();
       getMediaReq..roomUid = roomId.uid;
       getMediaReq..pointer = Int64(pointer);
       getMediaReq..year = year;
       getMediaReq..mediaType = mediaType;
       getMediaReq..fetchingDirectionType = FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH;
       getMediaReq..limit = pageSize;
       var getMediasRes = await mediaServices.fetchMedias(getMediaReq,
           options: CallOptions(
               metadata: {'accessToken': await _accountRepo.getAccessToken()}));
       await _saveFetchedMedias(getMediasRes.medias, roomId.uid, mediaType);
       medias = await _mediaDao.getByRoomIdAndType(roomId, mediaType.value,pageSize,position);
     } else if(medias.length < pageSize){
      int pointer= medias.first.createdOn;
      var getMediaReq = FetchMediasReq();
      getMediaReq..roomUid = roomId.uid;
      getMediaReq..pointer = Int64(pointer);
      getMediaReq..year = year;
      getMediaReq..mediaType = mediaType;
      getMediaReq..fetchingDirectionType = FetchMediasReq_FetchingDirectionType.FORWARD_FETCH;
      getMediaReq..limit = pageSize;
      var getMediasRes = await mediaServices.fetchMedias(getMediaReq,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      await _saveFetchedMedias(getMediasRes.medias, roomId.uid, mediaType);
      medias = await _mediaDao.getByRoomIdAndType(roomId, mediaType.value,pageSize,position);
     }

    return medias;
  }

  _saveFetchedMedias(List<MediaObject.Media> getMedias, Uid roomUid,
      FetchMediasReq_MediaType mediaType) async {
    for (MediaObject.Media media in getMedias) {
      MediaType type = findFetchedMediaType(mediaType);
      String json = findFetchedMediaJson(media);
      await _mediaDao.insertQueryMedia(Media(
          createdOn: media.createdOn.toInt(),
          createdBy: media.createdBy.string,
          messageId: media.messageId.toInt(),
          type: type,
          roomId: roomUid.string,
          json: json));
    }
  }

  MediaType findFetchedMediaType(FetchMediasReq_MediaType mediaType) {
    MediaType type;
    if (mediaType == FetchMediasReq_MediaType.IMAGES) {
      type = MediaType.IMAGE;
    } else if (mediaType == FetchMediasReq_MediaType.VIDEOS) {
      type = MediaType.VIDEO;
    } else if (mediaType == FetchMediasReq_MediaType.FILES) {
      type = MediaType.FILE;
    } else if (mediaType == FetchMediasReq_MediaType.AUDIOS) {
      type = MediaType.AUDIO;
    } else if (mediaType == FetchMediasReq_MediaType.MUSICS) {
      type = MediaType.MUSIC;
    } else if (mediaType == FetchMediasReq_MediaType.DOCUMENTS) {
      type = MediaType.DOCUMENT;
    } else if (mediaType == FetchMediasReq_MediaType.LINKS) {
      type = MediaType.LINK;
    } else
      type = MediaType.NOT_SET;
  }

  // Future<List<Media>> getMediaQuery(String roomId) async {
  //   mediaList = await _mediaQueriesDao.getByRoomIdAndType(roomId);
  //   return mediaList;
  // }

  Future<List<Media>> getMediaAround(String roomId, int offset) async {
    mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset);
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
        "size": media.file.size,
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
