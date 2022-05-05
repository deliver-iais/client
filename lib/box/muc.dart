import 'package:collection/collection.dart';
import 'package:deliver/shared/constants.dart';
import 'package:hive/hive.dart';

part 'muc.g.dart';

@HiveType(typeId: MUC_TRACK_ID)
class Muc {
  // DbID
  @HiveField(0)
  String uid;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? token;

  @HiveField(3)
  String? id;

  @HiveField(4)
  String? info;

  @HiveField(5)
  List<int>? pinMessagesIdList;

  @HiveField(6)
  int? population;

  @HiveField(7)
  int? lastMessageId;

  @HiveField(8)
  bool? showPinMessage = true;

  Muc({
    required this.uid,
    this.name,
    this.token,
    this.id,
    this.info,
    this.pinMessagesIdList,
    this.population,
    this.lastMessageId,
    this.showPinMessage,
  });

  Muc copy(Muc muc) => Muc(
        uid: muc.uid,
        name: muc.name ?? name,
        token: muc.token ?? token,
        id: muc.id ?? id,
        info: muc.info ?? info,
        lastMessageId: muc.lastMessageId ?? lastMessageId,
        pinMessagesIdList: muc.pinMessagesIdList ?? pinMessagesIdList,
        showPinMessage: muc.showPinMessage ?? showPinMessage,
        population: muc.population ?? population,
      );

  Muc copyWith({
    required String uid,
    String? name,
    String? token,
    String? id,
    String? info,
    int? lastMessageId,
    List<int>? pinMessagesIdList,
    int? population,
    bool? showPinMessage,
  }) =>
      Muc(
        uid: uid,
        name: name ?? this.name,
        token: token ?? this.token,
        id: id ?? this.id,
        info: info ?? this.info,
        lastMessageId: lastMessageId ?? this.lastMessageId,
        pinMessagesIdList: pinMessagesIdList ?? this.pinMessagesIdList,
        population: population ?? this.population,
        showPinMessage: showPinMessage ?? this.showPinMessage,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is Muc &&
          const DeepCollectionEquality().equals(other.uid, uid) &&
          const DeepCollectionEquality().equals(other.name, name) &&
          const DeepCollectionEquality().equals(other.token, token) &&
          const DeepCollectionEquality().equals(other.id, id) &&
          const DeepCollectionEquality().equals(other.info, info) &&
          const DeepCollectionEquality()
              .equals(other.pinMessagesIdList, pinMessagesIdList) &&
          const DeepCollectionEquality().equals(other.population, population) &&
          const DeepCollectionEquality()
              .equals(other.lastMessageId, lastMessageId) &&
          const DeepCollectionEquality()
              .equals(other.showPinMessage, showPinMessage));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(uid),
        const DeepCollectionEquality().hash(name),
        const DeepCollectionEquality().hash(token),
        const DeepCollectionEquality().hash(id),
        const DeepCollectionEquality().hash(info),
        const DeepCollectionEquality().hash(pinMessagesIdList),
        const DeepCollectionEquality().hash(population),
        const DeepCollectionEquality().hash(lastMessageId),
        const DeepCollectionEquality().hash(showPinMessage),
      );
}
