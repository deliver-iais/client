import 'dart:math';

import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/string_extension.dart';
import 'package:hive/hive.dart';

abstract class MetaDao {
  Future<List<int>> getMetaDeletedIndex(
    String roomUid,
  );

  Future<void> saveMetaDeletedIndex(
    String roomUid,
    int index,
  );

  Future<List<Meta>> getMetaPage(
    String roomUid,
    MetaType type,
    int page, {
    int pageSize = META_PAGE_SIZE,
    int resultSize = META_PAGE_SIZE,
    int offset = 0,
  });

  Future<void> saveMeta(Meta meta);

  Future<int?> getIndexOfMetaFromMessageId(String roomUid, int messageId);

  Stream<int> getIndexOfMetaFromMessageIdAsStream(
    String roomUid,
    int messageId,
  );

  Future<bool> shouldFetchMetaDeletedIndex(
    String roomUid,
  );

  Future<void> setShouldFetchMetaDeletedIndex(
    String roomUid, {
    bool shouldFetchDeletedIndex = false,
  });

  Future<void> deleteMeta(String roomId, int index, MetaType type);

  Future clearAllMetas(String roomId);
}

class MetaDaoImpl extends MetaDao {
  @override
  Future<void> saveMeta(Meta meta) async {
    final metaBox = await _openMetaBox(meta.roomId, meta.type);
    final messageIdToMetaIndexBox = await _openMessageIdToMetaIndexBox(
      meta.roomId,
    );
    if (meta.isDeletedMeta()) {
      await saveMetaDeletedIndex(
        meta.roomId,
        meta.index,
      );
    }
    await messageIdToMetaIndexBox.put(meta.messageId, meta.index);
    return metaBox.put(meta.index, meta);
  }

  @override
  Future<int?> getIndexOfMetaFromMessageId(
    String roomUid,
    int messageId,
  ) async {
    final messageIdToMetaIndexBox = await _openMessageIdToMetaIndexBox(roomUid);

    return messageIdToMetaIndexBox.get(messageId);
  }

  @override
  Stream<int> getIndexOfMetaFromMessageIdAsStream(
    String roomUid,
    int messageId,
  ) async* {
    final messageIdToMetaIndexBox = await _openMessageIdToMetaIndexBox(roomUid);

    yield messageIdToMetaIndexBox.get(messageId) ?? -1;

    yield* messageIdToMetaIndexBox.watch(key: messageId).map(
          (event) => messageIdToMetaIndexBox.get(messageId) ?? -1,
        );
  }

  @override
  Future<void> deleteMeta(String roomId, int index, MetaType type) async {
    final metaBox = await _openMetaBox(roomId, type);
    final meta = metaBox.get(index);
    if (meta != null) {
      return metaBox.put(
        index,
        meta.copyDeleted(),
      );
    }
  }

  @override
  Future clearAllMetas(String roomId) async {
    for (final metaType in MetaType.values) {
      final metaBox = await _openMetaBox(roomId, metaType);
      await metaBox.clear();
    }
    await (await _openMessageIdToMetaIndexBox(
      roomId,
    ))
        .clear();
  }

  @override
  Future<List<Meta>> getMetaPage(
    String roomUid,
    MetaType type,
    int page, {
    int pageSize = META_PAGE_SIZE,
    int resultSize = META_PAGE_SIZE,
    int offset = 0,
  }) async {
    final val = max(0, offset - (page * pageSize));
    final metaBox = await _openMetaBox(roomUid, type);
    return Iterable<int>.generate(min(resultSize, META_PAGE_SIZE))
        .map((e) {
          return page * pageSize + e + val;
        })
        .map((e) => metaBox.get(e))
        .where((element) => element != null)
        .map((element) => element!)
        .toList();
  }

  @override
  Future<List<int>> getMetaDeletedIndex(
    String roomUid,
  ) async {
    final deletedIndexBox = await _openDeletedIndexBox(roomUid);
    return deletedIndexBox.values.toList();
  }

  @override
  Future<void> saveMetaDeletedIndex(
    String roomUid,
    int index,
  ) async {
    final deletedIndexBox = await _openDeletedIndexBox(
      roomUid,
    );
    return deletedIndexBox.put(index, index);
  }

  @override
  Future<bool> shouldFetchMetaDeletedIndex(String roomUid) async {
    final shouldFetchDeletedIndexBox = await _openShouldFetchDeletedIndexBox();
    return shouldFetchDeletedIndexBox.get(roomUid) ?? true;
  }

  @override
  Future<void> setShouldFetchMetaDeletedIndex(
    String roomUid, {
    bool shouldFetchDeletedIndex = false,
  }) async {
    final shouldFetchDeletedIndexBox = await _openShouldFetchDeletedIndexBox();
    return shouldFetchDeletedIndexBox.put(roomUid, shouldFetchDeletedIndex);
  }

  static String _deletedIndexTableKey(String roomUid) =>
      "meta-deleted-index-${roomUid.convertUidStringToDaoKey()}";

  static String _messageIdToMetaIndexBoxTableKey(String roomUid) =>
      "message-id-to-meta-index-${roomUid.convertUidStringToDaoKey()}";

  static String _metaTableKey(String roomUid, MetaType type) =>
      "meta-${roomUid.convertUidStringToDaoKey()}-$type";

  static String _ShouldFetchDeletedIndexKey() => "should-fetch-deleted-index";

  Future<BoxPlus<Meta>> _openMetaBox(String uid, MetaType type) {
    DBManager.open(
      _metaTableKey(uid, type),
      TableInfo.META_TABLE_NAME,
    );
    return gen(
      Hive.openBox<Meta>(
        _metaTableKey(uid, type),
      ),
    );
  }

  Future<BoxPlus<int>> _openMessageIdToMetaIndexBox(
    String uid,
  ) {
    DBManager.open(
      _messageIdToMetaIndexBoxTableKey(uid),
      TableInfo.MESSAGE_ID_TO_META_INDEX_TABLE_NAME,
    );
    return gen(
      Hive.openBox<int>(
        _messageIdToMetaIndexBoxTableKey(uid),
      ),
    );
  }

  Future<BoxPlus<bool>> _openShouldFetchDeletedIndexBox() {
    DBManager.open(
      _ShouldFetchDeletedIndexKey(),
      TableInfo.SHOULD_FETCH_DELETED_INDEX_TABLE_NAME,
    );
    return gen(
      Hive.openBox<bool>(_ShouldFetchDeletedIndexKey()),
    );
  }

  Future<BoxPlus<int>> _openDeletedIndexBox(String uid) {
    DBManager.open(
      _deletedIndexTableKey(uid),
      TableInfo.META_DELETED_INDEX_TABLE_NAME,
    );
    return gen(
      Hive.openBox<int>(
        _deletedIndexTableKey(uid),
      ),
    );
  }
}
