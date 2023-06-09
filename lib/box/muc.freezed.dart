// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'muc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Muc _$MucFromJson(Map<String, dynamic> json) {
  return _Muc.fromJson(json);
}

/// @nodoc
mixin _$Muc {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get info => throw _privateConstructorUsedError;
  List<int> get pinMessagesIdList => throw _privateConstructorUsedError;
  dynamic get population => throw _privateConstructorUsedError;
  dynamic get lastCanceledPinMessageId => throw _privateConstructorUsedError;
  MucType get mucType => throw _privateConstructorUsedError;
  MucRole get currentUserRole => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MucCopyWith<Muc> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MucCopyWith<$Res> {
  factory $MucCopyWith(Muc value, $Res Function(Muc) then) =
      _$MucCopyWithImpl<$Res, Muc>;
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String name,
      String token,
      String id,
      String info,
      List<int> pinMessagesIdList,
      dynamic population,
      dynamic lastCanceledPinMessageId,
      MucType mucType,
      MucRole currentUserRole});
}

/// @nodoc
class _$MucCopyWithImpl<$Res, $Val extends Muc> implements $MucCopyWith<$Res> {
  _$MucCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? token = null,
    Object? id = null,
    Object? info = null,
    Object? pinMessagesIdList = null,
    Object? population = freezed,
    Object? lastCanceledPinMessageId = freezed,
    Object? mucType = null,
    Object? currentUserRole = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      info: null == info
          ? _value.info
          : info // ignore: cast_nullable_to_non_nullable
              as String,
      pinMessagesIdList: null == pinMessagesIdList
          ? _value.pinMessagesIdList
          : pinMessagesIdList // ignore: cast_nullable_to_non_nullable
              as List<int>,
      population: freezed == population
          ? _value.population
          : population // ignore: cast_nullable_to_non_nullable
              as dynamic,
      lastCanceledPinMessageId: freezed == lastCanceledPinMessageId
          ? _value.lastCanceledPinMessageId
          : lastCanceledPinMessageId // ignore: cast_nullable_to_non_nullable
              as dynamic,
      mucType: null == mucType
          ? _value.mucType
          : mucType // ignore: cast_nullable_to_non_nullable
              as MucType,
      currentUserRole: null == currentUserRole
          ? _value.currentUserRole
          : currentUserRole // ignore: cast_nullable_to_non_nullable
              as MucRole,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_MucCopyWith<$Res> implements $MucCopyWith<$Res> {
  factory _$$_MucCopyWith(_$_Muc value, $Res Function(_$_Muc) then) =
      __$$_MucCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String name,
      String token,
      String id,
      String info,
      List<int> pinMessagesIdList,
      dynamic population,
      dynamic lastCanceledPinMessageId,
      MucType mucType,
      MucRole currentUserRole});
}

/// @nodoc
class __$$_MucCopyWithImpl<$Res> extends _$MucCopyWithImpl<$Res, _$_Muc>
    implements _$$_MucCopyWith<$Res> {
  __$$_MucCopyWithImpl(_$_Muc _value, $Res Function(_$_Muc) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? name = null,
    Object? token = null,
    Object? id = null,
    Object? info = null,
    Object? pinMessagesIdList = null,
    Object? population = freezed,
    Object? lastCanceledPinMessageId = freezed,
    Object? mucType = null,
    Object? currentUserRole = null,
  }) {
    return _then(_$_Muc(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      info: null == info
          ? _value.info
          : info // ignore: cast_nullable_to_non_nullable
              as String,
      pinMessagesIdList: null == pinMessagesIdList
          ? _value._pinMessagesIdList
          : pinMessagesIdList // ignore: cast_nullable_to_non_nullable
              as List<int>,
      population: freezed == population ? _value.population! : population,
      lastCanceledPinMessageId: freezed == lastCanceledPinMessageId
          ? _value.lastCanceledPinMessageId!
          : lastCanceledPinMessageId,
      mucType: null == mucType
          ? _value.mucType
          : mucType // ignore: cast_nullable_to_non_nullable
              as MucType,
      currentUserRole: null == currentUserRole
          ? _value.currentUserRole
          : currentUserRole // ignore: cast_nullable_to_non_nullable
              as MucRole,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Muc implements _Muc {
  const _$_Muc(
      {@UidJsonKey required this.uid,
      this.name = "",
      this.token = "",
      this.id = "",
      this.info = "",
      final List<int> pinMessagesIdList = const [],
      this.population = 0,
      this.lastCanceledPinMessageId = 0,
      this.mucType = MucType.Public,
      this.currentUserRole = MucRole.NONE})
      : _pinMessagesIdList = pinMessagesIdList;

  factory _$_Muc.fromJson(Map<String, dynamic> json) => _$$_MucFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String token;
  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String info;
  final List<int> _pinMessagesIdList;
  @override
  @JsonKey()
  List<int> get pinMessagesIdList {
    if (_pinMessagesIdList is EqualUnmodifiableListView)
      return _pinMessagesIdList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pinMessagesIdList);
  }

  @override
  @JsonKey()
  final dynamic population;
  @override
  @JsonKey()
  final dynamic lastCanceledPinMessageId;
  @override
  @JsonKey()
  final MucType mucType;
  @override
  @JsonKey()
  final MucRole currentUserRole;

  @override
  String toString() {
    return 'Muc(uid: $uid, name: $name, token: $token, id: $id, info: $info, pinMessagesIdList: $pinMessagesIdList, population: $population, lastCanceledPinMessageId: $lastCanceledPinMessageId, mucType: $mucType, currentUserRole: $currentUserRole)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Muc &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.info, info) || other.info == info) &&
            const DeepCollectionEquality()
                .equals(other._pinMessagesIdList, _pinMessagesIdList) &&
            const DeepCollectionEquality()
                .equals(other.population, population) &&
            const DeepCollectionEquality().equals(
                other.lastCanceledPinMessageId, lastCanceledPinMessageId) &&
            (identical(other.mucType, mucType) || other.mucType == mucType) &&
            (identical(other.currentUserRole, currentUserRole) ||
                other.currentUserRole == currentUserRole));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      name,
      token,
      id,
      info,
      const DeepCollectionEquality().hash(_pinMessagesIdList),
      const DeepCollectionEquality().hash(population),
      const DeepCollectionEquality().hash(lastCanceledPinMessageId),
      mucType,
      currentUserRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MucCopyWith<_$_Muc> get copyWith =>
      __$$_MucCopyWithImpl<_$_Muc>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_MucToJson(
      this,
    );
  }
}

abstract class _Muc implements Muc {
  const factory _Muc(
      {@UidJsonKey required final Uid uid,
      final String name,
      final String token,
      final String id,
      final String info,
      final List<int> pinMessagesIdList,
      final dynamic population,
      final dynamic lastCanceledPinMessageId,
      final MucType mucType,
      final MucRole currentUserRole}) = _$_Muc;

  factory _Muc.fromJson(Map<String, dynamic> json) = _$_Muc.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  String get name;
  @override
  String get token;
  @override
  String get id;
  @override
  String get info;
  @override
  List<int> get pinMessagesIdList;
  @override
  dynamic get population;
  @override
  dynamic get lastCanceledPinMessageId;
  @override
  MucType get mucType;
  @override
  MucRole get currentUserRole;
  @override
  @JsonKey(ignore: true)
  _$$_MucCopyWith<_$_Muc> get copyWith => throw _privateConstructorUsedError;
}
