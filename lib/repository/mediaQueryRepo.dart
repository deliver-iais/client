import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/fetchingDirectionType.dart';
import 'package:deliver_flutter/models/mediaType.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/media.pb.dart'
    as MediaObject;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';

class MediaQueryRepo {
  var mediaList;
  var allMedia;
  var _mediaQueriesDao = GetIt.I.get<MediaDao>();
  int count;
  var _accountRepo = GetIt.I.get<AccountRepo>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().mediaConnection.host,
      port: ServicesDiscoveryRepo().mediaConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var mediaServices = QueryServiceClient(clientChannel);

   fetchMedias(
      Uid roomUid,
      //String pointer,
      int year,
      FetchMediasReq_MediaType mediaType,
      FetchMediasReq_FetchingDirectionType fetchingDirectionType,
      int limit) async {
    var getMediaReq = FetchMediasReq();
    getMediaReq..roomUid = roomUid;
   // getMediaReq..pointer = Int64.parseInt(pointer);
    getMediaReq..year = year;
    getMediaReq..mediaType = mediaType;
    getMediaReq..fetchingDirectionType = fetchingDirectionType;
    getMediaReq..limit = limit;
    var getMedias = await mediaServices.fetchMedias(getMediaReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    print("mediaaaaaaaaaaaaaaaaa${getMedias.medias.length}");

    // for(MediaObject.Media media in getMedias.medias ){
    //   print(media.messageId);
    //   // print(media.createdOn);
    //   // print(media.createdBy);
    //   // print(media.file);
    //   // print(media.link);
    //
    //  }
  //  return getMedias;
  }

  // Future<Media> insertMediaQueryInfo(
  //     int messageId,
  //     String mediaUrl,
  //     String mediaSender,
  //     String mediaName,
  //     String mediaType,
  //     String mediaTime,
  //     String roomId,
  //     String mediaUuid) async {
  //   Media mediaQuery = Media(
  //       messageId: messageId,
  //       mediaUrl: mediaUrl,
  //       mediaSender: mediaSender,
  //       mediaName: mediaName,
  //       mediaType: mediaType,
  //       time: mediaTime,
  //       roomId: roomId,
  //       mediaUuid: mediaUuid);
  //   await _mediaQueriesDao.insertQueryMedia(mediaQuery);
  //   return mediaQuery;
  // }

  Future<List<Media>> getMediaQuery(String roomId) async {
    mediaList = await _mediaQueriesDao.getByRoomId(roomId);
    return mediaList;
  }

  Future<List<Media>> getMediaAround(String roomId, int offset) async {
    mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset);
    return mediaList;
  }

  Future<List<Media>> getAllMedia() async {
    allMedia = await _mediaQueriesDao.getAll();
    return allMedia;
  }
}
