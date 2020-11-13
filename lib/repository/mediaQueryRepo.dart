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
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:fixnum/fixnum.dart';

class MediaQueryRepo {
  var mediaList;
  var allMedia;
  var _mediaQueriesDao = GetIt.I.get<MediaDao>();
  int count;
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mediaDao = GetIt.I.get<MediaDao>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().mediaConnection.host,
      port: ServicesDiscoveryRepo().mediaConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));

  var mediaServices = QueryServiceClient(clientChannel);

  Future<List<int>> getMediaMetaData(Uid uid) async {
    int imageCount;
    var getMediaMetaDataReq = GetMediaMetadataReq();
    getMediaMetaDataReq..with_1 = uid;
    var mediaResponse = await mediaServices.getMediaMetadata(
        getMediaMetaDataReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
  }

  _saveFetchedMedias(List<MediaObject.Media> getMedias, Uid roomUid) async {
    for (MediaObject.Media media in getMedias) {
      MediaType type = findFetchedMediaType(media);
      if (type == MediaType.FILE) {
        await _mediaDao.insertQueryMedia(
          Media(
              createdOn: media.createdOn.toInt(),
              createdBy: media.createdBy.string,
              messageId: media.messageId.toInt(),
              type: type,
              roomId: roomUid.string,
              fileName: media.file.name,
              fileId: media.file.uuid),
        );
      } else if (type == MediaType.LINK) {
        await _mediaDao.insertQueryMedia(
          Media(
              createdOn: media.createdOn.toInt(),
              createdBy: media.createdBy.string,
              messageId: media.messageId.toInt(),
              type: type,
              roomId: roomUid.string,
              linkAddress: media.link),
        );
      }
    }
  }

  MediaType findFetchedMediaType(MediaObject.Media media) {
    if (media.hasFile()) {
      return MediaType.FILE;
    } else if (media.hasLink()) {
      return MediaType.LINK;
    } else {
      return MediaType.NOT_SET;
    }
  }

  getMedias(
      String roomId,
      String pointer,
      int year,
      FetchMediasReq_MediaType mediaType,
      FetchMediasReq_FetchingDirectionType fetchingDirectionType,
      int limit) async {
    var medias = await _mediaDao.getByRoomIdAndType(roomId,mediaType);
    if (medias.length == 0 || medias.length < limit) {
      var getMediaReq = FetchMediasReq();
      getMediaReq..roomUid = roomId.uid;
      getMediaReq..pointer = Int64.parseInt(pointer);
      getMediaReq..year = year;
      getMediaReq..mediaType = mediaType;
      getMediaReq..fetchingDirectionType = fetchingDirectionType;
      getMediaReq..limit = limit;
      var getMediasRes = await mediaServices.fetchMedias(getMediaReq,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      await _saveFetchedMedias(getMediasRes.medias, roomId.uid);
      medias = await _mediaDao.getByRoomIdAndType(roomId,);
    }
    return medias;
  }

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
