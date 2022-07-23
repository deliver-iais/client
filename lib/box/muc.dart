import 'package:collection/collection.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/shared/constants.dart';
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
  int lastCanceledPinMessageId;

  @HiveField(8)
  MucType mucType;

  Muc({
    required this.uid,
    this.name = "",
    this.token = "",
    this.id = "",
    this.info = "",
    this.pinMessagesIdList = const [],
    this.population = 0,
    this.lastCanceledPinMessageId = 0,
    this.mucType = MucType.Public,
  });

  Muc copyWith({
    required String uid,
    String? name,
    String? token,
    String? id,
    String? info,
    int? lastMessageId,
    List<int>? pinMessagesIdList,
    int? population,
    int? lastCanceledPinMessageId,
    MucType? mucType,
  }) =>
      Muc(
        uid: uid,
        name: name ?? this.name,
        token: token ?? this.token,
        id: id ?? this.id,
        info: info ?? this.info,
        pinMessagesIdList: pinMessagesIdList ?? this.pinMessagesIdList,
        population: population ?? this.population,
        lastCanceledPinMessageId:
            lastCanceledPinMessageId ?? this.lastCanceledPinMessageId,
        mucType: mucType ?? this.mucType,
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
          const DeepCollectionEquality().equals(other.mucType, mucType) &&
          const DeepCollectionEquality().equals(
            other.lastCanceledPinMessageId,
            lastCanceledPinMessageId,
          ));

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
        const DeepCollectionEquality().hash(lastCanceledPinMessageId),
        const DeepCollectionEquality().hash(mucType),
      );
}
