// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'last_call_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

LastCallStatus _$LastCallStatusFromJson(Map<String, dynamic> json) {
  return _LastCallStatus.fromJson(json);
}

/// @nodoc
mixin _$LastCallStatus {
  int get id => throw _privateConstructorUsedError;
  String get callId => throw _privateConstructorUsedError;
  String get roomUid => throw _privateConstructorUsedError;
  int get expireTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LastCallStatusCopyWith<LastCallStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LastCallStatusCopyWith<$Res> {
  factory $LastCallStatusCopyWith(
          LastCallStatus value, $Res Function(LastCallStatus) then) =
      _$LastCallStatusCopyWithImpl<$Res, LastCallStatus>;
  @useResult
  $Res call({int id, String callId, String roomUid, int expireTime});
}

/// @nodoc
class _$LastCallStatusCopyWithImpl<$Res, $Val extends LastCallStatus>
    implements $LastCallStatusCopyWith<$Res> {
  _$LastCallStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callId = null,
    Object? roomUid = null,
    Object? expireTime = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      callId: null == callId
          ? _value.callId
          : callId // ignore: cast_nullable_to_non_nullable
              as String,
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as String,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LastCallStatusImplCopyWith<$Res>
    implements $LastCallStatusCopyWith<$Res> {
  factory _$$LastCallStatusImplCopyWith(_$LastCallStatusImpl value,
          $Res Function(_$LastCallStatusImpl) then) =
      __$$LastCallStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String callId, String roomUid, int expireTime});
}

/// @nodoc
class __$$LastCallStatusImplCopyWithImpl<$Res>
    extends _$LastCallStatusCopyWithImpl<$Res, _$LastCallStatusImpl>
    implements _$$LastCallStatusImplCopyWith<$Res> {
  __$$LastCallStatusImplCopyWithImpl(
      _$LastCallStatusImpl _value, $Res Function(_$LastCallStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callId = null,
    Object? roomUid = null,
    Object? expireTime = null,
  }) {
    return _then(_$LastCallStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      callId: null == callId
          ? _value.callId
          : callId // ignore: cast_nullable_to_non_nullable
              as String,
      roomUid: null == roomUid
          ? _value.roomUid
          : roomUid // ignore: cast_nullable_to_non_nullable
              as String,
      expireTime: null == expireTime
          ? _value.expireTime
          : expireTime // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LastCallStatusImpl implements _LastCallStatus {
  const _$LastCallStatusImpl(
      {required this.id,
      required this.callId,
      required this.roomUid,
      required this.expireTime});

  factory _$LastCallStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$LastCallStatusImplFromJson(json);

  @override
  final int id;
  @override
  final String callId;
  @override
  final String roomUid;
  @override
  final int expireTime;

  @override
  String toString() {
    return 'LastCallStatus(id: $id, callId: $callId, roomUid: $roomUid, expireTime: $expireTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LastCallStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.callId, callId) || other.callId == callId) &&
            (identical(other.roomUid, roomUid) || other.roomUid == roomUid) &&
            (identical(other.expireTime, expireTime) ||
                other.expireTime == expireTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, callId, roomUid, expireTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LastCallStatusImplCopyWith<_$LastCallStatusImpl> get copyWith =>
      __$$LastCallStatusImplCopyWithImpl<_$LastCallStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LastCallStatusImplToJson(
      this,
    );
  }
}

abstract class _LastCallStatus implements LastCallStatus {
  const factory _LastCallStatus(
      {required final int id,
      required final String callId,
      required final String roomUid,
      required final int expireTime}) = _$LastCallStatusImpl;

  factory _LastCallStatus.fromJson(Map<String, dynamic> json) =
      _$LastCallStatusImpl.fromJson;

  @override
  int get id;
  @override
  String get callId;
  @override
  String get roomUid;
  @override
  int get expireTime;
  @override
  @JsonKey(ignore: true)
  _$$LastCallStatusImplCopyWith<_$LastCallStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
