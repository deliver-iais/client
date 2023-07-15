import 'dart:async';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessageService {
  final BehaviorSubject<Uid?> inSearchMessageMode =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<int> currentSelectedMessageId =
      BehaviorSubject.seeded(-1);
  final Map<Uid, Map<String, List<Message>>> _searchCache = {};
  final BehaviorSubject<String?> text = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool?> openSearchResultPageOnFooter =
      BehaviorSubject.seeded(false);
  final _messageDao = GetIt.I.get<MessageDao>();
  late Uid? uid;

  void closeSearch() {
    inSearchMessageMode.add(null);
    text.add(null);
    currentSelectedMessageId.add(-1);
  }

  Future<List<Message>> searchMessagesResult(
    Uid roomUid,
    String keyword,
  ) async {
    if (keyword.isEmpty) {
      return [];
    }
    final roomCache = _searchCache[roomUid] ?? {};
    final cacheResult = roomCache[keyword];
    if (cacheResult != null) {
      return cacheResult;
    }
    final subString =
        findSubstringInSearchResults(roomCache.keys.toList(), keyword);
    if (subString.isNotEmpty) {
      return roomCache[subString]
              ?.where((msg) => isMessageContainKeyword(msg, keyword))
              .toList() ??
          [];
    }
    final messages = await _messageDao.searchMessages(roomUid, keyword);
    roomCache[keyword] = messages;
    _searchCache[roomUid] = roomCache;
    return messages;
  }

  String findSubstringInSearchResults(List<String> list, String input) {
    return list.firstWhere(
      (element) => input.contains(element),
      orElse: () => "",
    );
  }
}
