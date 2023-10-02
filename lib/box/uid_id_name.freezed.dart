// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'uid_id_name.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UidIdName _$UidIdNameFromJson(Map<String, dynamic> json) {
  return _UidIdName.fromJson(json);
}

/// @nodoc
mixin _$UidIdName {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get realName => throw _privateConstructorUsedError;
  int get lastUpdateTime => throw _privateConstructorUsedError;
  bool? get isContact => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UidIdNameCopyWith<UidIdName> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UidIdNameCopyWith<$Res> {
  factory $UidIdNameCopyWith(UidIdName value, $Res Function(UidIdName) then) =
      _$UidIdNameCopyWithImpl<$Res, UidIdName>;
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String? id,
      String? name,
      String? realName,
      int lastUpdateTime,
      bool? isContact});
}

/// @nodoc
class _$UidIdNameCopyWithImpl<$Res, $Val extends UidIdName>
    implements $UidIdNameCopyWith<$Res> {
  _$UidIdNameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = freezed,
    Object? name = freezed,
    Object? realName = freezed,
    Object? lastUpdateTime = null,
    Object? isContact = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      realName: freezed == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      isContact: freezed == isContact
          ? _value.isContact
          : isContact // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UidIdNameCopyWith<$Res> implements $UidIdNameCopyWith<$Res> {
  factory _$$_UidIdNameCopyWith(
          _$_UidIdName value, $Res Function(_$_UidIdName) then) =
      __$$_UidIdNameCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String? id,
      String? name,
      String? realName,
      int lastUpdateTime,
      bool? isContact});
}

/// @nodoc
class __$$_UidIdNameCopyWithImpl<$Res>
    extends _$UidIdNameCopyWithImpl<$Res, _$_UidIdName>
    implements _$$_UidIdNameCopyWith<$Res> {
  __$$_UidIdNameCopyWithImpl(
      _$_UidIdName _value, $Res Function(_$_UidIdName) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? id = freezed,
    Object? name = freezed,
    Object? realName = freezed,
    Object? lastUpdateTime = null,
    Object? isContact = freezed,
  }) {
    return _then(_$_UidIdName(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      realName: freezed == realName
          ? _value.realName
          : realName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      isContact: freezed == isContact
          ? _value.isContact
          : isContact // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UidIdName implements _UidIdName {
  const _$_UidIdName(
      {@UidJsonKey required this.uid,
      this.id,
      this.name,
      this.realName,
      this.lastUpdateTime = 0,
      this.isContact});

  factory _$_UidIdName.fromJson(Map<String, dynamic> json) =>
      _$$_UidIdNameFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? realName;
  @override
  @JsonKey()
  final int lastUpdateTime;
  @override
  final bool? isContact;

  @override
  String toString() {
    return 'UidIdName(uid: $uid, id: $id, name: $name, realName: $realName, lastUpdateTime: $lastUpdateTime, isContact: $isContact)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UidIdName &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.realName, realName) ||
                other.realName == realName) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.isContact, isContact) ||
                other.isContact == isContact));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, uid, id, name, realName, lastUpdateTime, isContact);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UidIdNameCopyWith<_$_UidIdName> get copyWith =>
      __$$_UidIdNameCopyWithImpl<_$_UidIdName>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UidIdNameToJson(
      this,
    );
  }
}

abstract class _UidIdName implements UidIdName {
  const factory _UidIdName(
      {@UidJsonKey required final Uid uid,
      final String? id,
      final String? name,
      final String? realName,
      final int lastUpdateTime,
      final bool? isContact}) = _$_UidIdName;

  factory _UidIdName.fromJson(Map<String, dynamic> json) =
      _$_UidIdName.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get realName;
  @override
  int get lastUpdateTime;
  @override
  bool? get isContact;
  @override
  @JsonKey(ignore: true)
  _$$_UidIdNameCopyWith<_$_UidIdName> get copyWith =>
      throw _privateConstructorUsedError;
}
