// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'is_verified.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

IsVerified _$IsVerifiedFromJson(Map<String, dynamic> json) {
  return _IsVerified.fromJson(json);
}

/// @nodoc
mixin _$IsVerified {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  int get lastUpdate => throw _privateConstructorUsedError;
  int get expireTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IsVerifiedCopyWith<IsVerified> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IsVerifiedCopyWith<$Res> {
  factory $IsVerifiedCopyWith(
          IsVerified value, $Res Function(IsVerified) then) =
      _$IsVerifiedCopyWithImpl<$Res, IsVerified>;
  @useResult
  $Res call({@UidJsonKey Uid uid, int lastUpdate, int expireTime});
}

/// @nodoc
class _$IsVerifiedCopyWithImpl<$Res, $Val extends IsVerified>
    implements $IsVerifiedCopyWith<$Res> {
  _$IsVerifiedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? lastUpdate = null,
    Object? expireTime = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      lastUpdate: null == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as int,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IsVerifiedImplCopyWith<$Res>
    implements $IsVerifiedCopyWith<$Res> {
  factory _$$IsVerifiedImplCopyWith(
          _$IsVerifiedImpl value, $Res Function(_$IsVerifiedImpl) then) =
      __$$IsVerifiedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@UidJsonKey Uid uid, int lastUpdate, int expireTime});
}

/// @nodoc
class __$$IsVerifiedImplCopyWithImpl<$Res>
    extends _$IsVerifiedCopyWithImpl<$Res, _$IsVerifiedImpl>
    implements _$$IsVerifiedImplCopyWith<$Res> {
  __$$IsVerifiedImplCopyWithImpl(
      _$IsVerifiedImpl _value, $Res Function(_$IsVerifiedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? lastUpdate = null,
    Object? expireTime = null,
  }) {
    return _then(_$IsVerifiedImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      lastUpdate: null == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as int,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IsVerifiedImpl implements _IsVerified {
  const _$IsVerifiedImpl(
      {@UidJsonKey required this.uid,
      required this.lastUpdate,
      required this.expireTime});

  factory _$IsVerifiedImpl.fromJson(Map<String, dynamic> json) =>
      _$$IsVerifiedImplFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  final int lastUpdate;
  @override
  final int expireTime;

  @override
  String toString() {
    return 'IsVerified(uid: $uid, lastUpdate: $lastUpdate, expireTime: $expireTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IsVerifiedImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            (identical(other.expireTime, expireTime) ||
                other.expireTime == expireTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, uid, lastUpdate, expireTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IsVerifiedImplCopyWith<_$IsVerifiedImpl> get copyWith =>
      __$$IsVerifiedImplCopyWithImpl<_$IsVerifiedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IsVerifiedImplToJson(
      this,
    );
  }
}

abstract class _IsVerified implements IsVerified {
  const factory _IsVerified(
      {@UidJsonKey required final Uid uid,
      required final int lastUpdate,
      required final int expireTime}) = _$IsVerifiedImpl;

  factory _IsVerified.fromJson(Map<String, dynamic> json) =
      _$IsVerifiedImpl.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  int get lastUpdate;
  @override
  int get expireTime;
  @override
  @JsonKey(ignore: true)
  _$$IsVerifiedImplCopyWith<_$IsVerifiedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
