// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_network_connections.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalNetworkConnections _$LocalNetworkConnectionsFromJson(
    Map<String, dynamic> json) {
  return _LocalNetworkConnections.fromJson(json);
}

/// @nodoc
mixin _$LocalNetworkConnections {
  @UidJsonKey
  Uid get uid => throw _privateConstructorUsedError;
  String get ip => throw _privateConstructorUsedError;
  int get lastUpdateTime => throw _privateConstructorUsedError;
  bool get backupLocalMessages => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocalNetworkConnectionsCopyWith<LocalNetworkConnections> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalNetworkConnectionsCopyWith<$Res> {
  factory $LocalNetworkConnectionsCopyWith(LocalNetworkConnections value,
          $Res Function(LocalNetworkConnections) then) =
      _$LocalNetworkConnectionsCopyWithImpl<$Res, LocalNetworkConnections>;
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String ip,
      int lastUpdateTime,
      bool backupLocalMessages});
}

/// @nodoc
class _$LocalNetworkConnectionsCopyWithImpl<$Res,
        $Val extends LocalNetworkConnections>
    implements $LocalNetworkConnectionsCopyWith<$Res> {
  _$LocalNetworkConnectionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? ip = null,
    Object? lastUpdateTime = null,
    Object? backupLocalMessages = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      ip: null == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      backupLocalMessages: null == backupLocalMessages
          ? _value.backupLocalMessages
          : backupLocalMessages // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalNetworkConnectionsImplCopyWith<$Res>
    implements $LocalNetworkConnectionsCopyWith<$Res> {
  factory _$$LocalNetworkConnectionsImplCopyWith(
          _$LocalNetworkConnectionsImpl value,
          $Res Function(_$LocalNetworkConnectionsImpl) then) =
      __$$LocalNetworkConnectionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@UidJsonKey Uid uid,
      String ip,
      int lastUpdateTime,
      bool backupLocalMessages});
}

/// @nodoc
class __$$LocalNetworkConnectionsImplCopyWithImpl<$Res>
    extends _$LocalNetworkConnectionsCopyWithImpl<$Res,
        _$LocalNetworkConnectionsImpl>
    implements _$$LocalNetworkConnectionsImplCopyWith<$Res> {
  __$$LocalNetworkConnectionsImplCopyWithImpl(
      _$LocalNetworkConnectionsImpl _value,
      $Res Function(_$LocalNetworkConnectionsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? ip = null,
    Object? lastUpdateTime = null,
    Object? backupLocalMessages = null,
  }) {
    return _then(_$LocalNetworkConnectionsImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as Uid,
      ip: null == ip
          ? _value.ip
          : ip // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdateTime: null == lastUpdateTime
          ? _value.lastUpdateTime
          : lastUpdateTime // ignore: cast_nullable_to_non_nullable
              as int,
      backupLocalMessages: null == backupLocalMessages
          ? _value.backupLocalMessages
          : backupLocalMessages // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalNetworkConnectionsImpl implements _LocalNetworkConnections {
  const _$LocalNetworkConnectionsImpl(
      {@UidJsonKey required this.uid,
      required this.ip,
      required this.lastUpdateTime,
      this.backupLocalMessages = true});

  factory _$LocalNetworkConnectionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalNetworkConnectionsImplFromJson(json);

  @override
  @UidJsonKey
  final Uid uid;
  @override
  final String ip;
  @override
  final int lastUpdateTime;
  @override
  @JsonKey()
  final bool backupLocalMessages;

  @override
  String toString() {
    return 'LocalNetworkConnections(uid: $uid, ip: $ip, lastUpdateTime: $lastUpdateTime, backupLocalMessages: $backupLocalMessages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalNetworkConnectionsImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.lastUpdateTime, lastUpdateTime) ||
                other.lastUpdateTime == lastUpdateTime) &&
            (identical(other.backupLocalMessages, backupLocalMessages) ||
                other.backupLocalMessages == backupLocalMessages));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, uid, ip, lastUpdateTime, backupLocalMessages);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalNetworkConnectionsImplCopyWith<_$LocalNetworkConnectionsImpl>
      get copyWith => __$$LocalNetworkConnectionsImplCopyWithImpl<
          _$LocalNetworkConnectionsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalNetworkConnectionsImplToJson(
      this,
    );
  }
}

abstract class _LocalNetworkConnections implements LocalNetworkConnections {
  const factory _LocalNetworkConnections(
      {@UidJsonKey required final Uid uid,
      required final String ip,
      required final int lastUpdateTime,
      final bool backupLocalMessages}) = _$LocalNetworkConnectionsImpl;

  factory _LocalNetworkConnections.fromJson(Map<String, dynamic> json) =
      _$LocalNetworkConnectionsImpl.fromJson;

  @override
  @UidJsonKey
  Uid get uid;
  @override
  String get ip;
  @override
  int get lastUpdateTime;
  @override
  bool get backupLocalMessages;
  @override
  @JsonKey(ignore: true)
  _$$LocalNetworkConnectionsImplCopyWith<_$LocalNetworkConnectionsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
