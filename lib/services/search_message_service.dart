import 'dart:async';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessageService {
  final BehaviorSubject<Uid?> inSearchMessageMode =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<int> foundMessageId = BehaviorSubject.seeded(-1);
  final BehaviorSubject<String?> text = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool?> openSearchResultPageOnFooter =
      BehaviorSubject.seeded(false);
  final _messageDao = GetIt.I.get<MessageDao>();
  late Uid? uid;

  void closeSearch() {
    inSearchMessageMode.add(null);
    text.add(null);
    foundMessageId.add(-1);
  }

  Future<List<Message>> searchMessagesResult(
    Uid roomUid,
    String keyword,
  ) async {
    if (keyword.isEmpty) {
      return [];
    }
    final messages = await _messageDao.searchMessages(roomUid, keyword);
    return messages;
  }
}
