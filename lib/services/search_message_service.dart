import 'dart:async';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/widgets/search_message_room/search_messages_in_room.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessageService {
  final BehaviorSubject<Uid?> inSearchMessageMode =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<int> foundMessageId = BehaviorSubject.seeded(-1);
  final BehaviorSubject<String?> text = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool?> searchResult = BehaviorSubject.seeded(false);
  final _messageDao = GetIt.I.get<MessageDao>();
  late Uid? uid;

  Widget buildSearchMessagePage() {
    inSearchMessageMode.listen((value) {
      uid = value;
    });
    return SearchMessageInRoomWidget(uid: uid);
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
