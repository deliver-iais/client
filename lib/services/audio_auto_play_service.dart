import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:get_it/get_it.dart';

class AudioAutoPlayService {
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  List<Meta> _autoPlayAudioList = [];

  //index of next meta
  int _autoPlayAudioIndex = 0;

  void setAudioAutoPlay(List<Meta>? metas) {
    if (metas != null && metas.isNotEmpty) {
      _autoPlayAudioList = metas;
      _autoPlayAudioIndex = 0;
    }
  }

  void switchToNextAudioInAutoPlayList() {
    _autoPlayAudioIndex++;
  }

  Meta getNextAudioInAutoPlayList() {
    return _autoPlayAudioList[_autoPlayAudioIndex];
  }

  Future<void> fetchAndSaveNextAudioListPageWithMessage({
    required int messageId,
    required String roomUid,
    MetaType type = MetaType.AUDIO,
  }) async {
    final list = (await _metaRepo.getAudioAutoPlayListPageByMessageId(
      messageId: messageId,
      roomUid: roomUid,
      type: type,
    ))
        ?.where((element) => !element.isDeletedMeta())
        .toList();
    if (list != null && list.isNotEmpty) {
      setAudioAutoPlay(list);
      await getAudioAutoPlayFilePathFromMetaAudio(
        getNextAudioInAutoPlayList(),
      );
    }
  }

  Future<void> fetchAndSaveNextAudioAutoPlayListPageIfNeeded() async {
    if (_autoPlayAudioList.length == _autoPlayAudioIndex) {
      final list = await _metaRepo.getAudioAutoPlayListPageByMessageId(
        messageId: _autoPlayAudioList.last.messageId,
        roomUid: _autoPlayAudioList.last.roomId,
        type: _autoPlayAudioList.last.type,
      );
      setAudioAutoPlay(list);
      if (_autoPlayAudioIndex != _autoPlayAudioList.length) {
        await getAudioAutoPlayFilePathFromMetaAudio(
          getNextAudioInAutoPlayList(),
        );
      }
    }
  }

  bool HasAudioAutoList() {
    return _autoPlayAudioList.isNotEmpty &&
        _autoPlayAudioIndex != _autoPlayAudioList.length;
  }

  Future<String?> getAudioAutoPlayFilePathFromMetaAudio(Meta meta) {
    if (!meta.isDeletedMeta()) {
      return _fileRepo.getFilePathFromFileProto(
        meta.json.toFile(),
      );
    }
    return Future.value();
  }
}
