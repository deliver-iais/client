import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/recent_emoji.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

abstract class RecentEmojiDao {
  Future<List<RecentEmoji>> getAll();

  Future<void> deleteAll();

  Future<void> addRecentEmoji(String emoji);
}

class RecentEmojiImpl extends RecentEmojiDao {
  @override
  Future<List<RecentEmoji>> getAll() async {
    final box = await _open();

    return sorted(box.values);
  }

  List<RecentEmoji> sorted(Iterable<RecentEmoji> list) =>
      list.toList()..sort((a, b) => b.count.compareTo(a.count));

  @override
  Future<void> addRecentEmoji(String emoji) async {
    final box = await _open();
    final count = box.get(emoji)?.count ?? 0;
    if (box.values.length > MAX_RECENT_EMOJI_LENGTH - 1 && count == 0) {
      await box.delete(sorted(box.values).last.char);
    }
    return box.put(emoji, RecentEmoji(char: emoji, count: count + 1));
  }

  @override
  Future<void> deleteAll() async {
    final box = await _open();
    return box.clear();
  }

  static String _key() => "recent-emoji";

  Future<BoxPlus<RecentEmoji>> _open() {
    DBManager.open(_key(), TableInfo.RECENT_EMOJI_TABLE_NAME);
    return gen(Hive.openBox<RecentEmoji>(_key()));
  }
}
