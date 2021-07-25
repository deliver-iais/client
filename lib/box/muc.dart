import 'package:deliver_flutter/shared/constants.dart';
import 'package:hive/hive.dart';

part 'muc.g.dart';

@HiveType(typeId: MUC_TRACK_ID)
class Muc {
  // DbID
  @HiveField(0)
  String uid;

  @HiveField(1)
  String name;

  @HiveField(2)
  String token;

  @HiveField(3)
  String id;

  @HiveField(4)
  String info;

  @HiveField(5)
  List<int> pinMessagesIdList;

  @HiveField(6)
  int population;

  @HiveField(7)
  int lastMessageId;

  @HiveField(8)
  bool showPinMessage = true;

  Muc({
    this.uid,
    this.name,
    this.token,
    this.id,
    this.info,
    this.pinMessagesIdList,
    this.population,
    this.lastMessageId,
    this.showPinMessage
  });

  Muc copy(Muc muc) => Muc(
        uid: muc.uid ?? this.uid,
        name: muc.name ?? this.name,
        token: muc.token ?? this.token,
        id: muc.id ?? this.id,
        info: muc.info ?? this.info,
        lastMessageId: muc.lastMessageId??this.lastMessageId,
        pinMessagesIdList: muc.pinMessagesIdList ?? this.pinMessagesIdList,
        showPinMessage: muc.showPinMessage??this.showPinMessage,
        population: muc.population ?? this.population,
      );

  Muc copyWith({
    String uid,
    String name,
    String token,
    String id,
    String info,
    int lastMessageId,
    List<int> pinMessagesIdList,
    int population,
    bool showPinMessage
  }) =>
      Muc(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        token: token ?? this.token,
        id: id ?? this.id,
        info: info ?? this.info,
        lastMessageId: lastMessageId??this.lastMessageId,
        pinMessagesIdList: pinMessagesIdList ?? this.pinMessagesIdList,
        population: population ?? this.population,
        showPinMessage: showPinMessage??this.showPinMessage
      );
}
