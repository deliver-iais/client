import 'dart:convert';
import 'dart:ffi';
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
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  int lastTime;
  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().mediaConnection.host,
      port: ServicesDiscoveryRepo().mediaConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var mediaServices = QueryServiceClient(clientChannel);

 Future<MediaCount> allMediasTypeCountInServer(Uid uid) async {
  Uid uid1= Uid.create()..category=Categories.USER
   ..node="Hello";

    var getMediaMetaDataReq = GetMediaMetadataReq();
    getMediaMetaDataReq..with_1 =uid1;
    var mediaResponse = await mediaServices.getMediaMetadata(
        getMediaMetaDataReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    print("oooooooooooooooooooooooooooooooooooooooooooo${mediaResponse.allFilesCount}");
    MediaCount()
    ..imageCount = mediaResponse.allImagesCount.toInt()
    ..linkCount = mediaResponse.allLinksCount.toInt()
    ..audioCount = mediaResponse.allAudiosCount.toInt()
    ..fileCount = mediaResponse.allFilesCount.toInt()
    ..documentCount = mediaResponse.allDocumentsCount.toInt()
    ..videoCount = mediaResponse.allVideosCount.toInt()
    ..musicCount = mediaResponse.allMusicsCount.toInt();
    return MediaCount();


    // if(mediaType==MediaType.IMAGE){
    //
    //   return mediaResponse.allImagesCount.toInt();
    //
    // }else if(mediaType==MediaType.LINK){
    //   return mediaResponse.allLinksCount.toInt();
    // }else if(mediaType==MediaType.FILE){
    //   return mediaResponse.allFilesCount.toInt();
    // }else if(mediaType==MediaType.MUSIC){
    //   return mediaResponse.allMusicsCount.toInt();
    // }else if(mediaType==MediaType.VIDEO){
    //   return mediaResponse.allVideosCount.toInt();
    // }else if(mediaType==MediaType.DOCUMENT){
    //   return mediaResponse.allDocumentsCount.toInt();
    // }else if(mediaType==MediaType.AUDIO){
    //   return mediaResponse.allAudiosCount.toInt();
    // } else {
    //   //todo if type not be set what should do?
    // }
    // return mediaResponse;
    //insertMediaMetaData(uid, mediaResponse);
  }

  Stream<int> allMediasTypeInDBCount(Uid uid , FetchMediasReq_MediaType mediaType) {

    _mediaDao.getByRoomIdAndType(uid.string,mediaType.value).listen((event) async{
      if(event.length==0){
       await getLastMediasList(uid,mediaType);
        //medias =  _mediaDao.getByRoomIdAndType(uid.string,mediaType.value);
      }
      else{
        return event.length;
      }
    });

  }
  
  // Future<bool> hasMedia(Uid uid , FetchMediasReq_MediaType mediaType) async{
  //  int dbCount= await allMediasTypeCountInServer(uid.string,mediaType);
  //  if( dbCount ==0){
  //    return false;
  //  }else if(dbCount==null){
  //    allMediasTypeInDBCount(uid.string,mediaType).listen((event) {
  //      if( event!=0){
  //        return true;
  //      }else{
  //        return false;
  //      }
  //    });
  //  }
  //
  //
  // }

  Future<bool> hasMedia(Uid uid , FetchMediasReq_MediaType mediaType) async{
    MediaCount dbCount= await allMediasTypeCountInServer(uid.string);
    if(mediaType==queryObject.FetchMediasReq_MediaType.IMAGES&& dbCount.imageCount ==0){
      return false;
    }else if(dbCount==null){
      allMediasTypeInDBCount(uid.string,mediaType).listen((event) {
        if( event!=0){
          return true;
        }else{
          return false;
        }
      });
    }


  }

  Future<Media> getMedia(int position ,Uid uid,  FetchMediasReq_MediaType mediaType) async{
    var mediasList = await _mediaDao.getMedia(uid.string,mediaType.value);
    return mediasList[position];
  }

  Future<List<Media>> fetchMoreMedia(Uid roomId , FetchMediasReq_MediaType mediaType) async{
     List<Media> medias= await _mediaDao.getMedia(roomId.string, mediaType.value);
    int pointer = medias.first.createdOn;
     var getMediaReq = FetchMediasReq();
     getMediaReq..roomUid = roomId;
     getMediaReq..pointer = Int64(pointer);
     getMediaReq..year = DateTime.now().year;
     getMediaReq..mediaType = mediaType;
     getMediaReq..fetchingDirectionType = FetchMediasReq_FetchingDirectionType.BACKWARD_FETCH;
     getMediaReq..limit = 30;
     var getMediasRes = await mediaServices.fetchMedias(getMediaReq,
         options: CallOptions(
             metadata: {'accessToken': await _accountRepo.getAccessToken()}));
     List<Media> mediasList = await _saveFetchedMedias(getMediasRes.medias, roomId, mediaType);
   return mediasList;
  }

  // insertMediaMetaData(
  //     Uid uid, queryObject.GetMediaMetadataRes mediaResponse) async {
  //   await _mediaMetaDataDao.insertMetaData(MediasMetaDataData(
  //     roomId: uid.string,
  //     imagesCount: mediaResponse.allImagesCount.toInt(),
  //     videosCount: mediaResponse.allVideosCount.toInt(),
  //     filesCount: mediaResponse.allFilesCount.toInt(),
  //     documentsCount: mediaResponse.allDocumentsCount.toInt(),
  //     audiosCount: mediaResponse.allAudiosCount.toInt(),
  //     musicsCount: mediaResponse.allMusicsCount.toInt(),
  //     linkCount: mediaResponse.allLinksCount.toInt(),
  //   ));
  // }

  Future<MediasMetaDataData> getMediasCountFromDB(String roomId) async {
    var mediaMeta = await _mediaMetaDataDao.getMediasCountByRoomId(roomId);
    return mediaMeta;
  }

  Future<List<Media>> getLastMediasList(Uid roomId, FetchMediasReq_MediaType mediaType) async {
    // await getMediasCountFromServer(roomId.uid);
    // var medias = await _mediaDao.getByRoomIdAndType(roomId, mediaType.value);
    // if(medias.length==0){
    //await allMediasTypeCountInServer(roomId);
     var getMediaReq = FetchMediasReq();
    getMediaReq..roomUid = roomId;
    getMediaReq..pointer = Int64(20);
    //Int64(DateTime.now().microsecondsSinceEpoch)
    getMediaReq..year = DateTime.now().year;
    getMediaReq..mediaType = mediaType;
    getMediaReq..fetchingDirectionType = FetchMediasReq_FetchingDirectionType.FORWARD_FETCH;
    getMediaReq..limit = 10;
    try{
    var getMediasRes = await mediaServices.fetchMedias(getMediaReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    List<Media> medias = await _saveFetchedMedias(getMediasRes.medias, roomId, mediaType);
    return medias;
    }
            catch(e){
      print("errrrrrrrrrroooooooorrrrr:$e");

            }

    //  medias = await _mediaDao.getByRoomIdAndType(roomId, mediaType.value);
    // }
    // return medias;
  }

 Future<List<Media>> _saveFetchedMedias(List<MediaObject.Media> getMedias, Uid roomUid,
      FetchMediasReq_MediaType mediaType) async {
    List<Media> mediaList;
    for (MediaObject.Media media in getMedias) {
      MediaType type = findFetchedMediaType(mediaType);
      String json = findFetchedMediaJson(media);
      Media insertedMedia = Media(
          createdOn: media.createdOn.toInt(),
          createdBy: media.createdBy.string,
          messageId: media.messageId.toInt(),
          type: type,
          roomId: roomUid.string,
          json: json);
      mediaList.add(insertedMedia);
      await _mediaDao.insertQueryMedia(insertedMedia);
    }
    return mediaList;
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
