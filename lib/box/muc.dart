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

  Muc({
    this.uid,
    this.name,
    this.token,
    this.id,
    this.info,
    this.pinMessagesIdList,
    this.population,
  });

  Muc copy(Muc muc) => Muc(
        uid: muc.uid ?? this.uid,
        name: muc.name ?? this.name,
        token: muc.token ?? this.token,
        id: muc.id ?? this.id,
        info: muc.info ?? this.info,
        pinMessagesIdList: muc.pinMessagesIdList ?? this.pinMessagesIdList,
        population: muc.population ?? this.population,
      );

  Muc copyWith({
    String uid,
    String name,
    String token,
    String id,
    String info,
    List<int> pinMessagesIdList,
    int population,
  }) =>
      Muc(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        token: token ?? this.token,
        id: id ?? this.id,
        info: info ?? this.info,
        pinMessagesIdList: pinMessagesIdList ?? this.pinMessagesIdList,
        population: population ?? this.population,
      );
}
