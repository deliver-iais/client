import 'dart:async';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/screen/room/widgets/search_bar.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SearchMessageService {

  Timer? highlightMessageTimer;
  final BehaviorSubject<bool?> isSearchMessageMode =
      BehaviorSubject.seeded(false);
  final BehaviorSubject<int> foundMessageId = BehaviorSubject.seeded(-1);
  final _messageDao = GetIt.I.get<MessageDao>();
  late Uid uid;

  void buildNavigationCenter(Uid roomUid) {
    uid = roomUid;
    isSearchMessageMode.add(true);
  }

  Widget buildSearchMessagePage() {
    return SearchMessagesScreen(uid: uid);
  }

  void x (){

  }

  Future<List<Message>> searchMessagesResult(
    Uid roomUid,
    String keyword,
  ) async {
    if (keyword.isEmpty) {
      return [];
    }
    final messages = await _messageDao.searchMessages(roomUid, keyword);
    //  for (var message in messages) {
    //   if(message.type == MessageType.FILE){
    //     if(!message.json.toFile().caption.contains(keyword)){
    //       messages.remove(message);
    //     }
    //   }
    // }
    return messages;

  }

  String extractText(Message msg) {
    if (msg.type == MessageType.TEXT) {
      return msg.json.toText().text.trim();
    } else if (msg.type == MessageType.FILE ) {
      return msg.json.toFile().caption.trim();
    } else {
      return "";
    }
  }

  Widget date(int msgTime) {
    final time = DateTime.fromMillisecondsSinceEpoch(msgTime);
    var msgDay = time.day.toString();
    var msgMonth = time.month.toString();
    final msgYear = time.year.toString();
    msgDay = msgDay.length != 2 ? '0$msgDay' : msgDay;
    msgMonth = msgMonth.length != 2 ? '0$msgMonth' : msgMonth;

    return Text(
      '$msgMonth/$msgDay/$msgYear',
      style: const TextStyle(fontStyle: FontStyle.italic),
    );
  }
}
