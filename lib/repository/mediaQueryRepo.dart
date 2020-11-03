import 'package:deliver_flutter/db/dao/MediaDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:get_it/get_it.dart';

class MediaQueryRepo {
  var mediaList;
  var allMedia;
  var _mediaQueriesDao = GetIt.I.get<MediaDao>();
  int count;

  Future<Media> insertMediaQueryInfo(
      int messageId,
      String mediaUrl,
      String mediaSender,
      String mediaName,
      String mediaType,
      String mediaTime,
      String roomId,
      String mediaUuid) async {
    Media mediaQuery = Media(
        messageId: messageId,
        mediaUrl: mediaUrl,
        mediaSender: mediaSender,
        mediaName: mediaName,
        mediaType: mediaType,
        time: mediaTime,
        roomId: roomId,
        mediaUuid: mediaUuid);
    await _mediaQueriesDao.insertQueryMedia(mediaQuery);
    return mediaQuery;
  }

  Future<List<Media>> getMediaQuery(String roomId) async {
    mediaList = await _mediaQueriesDao.getByRoomId(roomId);
    return mediaList;
  }

  Future<List<Media>> getMediaAround(String roomId,int offset) async {
      mediaList = await _mediaQueriesDao.getMediaAround(roomId, offset);
      return mediaList;
  }



  Future<List<Media>> getAllMedia() async{
   allMedia= await _mediaQueriesDao.getAll();
   return allMedia;
  }
}
