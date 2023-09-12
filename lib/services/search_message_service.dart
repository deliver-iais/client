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
  final Map<String, List<Message>> _searchCache = {};
  final BehaviorSubject<String?> text = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool?> openSearchResultPageOnFooter =
      BehaviorSubject.seeded(false);
  final _messageDao = GetIt.I.get<MessageDao>();

  Uid? getUid() => inSearchMessageMode.value;

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
    final cacheResult = _searchCache[keyword];

    if (cacheResult != null) {
      return cacheResult;
    }

    final subString =
        findSubstringInSearchResults(_searchCache.keys.toList(), keyword);
    if (subString.isNotEmpty) {
      return _searchCache[subString]
              ?.where((msg) => isMessageContainKeyword(msg, keyword))
              .toList() ??
          [];
    }

    final messages = await _messageDao.searchMessages(roomUid, keyword);
    _searchCache[keyword] = messages;
    return messages;
  }

  String findSubstringInSearchResults(List<String> list, String input) {
    return list.firstWhere(
      (element) => input.contains(element),
      orElse: () => "",
    );
  }

  void clearCache() {
    _searchCache.clear();
  }
}
