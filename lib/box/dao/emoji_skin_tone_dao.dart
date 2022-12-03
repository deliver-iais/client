import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/emoji_skin_tone.dart';
import 'package:deliver/box/hive_plus.dart';

import 'package:hive/hive.dart';

abstract class EmojiSkinToneDao {
  Future<List<EmojiSkinTone>> getAll();

  Future<void> addNewSkinTone(EmojiSkinTone emojiSkinTone);
}

class EmojiSkinToneImpl extends EmojiSkinToneDao {
  @override
  Future<List<EmojiSkinTone>> getAll() async {
    final box = await _open();

    return box.values.toList();
  }

  @override
  Future<void> addNewSkinTone(EmojiSkinTone emojiSkinTone) async {
    final box = await _open();

    return box.put(emojiSkinTone.char, emojiSkinTone);
  }

  static String _key() => "emoji-skin-tone";

  Future<BoxPlus<EmojiSkinTone>> _open() {
    DBManager.open(_key(), TableInfo.EMOJI_SKIN_TONE_TABLE_NAME);
    return gen(Hive.openBox<EmojiSkinTone>(_key()));
  }
}
